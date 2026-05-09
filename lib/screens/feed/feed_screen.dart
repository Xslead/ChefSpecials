import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/user_model.dart';
import '../../utils/category_helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/block_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/follow_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import '../home/widgets/recipe_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select<AuthProvider, bool>((a) => a.isAuthenticated);
    if (!isAuthenticated) {
      return const _LoginRequiredView();
    }
    return ChangeNotifierProvider(
      create: (_) => FeedProvider(),
      child: const _FeedBody(),
    );
  }
}

class _LoginRequiredView extends StatelessWidget {
  const _LoginRequiredView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.dynamic_feed_outlined,
                    size: 36,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.loginRequired,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.loginRequiredFeedMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryOf(context),
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: ElevatedButton(
                      onPressed: () => context.push('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                      ),
                      child: Text(
                        l10n.signIn,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: Text(
                    l10n.signUp,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedBody extends StatefulWidget {
  const _FeedBody();

  @override
  State<_FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends State<_FeedBody> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  StreamSubscription<MapEntry<String, String>>? _authorNameSub;
  Set<String> _followingIdSet = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
      _authorNameSub = context
          .read<RecipeProvider>()
          .authorNameChanges
          .listen((entry) {
        if (!mounted) return;
        context.read<FeedProvider>().updateAuthorName(entry.key, entry.value);
      });
    });
  }

  @override
  void dispose() {
    _authorNameSub?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _init() {
    final currentUser = context.read<AuthProvider>().userModel;
    if (currentUser != null) {
      context.read<FollowProvider>().initialize(currentUser.uid,
          userName: currentUser.fullName, userAvatar: currentUser.photoUrl);
      context.read<BlockProvider>().initialize(currentUser.uid);
    }
    final followProvider = context.read<FollowProvider>();
    _followingIdSet = Set.from(followProvider.followingIds);
    context.read<FeedProvider>().loadFeed(followProvider.followingList);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<FeedProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final followProvider = context.watch<FollowProvider>();
    final feedProvider = context.watch<FeedProvider>();

    // Show error SnackBar when provider sets an error
    if (feedProvider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.error)),
          );
        }
      });
    }

    // Reload when following set changes
    final currentSet = followProvider.followingIds;
    if (!feedProvider.isLoading &&
        (currentSet.length != _followingIdSet.length ||
            currentSet.any((id) => !_followingIdSet.contains(id)))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _followingIdSet = Set.from(currentSet);
        feedProvider.loadFeed(followProvider.followingList);
      });
    }

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n, feedProvider),
          Expanded(child: _buildBody(context, l10n, feedProvider)),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AppLocalizations l10n, FeedProvider feedProvider) {
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
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search bar + filter button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.neutralLightOf(context),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(Icons.search,
                              color: AppTheme.textTertiaryOf(context),
                              size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: l10n.searchFeedHint,
                                hintStyle: TextStyle(
                                  color: AppTheme.textTertiaryOf(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              onChanged: feedProvider.onSearchChanged,
                            ),
                          ),
                          if (feedProvider.searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                feedProvider.clearSearch();
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
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context, feedProvider),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: feedProvider.activeFilterCount > 0
                            ? AppTheme.primaryColor
                            : AppTheme.neutralLightOf(context),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Badge(
                        isLabelVisible: feedProvider.activeFilterCount > 0,
                        label: Text(
                          '${feedProvider.activeFilterCount}',
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                        backgroundColor: Colors.white,
                        textColor: AppTheme.primaryColor,
                        child: Icon(
                          Icons.tune_rounded,
                          size: 22,
                          color: feedProvider.activeFilterCount > 0
                              ? Colors.white
                              : AppTheme.textTertiaryOf(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, AppLocalizations l10n, FeedProvider feedProvider) {
    if (feedProvider.isLoading) {
      return const LoadingState();
    }

    // When searching, show user results + recipe filter
    if (feedProvider.searchQuery.isNotEmpty) {
      return _buildSearchResults(context, l10n, feedProvider);
    }

    if (feedProvider.followingIds.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: l10n.noFollowing,
        subtitle: l10n.noFollowingSubtitle,
      );
    }

    final blockedIds = context.watch<BlockProvider>().blockedUserIds;
    final items = feedProvider.displayedRecipes
        .where((r) => !blockedIds.contains(r.authorId))
        .toList();

    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.dynamic_feed_outlined,
        title: l10n.noFeedRecipes,
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () => feedProvider.loadFeed(feedProvider.followingIds),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: items.length + (feedProvider.isLoadingMore ? 1 : 0),
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

  Widget _buildSearchResults(
      BuildContext context, AppLocalizations l10n, FeedProvider feedProvider) {
    final blockedIds = context.read<BlockProvider>().blockedUserIds;
    final filteredRecipes = feedProvider.displayedRecipes
        .where((r) => !blockedIds.contains(r.authorId))
        .toList();
    final searchedUsers = feedProvider.searchedUsers
        .where((u) => !blockedIds.contains(u.uid))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
      children: [
        // People section
        if (feedProvider.isSearchingUsers)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primaryColor, strokeWidth: 2),
            ),
          )
        else if (searchedUsers.isNotEmpty) ...[
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
              itemCount: searchedUsers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _buildUserCard(searchedUsers[index]),
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

  void _showFilterSheet(BuildContext context, FeedProvider feedProvider) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.neutralLightOf(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.tune_rounded,
                            color: AppTheme.primaryColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.filters,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (feedProvider.activeFilterCount > 0)
                        TextButton(
                          onPressed: () {
                            feedProvider.clearFilters();
                            setSheetState(() {});
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
                          ),
                          child: Text(l10n.clearAll,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Divider(
                    color: AppTheme.neutralLightOf(context), height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context,
                            icon: Icons.category_rounded,
                            title: l10n.category),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              AppConstants.defaultCategories.map((cat) {
                            final isSelected =
                                feedProvider.selectedCategory == cat;
                            return _buildChip(
                              context: context,
                              label: _localizeCategory(cat, l10n),
                              selected: isSelected,
                              onTap: () {
                                feedProvider.setCategory(
                                    isSelected ? null : cat);
                                setSheetState(() {});
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(context,
                            icon: Icons.eco_rounded,
                            title: l10n.dietaryTags),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppConstants.defaultDietaryTags
                              .map((tag) {
                            final isSelected = feedProvider
                                .selectedDietaryTags
                                .contains(tag);
                            return _buildChip(
                              context: context,
                              label: localizeDietaryTag(tag, l10n),
                              selected: isSelected,
                              outlined: true,
                              onTap: () {
                                feedProvider.toggleDietaryTag(tag);
                                setSheetState(() {});
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(context,
                            icon: Icons.sort_rounded,
                            title: l10n.sortBy),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildSortOption(
                                context,
                                setSheetState,
                                feedProvider,
                                'newest',
                                l10n.newest),
                            _buildSortOption(
                                context,
                                setSheetState,
                                feedProvider,
                                'oldest',
                                l10n.oldest),
                            _buildSortOption(
                                context,
                                setSheetState,
                                feedProvider,
                                'popular',
                                l10n.popular),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        feedProvider.activeFilterCount > 0
                            ? l10n.applyFiltersCount(
                                feedProvider.activeFilterCount)
                            : l10n.applyFilters,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context,
      {required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryOf(context),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? (outlined
                  ? AppTheme.primaryColor.withValues(alpha: 0.12)
                  : AppTheme.primaryColor)
              : AppTheme.neutralLightOf(context),
          borderRadius: BorderRadius.circular(50),
          border: selected && outlined
              ? Border.all(color: AppTheme.primaryColor, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? (outlined ? AppTheme.primaryColor : Colors.white)
                : AppTheme.textSecondaryOf(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, StateSetter setSheetState,
      FeedProvider feedProvider, String value, String label) {
    final isSelected = feedProvider.sortBy == value;
    return GestureDetector(
      onTap: () {
        feedProvider.setSortBy(value);
        setSheetState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.neutralLightOf(context),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AppTheme.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _localizeCategory(String category, AppLocalizations l10n) {
    switch (category) {
      case 'Breakfast':
        return l10n.breakfast;
      case 'Lunch':
        return l10n.lunch;
      case 'Dinner':
        return l10n.dinner;
      case 'Dessert':
        return l10n.dessert;
      case 'Snack':
        return l10n.snack;
      case 'Drink':
        return l10n.drink;
      case 'Salad':
        return l10n.salad;
      case 'Soup':
        return l10n.soup;
      default:
        return category;
    }
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
              color:
                  AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
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
                        color:
                            AppTheme.primaryColor.withValues(alpha: 0.1),
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
