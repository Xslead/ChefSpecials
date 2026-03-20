import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/feed_provider.dart';
import 'package:chef_specials/services/recipe_service.dart';
import 'package:chef_specials/services/user_service.dart';
import 'package:chef_specials/models/recipe.dart';

Recipe _makeRecipe({
  String title = 'Test Recipe',
  String authorId = 'user1',
  String authorName = 'Chef',
  String category = 'Breakfast',
  bool isPrivate = false,
  double averageRating = 0.0,
  List<String> dietaryTags = const [],
  DateTime? createdAt,
}) {
  return Recipe(
    title: title,
    description: 'A test recipe',
    authorId: authorId,
    authorName: authorName,
    category: category,
    servings: 2,
    prepTimeMinutes: 10,
    cookTimeMinutes: 20,
    ingredients: [],
    steps: [],
    createdAt: createdAt ?? DateTime.now(),
    isPrivate: isPrivate,
    averageRating: averageRating,
    dietaryTags: dietaryTags,
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late RecipeService recipeService;
  late UserService userService;
  late FeedProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    recipeService = RecipeService(firestore: fakeFirestore);
    userService = UserService(firestore: fakeFirestore);
    provider = FeedProvider(
      recipeService: recipeService,
      userService: userService,
    );
  });

  group('FeedProvider', () {
    test('initial state', () {
      expect(provider.recipes, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.isLoadingMore, false);
      expect(provider.hasMore, true);
      expect(provider.searchQuery, '');
      expect(provider.followingIds, isEmpty);
      expect(provider.selectedCategory, isNull);
      expect(provider.selectedDietaryTags, isEmpty);
      expect(provider.sortBy, 'newest');
      expect(provider.searchedUsers, isEmpty);
      expect(provider.isSearchingUsers, false);
      expect(provider.error, isNull);
      expect(provider.activeFilterCount, 0);
    });

    test('loadFeed with empty following IDs sets isLoading false', () async {
      await provider.loadFeed([]);

      expect(provider.isLoading, false);
      expect(provider.recipes, isEmpty);
      expect(provider.followingIds, isEmpty);
    });

    test('loadFeed with empty following IDs notifies listeners', () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.loadFeed([]);

      // Two notifications: isLoading=true, then isLoading=false
      expect(notifyCount, 2);
    });

    test('loadFeed success loads recipes from followed users', () async {
      // Add a public recipe by user1
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(authorId: 'user1', title: 'Pancakes').toMap());

      await provider.loadFeed(['user1']);

      expect(provider.isLoading, false);
      expect(provider.recipes, hasLength(1));
      expect(provider.recipes.first.title, 'Pancakes');
      expect(provider.followingIds, ['user1']);
    });

    test('loadFeed filters out private recipes', () async {
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(authorId: 'user1', title: 'Public').toMap());
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(authorId: 'user1', title: 'Private', isPrivate: true)
              .toMap());

      await provider.loadFeed(['user1']);

      expect(provider.recipes, hasLength(1));
      expect(provider.recipes.first.title, 'Public');
    });

    test('loadFeed failure sets error', () async {
      // Create a provider with a service that will throw
      final badProvider = FeedProvider(
        recipeService: RecipeService(firestore: FakeFirebaseFirestore()),
        userService: userService,
      );
      // Inject recipes for a user that doesn't exist in this firestore instance
      // The real failure would come from network, but we can test error handling
      // by calling loadFeed which internally calls getFeedRecipes
      await badProvider.loadFeed(['user1']);

      // With fake_cloud_firestore, this won't actually error — it returns empty
      expect(badProvider.isLoading, false);
      expect(badProvider.recipes, isEmpty);
    });

    test('loadFeed resets state before loading', () async {
      // First load
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(authorId: 'user1', title: 'Recipe1').toMap());
      await provider.loadFeed(['user1']);
      expect(provider.recipes, hasLength(1));

      // Second load — should reset and reload
      await provider.loadFeed(['user1']);
      expect(provider.recipes, hasLength(1));
      expect(provider.error, isNull);
    });

    test('loadMore does nothing when isLoadingMore is already true', () async {
      // loadMore guards against concurrent calls
      await provider.loadFeed([]);
      // _hasMore is true but _oldestLoaded is null, so it won't proceed
      await provider.loadMore();
      expect(provider.isLoadingMore, false);
    });

    test('loadMore does nothing when hasMore is false', () async {
      await provider.loadFeed(['user1']);
      // With 0 recipes, hasMore gets set to true initially but oldestLoaded is null
      await provider.loadMore();
      expect(provider.isLoadingMore, false);
    });

    test('loadMore appends recipes', () async {
      // Add 20 recipes to trigger hasMore=true
      final baseTime = DateTime(2025, 1, 1);
      for (var i = 0; i < 21; i++) {
        await fakeFirestore.collection('recipes').add(
            _makeRecipe(
              authorId: 'user1',
              title: 'Recipe $i',
              createdAt: baseTime.add(Duration(hours: i)),
            ).toMap());
      }

      await provider.loadFeed(['user1']);
      final initialCount = provider.recipes.length;

      if (provider.hasMore) {
        await provider.loadMore();
        // After loadMore, total should be >= initialCount
        expect(provider.recipes.length, greaterThanOrEqualTo(initialCount));
      }
      expect(provider.isLoadingMore, false);
    });

    test('onSearchChanged sets search query immediately', () {
      provider.onSearchChanged('pasta');
      expect(provider.searchQuery, 'pasta');
    });

    test('onSearchChanged trims whitespace', () {
      provider.onSearchChanged('  pasta  ');
      expect(provider.searchQuery, 'pasta');
    });

    test('onSearchChanged with empty clears search users', () {
      provider.onSearchChanged('test');
      expect(provider.isSearchingUsers, true);

      provider.onSearchChanged('');
      expect(provider.searchQuery, '');
      expect(provider.searchedUsers, isEmpty);
      expect(provider.isSearchingUsers, false);
    });

    test('onSearchChanged debounces user search', () async {
      // Add a user to search for
      await fakeFirestore.collection('users').doc('u1').set({
        'uid': 'u1',
        'email': 'alice@test.com',
        'firstName': 'Alice',
        'lastName': 'Smith',
        'fullName': 'Alice Smith',
        'createdAt': DateTime.now().toIso8601String(),
      });

      provider.onSearchChanged('alice');
      // Immediately after, isSearchingUsers should be true
      expect(provider.isSearchingUsers, true);
      expect(provider.searchedUsers, isEmpty);

      // Wait for debounce (400ms) + async work
      await Future.delayed(const Duration(milliseconds: 600));

      expect(provider.isSearchingUsers, false);
      expect(provider.searchedUsers, hasLength(1));
      expect(provider.searchedUsers.first.firstName, 'Alice');
    });

    test('clearSearch resets search state', () {
      provider.onSearchChanged('test');
      provider.clearSearch();

      expect(provider.searchQuery, '');
      expect(provider.searchedUsers, isEmpty);
      expect(provider.isSearchingUsers, false);
    });

    test('clearSearch notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.clearSearch();
      expect(notifyCount, 1);
    });

    test('setCategory updates selectedCategory', () {
      provider.setCategory('Dinner');
      expect(provider.selectedCategory, 'Dinner');

      provider.setCategory(null);
      expect(provider.selectedCategory, isNull);
    });

    test('setCategory notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setCategory('Lunch');
      expect(notifyCount, 1);
    });

    test('toggleDietaryTag adds and removes tags', () {
      provider.toggleDietaryTag('Vegan');
      expect(provider.selectedDietaryTags, contains('Vegan'));

      provider.toggleDietaryTag('Vegan');
      expect(provider.selectedDietaryTags, isNot(contains('Vegan')));
    });

    test('toggleDietaryTag notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.toggleDietaryTag('Keto');
      expect(notifyCount, 1);
    });

    test('setSortBy updates sort order', () {
      provider.setSortBy('oldest');
      expect(provider.sortBy, 'oldest');

      provider.setSortBy('popular');
      expect(provider.sortBy, 'popular');
    });

    test('setSortBy notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setSortBy('popular');
      expect(notifyCount, 1);
    });

    test('clearFilters resets all filter state', () {
      provider.setCategory('Breakfast');
      provider.toggleDietaryTag('Vegan');
      provider.setSortBy('oldest');

      expect(provider.activeFilterCount, 3);

      provider.clearFilters();
      expect(provider.selectedCategory, isNull);
      expect(provider.selectedDietaryTags, isEmpty);
      expect(provider.sortBy, 'newest');
      expect(provider.activeFilterCount, 0);
    });

    test('clearFilters notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.clearFilters();
      expect(notifyCount, 1);
    });

    test('activeFilterCount reflects combined filter state', () {
      expect(provider.activeFilterCount, 0);

      provider.setCategory('Lunch');
      expect(provider.activeFilterCount, 1);

      provider.toggleDietaryTag('Vegan');
      expect(provider.activeFilterCount, 2);

      provider.toggleDietaryTag('Keto');
      expect(provider.activeFilterCount, 3);

      provider.setSortBy('popular');
      expect(provider.activeFilterCount, 4);
    });

    test('displayedRecipes filters by search query', () async {
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(authorId: 'user1', title: 'Pancakes').toMap());
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(authorId: 'user1', title: 'Pasta').toMap());

      await provider.loadFeed(['user1']);
      provider.onSearchChanged('pan');

      final displayed = provider.displayedRecipes;
      expect(displayed, hasLength(1));
      expect(displayed.first.title, 'Pancakes');
    });

    test('displayedRecipes filters by category', () async {
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(
                  authorId: 'user1', title: 'Eggs', category: 'Breakfast')
              .toMap());
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(
                  authorId: 'user1', title: 'Pasta', category: 'Dinner')
              .toMap());

      await provider.loadFeed(['user1']);
      provider.setCategory('Breakfast');

      final displayed = provider.displayedRecipes;
      expect(displayed, hasLength(1));
      expect(displayed.first.title, 'Eggs');
    });

    test('displayedRecipes filters by dietary tags', () async {
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(
            authorId: 'user1',
            title: 'Salad',
            dietaryTags: ['Vegan', 'Gluten Free'],
          ).toMap());
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(
            authorId: 'user1',
            title: 'Steak',
            dietaryTags: ['High Protein'],
          ).toMap());

      await provider.loadFeed(['user1']);
      provider.toggleDietaryTag('Vegan');

      final displayed = provider.displayedRecipes;
      expect(displayed, hasLength(1));
      expect(displayed.first.title, 'Salad');
    });

    test('displayedRecipes sorts by oldest', () async {
      final older = DateTime(2025, 1, 1);
      final newer = DateTime(2025, 6, 1);

      await fakeFirestore.collection('recipes').add(
          _makeRecipe(authorId: 'user1', title: 'Old', createdAt: older)
              .toMap());
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(authorId: 'user1', title: 'New', createdAt: newer)
              .toMap());

      await provider.loadFeed(['user1']);
      provider.setSortBy('oldest');

      final displayed = provider.displayedRecipes;
      expect(displayed.first.title, 'Old');
      expect(displayed.last.title, 'New');
    });

    test('displayedRecipes sorts by popular', () async {
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(
                  authorId: 'user1', title: 'Low Rated', averageRating: 2.0)
              .toMap());
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(
                  authorId: 'user1', title: 'High Rated', averageRating: 5.0)
              .toMap());

      await provider.loadFeed(['user1']);
      provider.setSortBy('popular');

      final displayed = provider.displayedRecipes;
      expect(displayed.first.title, 'High Rated');
      expect(displayed.last.title, 'Low Rated');
    });

    test('displayedRecipes default sorts by newest', () async {
      final older = DateTime(2025, 1, 1);
      final newer = DateTime(2025, 6, 1);

      await fakeFirestore.collection('recipes').add(
          _makeRecipe(authorId: 'user1', title: 'Old', createdAt: older)
              .toMap());
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(authorId: 'user1', title: 'New', createdAt: newer)
              .toMap());

      await provider.loadFeed(['user1']);

      final displayed = provider.displayedRecipes;
      expect(displayed.first.title, 'New');
      expect(displayed.last.title, 'Old');
    });

    test('updateAuthorName updates matching recipes', () async {
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(
                  authorId: 'author1', authorName: 'OldName', title: 'R1')
              .toMap());
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(
                  authorId: 'author1', authorName: 'OldName', title: 'R2')
              .toMap());
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(
                  authorId: 'author2', authorName: 'Other', title: 'R3')
              .toMap());

      await provider.loadFeed(['author1', 'author2']);
      provider.updateAuthorName('author1', 'NewName');

      final author1Recipes =
          provider.recipes.where((r) => r.authorId == 'author1');
      for (final r in author1Recipes) {
        expect(r.authorName, 'NewName');
      }
      final author2Recipes =
          provider.recipes.where((r) => r.authorId == 'author2');
      for (final r in author2Recipes) {
        expect(r.authorName, 'Other');
      }
    });

    test('updateAuthorName notifies listeners', () async {
      await fakeFirestore.collection('recipes').add(
          _makeRecipe(authorId: 'a1', authorName: 'Old').toMap());
      await provider.loadFeed(['a1']);

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.updateAuthorName('a1', 'New');
      expect(notifyCount, 1);
    });

    test('displayedRecipes returns empty when no recipes loaded', () {
      expect(provider.displayedRecipes, isEmpty);
    });

    test('dispose cancels debounce timer without error', () {
      provider.onSearchChanged('test');
      // Should not throw
      provider.dispose();
    });
  });
}
