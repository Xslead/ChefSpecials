import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/recipe.dart';
import '../../providers/auth_provider.dart';
import '../../providers/follow_provider.dart';
import '../../services/recipe_service.dart';
import '../home/widgets/recipe_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final RecipeService _recipeService = RecipeService();
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
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.neutralLightOf(context),
                  borderRadius: BorderRadius.circular(14),
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
                          hintText: l10n.searchHint,
                          hintStyle: TextStyle(
                            color: AppTheme.textTertiaryOf(context),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 14),
                        onChanged: (v) =>
                            setState(() => _searchQuery = v.trim()),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
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
      return const Center(
        child: CircularProgressIndicator(
            color: AppTheme.primaryColor, strokeWidth: 2),
      );
    }

    if (_followingIds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline,
                  size: 72, color: AppTheme.neutralLightOf(context)),
              const SizedBox(height: 16),
              Text(
                l10n.noFollowing,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondaryOf(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noFollowingSubtitle,
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textTertiaryOf(context),
                    height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final items = _displayedRecipes;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dynamic_feed_outlined,
                size: 64, color: AppTheme.neutralLightOf(context)),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? l10n.noResults : l10n.noFeedRecipes,
              style: TextStyle(
                  fontSize: 15, color: AppTheme.textTertiaryOf(context)),
            ),
          ],
        ),
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
              child: Center(
                child: CircularProgressIndicator(
                    color: AppTheme.primaryColor, strokeWidth: 2),
              ),
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
}
