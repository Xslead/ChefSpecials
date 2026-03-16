import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/recipe.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/follow_provider.dart';
import '../../services/recipe_service.dart';
import '../../services/user_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import '../home/widgets/recipe_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final RecipeService _recipeService = RecipeService();
  final UserService _userService = UserService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Recipe> _recipes = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DateTime? _oldestLoaded;
  String _searchQuery = '';
  List<String> _followingIds = [];
  Set<String> _followingIdSet = {};

  // User search
  Timer? _userSearchDebounce;
  List<UserModel> _searchedUsers = [];
  bool _isSearchingUsers = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _userSearchDebounce?.cancel();
    super.dispose();
  }

  void _init() {
    final currentUser = context.read<AuthProvider>().userModel;
    if (currentUser != null) {
      context.read<FollowProvider>().initialize(currentUser.uid);
    }
    _loadFeed();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadFeed() async {
    final followProvider = context.read<FollowProvider>();
    _followingIds = followProvider.followingList;
    _followingIdSet = Set.from(followProvider.followingIds);

    setState(() {
      _isLoading = true;
      _recipes = [];
      _oldestLoaded = null;
      _hasMore = true;
    });

    if (_followingIds.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final fetched = await _recipeService.getFeedRecipes(_followingIds);
      if (mounted) {
        setState(() {
          _recipes = fetched;
          _hasMore = fetched.length == 20;
          _oldestLoaded =
              fetched.isNotEmpty ? fetched.last.createdAt : null;
        });
      }
    } catch (e) {
      debugPrint('FeedScreen load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _oldestLoaded == null) return;
    setState(() => _isLoadingMore = true);
    try {
      final fetched = await _recipeService.getFeedRecipes(
        _followingIds,
        before: _oldestLoaded,
      );
      if (mounted) {
        setState(() {
          _recipes.addAll(fetched);
          _hasMore = fetched.length == 20;
          if (fetched.isNotEmpty) _oldestLoaded = fetched.last.createdAt;
        });
      }
    } catch (e) {
      debugPrint('FeedScreen loadMore error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    setState(() => _searchQuery = trimmed);

    _userSearchDebounce?.cancel();
    if (trimmed.isEmpty) {
      setState(() {
        _searchedUsers = [];
        _isSearchingUsers = false;
      });
      return;
    }
    setState(() => _isSearchingUsers = true);
    _userSearchDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final users = await _userService.searchUsers(trimmed, limit: 10);
        if (mounted && _searchQuery == trimmed) {
          setState(() {
            _searchedUsers = users;
            _isSearchingUsers = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isSearchingUsers = false);
      }
    });
  }

  List<Recipe> get _displayedRecipes {
    if (_searchQuery.isEmpty) return _recipes;
    final q = _searchQuery.toLowerCase();
    return _recipes
        .where((r) => r.title.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final followProvider = context.watch<FollowProvider>();

    // Reload when following set changes
    final currentSet = followProvider.followingIds;
    if (!_isLoading &&
        (currentSet.length != _followingIdSet.length ||
            currentSet.any((id) => !_followingIdSet.contains(id)))) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadFeed());
    }

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n),
          Expanded(child: _buildBody(context, l10n)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.dynamic_feed_outlined,
                        color: AppTheme.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.feed,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.neutralLightOf(context),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search,
                        color: AppTheme.textTertiaryOf(context), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: l10n.searchFeedHint,
                          hintStyle: TextStyle(
                            color: AppTheme.textTertiaryOf(context),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 14),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _searchedUsers = [];
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.close_rounded,
                              size: 16,
                              color: AppTheme.textTertiaryOf(context)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    if (_isLoading) {
      return const LoadingState();
    }

    // When searching, show user results + recipe filter
    if (_searchQuery.isNotEmpty) {
      return _buildSearchResults(context, l10n);
    }

    if (_followingIds.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: l10n.noFollowing,
        subtitle: l10n.noFollowingSubtitle,
      );
    }

    final items = _displayedRecipes;

    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.dynamic_feed_outlined,
        title: l10n.noFeedRecipes,
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: _loadFeed,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: items.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: LoadingState(inline: true),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RecipeCard(recipe: items[index]),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, AppLocalizations l10n) {
    final filteredRecipes = _displayedRecipes;

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
      children: [
        // People section
        if (_isSearchingUsers)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primaryColor, strokeWidth: 2),
            ),
          )
        else if (_searchedUsers.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              l10n.people,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _searchedUsers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _buildUserCard(_searchedUsers[index]),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Filtered recipe results
        if (filteredRecipes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.dynamic_feed_outlined,
                      size: 48, color: AppTheme.neutralLightOf(context)),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noResults,
                    style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textTertiaryOf(context)),
                  ),
                ],
              ),
            ),
          )
        else
          ...filteredRecipes.map(
            (recipe) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: RecipeCard(recipe: recipe),
            ),
          ),
      ],
    );
  }

  Widget _buildUserCard(UserModel user) {
    return GestureDetector(
      onTap: () => context.push('/user/${user.uid}', extra: user.fullName),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
          boxShadow: [AppTheme.shadowOf(context)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: user.photoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: AppTheme.neutralSoft,
                          child: const Icon(Icons.person,
                              size: 20, color: AppTheme.textTertiary),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: AppTheme.neutralSoft,
                          child: const Icon(Icons.person,
                              size: 20, color: AppTheme.textTertiary),
                        ),
                      )
                    : Container(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: const Icon(Icons.person,
                            size: 20, color: AppTheme.primaryColor),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              user.firstName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (user.username != null)
              Text(
                '@${user.username}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
