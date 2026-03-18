import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/meal_plan_provider.dart';
import 'package:chef_specials/services/meal_plan_service.dart';
import 'package:chef_specials/models/meal_plan.dart';
import 'package:chef_specials/models/planned_meal.dart';
import 'package:chef_specials/models/recipe.dart';
import '../helpers/test_helpers.dart';

PlannedMeal _makeMeal({
  int day = 0,
  String mealType = 'breakfast',
  String recipeId = 'r1',
  String recipeName = 'Test Recipe',
  String? recipeImageUrl,
  int servings = 1,
}) {
  return PlannedMeal(
    day: day,
    mealType: mealType,
    recipeId: recipeId,
    recipeName: recipeName,
    recipeImageUrl: recipeImageUrl,
    servings: servings,
  );
}

MealPlan _makePlan({
  required String userId,
  required DateTime weekStartDate,
  List<PlannedMeal>? meals,
}) {
  final now = DateTime.now();
  return MealPlan(
    userId: userId,
    weekStartDate: weekStartDate,
    meals: meals ?? [],
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MealPlanService service;
  late MealPlanProvider provider;

  const userId = 'user1';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = MealPlanService(firestore: fakeFirestore);
    provider = MealPlanProvider(service: service);
  });

  group('MealPlanProvider', () {
    test('initial state', () {
      expect(provider.currentPlan, isNull);
      expect(provider.isLoading, isFalse);
    });

    test('selectedWeekStart is a Monday', () {
      final weekStart = provider.selectedWeekStart;
      // DateTime.weekday: Monday=1
      expect(weekStart.weekday, DateTime.monday);
    });

    group('init', () {
      test('sets up stream subscription', () async {
        provider.init(userId);
        await Future.delayed(Duration.zero);

        // No plan created yet, so currentPlan should be null
        expect(provider.currentPlan, isNull);
      });

      test('does not re-subscribe for same user', () async {
        provider.init(userId);
        provider.init(userId); // should be no-op
        await Future.delayed(Duration.zero);

        expect(provider.currentPlan, isNull);
      });

      test('picks up existing plan from Firestore', () async {
        // Pre-populate a meal plan via the service (ensures proper normalization)
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [_makeMeal(recipeName: 'Pre-existing Meal')],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        expect(provider.currentPlan, isNotNull);
        expect(provider.currentPlan!.meals.length, 1);
        expect(provider.currentPlan!.meals.first.recipeName,
            'Pre-existing Meal');
      });
    });

    group('navigateWeek', () {
      test('navigating forward changes selectedWeekStart by +7 days', () {
        provider.init(userId);
        final original = provider.selectedWeekStart;

        provider.navigateWeek(1);

        expect(
          provider.selectedWeekStart,
          original.add(const Duration(days: 7)),
        );
      });

      test('navigating backward changes selectedWeekStart by -7 days', () {
        provider.init(userId);
        final original = provider.selectedWeekStart;

        provider.navigateWeek(-1);

        expect(
          provider.selectedWeekStart,
          original.subtract(const Duration(days: 7)),
        );
      });

      test('navigating multiple times accumulates correctly', () {
        provider.init(userId);
        final original = provider.selectedWeekStart;

        provider.navigateWeek(1);
        provider.navigateWeek(1);
        provider.navigateWeek(-1);

        expect(
          provider.selectedWeekStart,
          original.add(const Duration(days: 7)),
        );
      });

      test('navigateWeek notifies listeners', () {
        provider.init(userId);

        int notifyCount = 0;
        provider.addListener(() => notifyCount++);

        provider.navigateWeek(1);
        expect(notifyCount, greaterThanOrEqualTo(1));
      });

      test('navigateWeek resets currentPlan for new week', () async {
        // Set up plan for current week via service
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [_makeMeal(recipeName: 'ThisWeek')],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        expect(provider.currentPlan, isNotNull);

        // Navigate to next week (no plan there)
        provider.navigateWeek(1);
        await Future.delayed(Duration.zero);

        expect(provider.currentPlan, isNull);
      });
    });

    group('addMeal', () {
      test('creates new plan when no current plan exists', () async {
        provider.init(userId);
        await Future.delayed(Duration.zero);

        expect(provider.currentPlan, isNull);

        await provider.addMeal(userId, _makeMeal(recipeName: 'New Meal'));
        await Future.delayed(Duration.zero);

        // The stream should pick up the new plan
        expect(provider.currentPlan, isNotNull);
        expect(provider.currentPlan!.meals.length, 1);
        expect(
            provider.currentPlan!.meals.first.recipeName, 'New Meal');
      });

      test('adds meal to existing plan via service', () async {
        // Pre-create a plan via the service
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [_makeMeal(recipeName: 'Existing')],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        expect(provider.currentPlan!.meals.length, 1);

        await provider.addMeal(
            userId, _makeMeal(recipeName: 'Added', recipeId: 'r_added'));
        await Future.delayed(Duration.zero);

        expect(provider.currentPlan!.meals.length, 2);
      });
    });

    group('removeMeal', () {
      test('removes meal from current plan via service', () async {
        final meal = _makeMeal(
            day: 0, mealType: 'breakfast', recipeName: 'ToRemove');
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [meal],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        expect(provider.currentPlan!.meals.length, 1);

        await provider.removeMeal(userId, meal);
        await Future.delayed(Duration.zero);

        expect(provider.currentPlan!.meals, isEmpty);
      });

      test('does nothing when currentPlan is null', () async {
        provider.init(userId);
        await Future.delayed(Duration.zero);

        // Should not throw
        await provider.removeMeal(userId, _makeMeal());
      });

      test('does nothing when currentPlan has no id', () async {
        provider.init(userId);
        await Future.delayed(Duration.zero);

        // currentPlan is null, so this is a no-op
        await provider.removeMeal(userId, _makeMeal());
        expect(provider.currentPlan, isNull);
      });
    });

    group('getMealsForDay', () {
      test('returns meals only for the specified day', () async {
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [
            _makeMeal(day: 0, recipeName: 'Mon Breakfast'),
            _makeMeal(day: 0, recipeName: 'Mon Lunch', mealType: 'lunch'),
            _makeMeal(day: 1, recipeName: 'Tue Breakfast'),
            _makeMeal(day: 3, recipeName: 'Thu Dinner', mealType: 'dinner'),
          ],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        final mondayMeals = provider.getMealsForDay(0);
        expect(mondayMeals.length, 2);
        expect(
            mondayMeals.map((m) => m.recipeName),
            containsAll(['Mon Breakfast', 'Mon Lunch']));

        final tuesdayMeals = provider.getMealsForDay(1);
        expect(tuesdayMeals.length, 1);
        expect(tuesdayMeals.first.recipeName, 'Tue Breakfast');

        final wednesdayMeals = provider.getMealsForDay(2);
        expect(wednesdayMeals, isEmpty);

        final thursdayMeals = provider.getMealsForDay(3);
        expect(thursdayMeals.length, 1);
      });

      test('returns empty list when no current plan', () {
        expect(provider.getMealsForDay(0), isEmpty);
      });

      test('returns empty list for a day with no meals', () async {
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [_makeMeal(day: 0, recipeName: 'Monday Only')],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        expect(provider.getMealsForDay(6), isEmpty);
      });
    });

    group('getMealsForSlot', () {
      test('filters by both day AND mealType', () async {
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [
            _makeMeal(
                day: 0,
                mealType: 'breakfast',
                recipeName: 'Mon Breakfast'),
            _makeMeal(
                day: 0, mealType: 'lunch', recipeName: 'Mon Lunch'),
            _makeMeal(
                day: 0,
                mealType: 'breakfast',
                recipeName: 'Mon Breakfast 2',
                recipeId: 'r_extra'),
            _makeMeal(
                day: 1,
                mealType: 'breakfast',
                recipeName: 'Tue Breakfast'),
          ],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        final mondayBreakfast = provider.getMealsForSlot(0, 'breakfast');
        expect(mondayBreakfast.length, 2);

        final mondayLunch = provider.getMealsForSlot(0, 'lunch');
        expect(mondayLunch.length, 1);
        expect(mondayLunch.first.recipeName, 'Mon Lunch');

        final mondayDinner = provider.getMealsForSlot(0, 'dinner');
        expect(mondayDinner, isEmpty);

        final tuesdayBreakfast = provider.getMealsForSlot(1, 'breakfast');
        expect(tuesdayBreakfast.length, 1);
      });

      test('returns empty list when no current plan', () {
        expect(provider.getMealsForSlot(0, 'breakfast'), isEmpty);
      });
    });

    group('copyFromLastWeek', () {
      test('delegates to service.copyFromPreviousWeek', () async {
        // Create a plan for previous week via the service
        final currentWeekStart = provider.selectedWeekStart;
        final prevWeekStart =
            currentWeekStart.subtract(const Duration(days: 7));

        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: prevWeekStart,
          meals: [_makeMeal(recipeName: 'Copied Meal')],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        expect(provider.currentPlan, isNull);

        await provider.copyFromLastWeek(userId);
        await Future.delayed(Duration.zero);

        // The stream should pick up the copied plan
        expect(provider.currentPlan, isNotNull);
        expect(provider.currentPlan!.meals.length, 1);
        expect(
            provider.currentPlan!.meals.first.recipeName, 'Copied Meal');
      });

      test('does nothing when no previous week plan exists', () async {
        provider.init(userId);
        await Future.delayed(Duration.zero);

        await provider.copyFromLastWeek(userId);
        await Future.delayed(Duration.zero);

        expect(provider.currentPlan, isNull);
      });
    });

    group('generateShoppingList', () {
      test('returns empty map when no current plan', () {
        expect(provider.generateShoppingList(), isEmpty);
      });

      test('aggregates recipe names with servings', () async {
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [
            _makeMeal(recipeName: 'Chicken Salad', servings: 2),
            _makeMeal(
                day: 1,
                recipeName: 'Chicken Salad',
                servings: 1,
                mealType: 'lunch'),
            _makeMeal(
                day: 2,
                recipeName: 'Pasta',
                servings: 3,
                mealType: 'dinner'),
          ],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        final shopping = provider.generateShoppingList();

        expect(shopping['Chicken Salad'], 3.0); // 2 + 1
        expect(shopping['Pasta'], 3.0);
        expect(shopping.length, 2);
      });

      test('handles single meal correctly', () async {
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [_makeMeal(recipeName: 'Solo Meal', servings: 4)],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        final shopping = provider.generateShoppingList();
        expect(shopping['Solo Meal'], 4.0);
        expect(shopping.length, 1);
      });
    });

    group('getWeeklyNutrition', () {
      test('returns zeros when no current plan', () {
        final result = provider.getWeeklyNutrition([]);
        expect(result['totalCalories'], 0.0);
        expect(result['protein'], 0.0);
        expect(result['carbs'], 0.0);
        expect(result['fat'], 0.0);
      });

      test('calculates nutrition from matching recipes', () async {
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [
            _makeMeal(recipeId: 'r1', servings: 2),
            _makeMeal(
                day: 1,
                recipeId: 'r2',
                servings: 1,
                mealType: 'lunch'),
          ],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        final recipes = [
          createTestRecipe(
            id: 'r1',
            caloriesPerServing: 400,
            proteinGrams: 30.0,
            carbsGrams: 40.0,
            fatGrams: 15.0,
          ),
          createTestRecipe(
            id: 'r2',
            caloriesPerServing: 600,
            proteinGrams: 45.0,
            carbsGrams: 50.0,
            fatGrams: 20.0,
          ),
        ];

        final nutrition = provider.getWeeklyNutrition(recipes);

        // r1: 400*2=800 cal, 30*2=60 protein, 40*2=80 carbs, 15*2=30 fat
        // r2: 600*1=600 cal, 45*1=45 protein, 50*1=50 carbs, 20*1=20 fat
        expect(nutrition['totalCalories'], 1400.0);
        expect(nutrition['protein'], 105.0);
        expect(nutrition['carbs'], 130.0);
        expect(nutrition['fat'], 50.0);
      });

      test('skips meals with no matching recipe', () async {
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [
            _makeMeal(recipeId: 'r1', servings: 1),
            _makeMeal(
                day: 1,
                recipeId: 'r_unknown',
                servings: 1,
                mealType: 'lunch'),
          ],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        final recipes = [
          createTestRecipe(
            id: 'r1',
            caloriesPerServing: 500,
            proteinGrams: 40.0,
            carbsGrams: 60.0,
            fatGrams: 10.0,
          ),
        ];

        final nutrition = provider.getWeeklyNutrition(recipes);

        // Only r1 counted, r_unknown skipped
        expect(nutrition['totalCalories'], 500.0);
        expect(nutrition['protein'], 40.0);
        expect(nutrition['carbs'], 60.0);
        expect(nutrition['fat'], 10.0);
      });

      test('handles recipes with null nutrition values', () async {
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [_makeMeal(recipeId: 'r_null', servings: 2)],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        // Build a recipe directly to ensure null nutrition fields
        final recipes = [
          Recipe(
            id: 'r_null',
            title: 'No Nutrition',
            description: 'No nutrition data',
            authorId: 'a1',
            authorName: 'Chef',
            category: 'Cat',
            servings: 1,
            prepTimeMinutes: 5,
            cookTimeMinutes: 5,
            ingredients: [],
            steps: [],
            caloriesPerServing: null,
            proteinGrams: null,
            carbsGrams: null,
            fatGrams: null,
            createdAt: DateTime.now(),
          ),
        ];

        final nutrition = provider.getWeeklyNutrition(recipes);

        expect(nutrition['totalCalories'], 0.0);
        expect(nutrition['protein'], 0.0);
        expect(nutrition['carbs'], 0.0);
        expect(nutrition['fat'], 0.0);
      });
    });

    group('getWeeklyNutrition — additional cases', () {
      test('returns zeros when current plan has empty meals', () async {
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        final recipes = [
          createTestRecipe(
            id: 'r1',
            caloriesPerServing: 500,
            proteinGrams: 40.0,
            carbsGrams: 60.0,
            fatGrams: 10.0,
          ),
        ];

        final nutrition = provider.getWeeklyNutrition(recipes);
        expect(nutrition['totalCalories'], 0.0);
        expect(nutrition['protein'], 0.0);
        expect(nutrition['carbs'], 0.0);
        expect(nutrition['fat'], 0.0);
      });

      test('handles recipes with null id gracefully', () async {
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [_makeMeal(recipeId: 'r1', servings: 1)],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        // Recipe with null id should not match any planned meal
        final recipes = [
          createTestRecipe(
            id: null,
            caloriesPerServing: 999,
          ),
        ];

        final nutrition = provider.getWeeklyNutrition(recipes);
        expect(nutrition['totalCalories'], 0.0);
      });
    });

    group('generateShoppingList — additional cases', () {
      test('handles plan with empty meals list', () async {
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        expect(provider.generateShoppingList(), isEmpty);
      });

      test('each unique recipe name is a separate key', () async {
        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [
            _makeMeal(recipeName: 'A', servings: 1, recipeId: 'r1'),
            _makeMeal(
                day: 1,
                recipeName: 'B',
                servings: 2,
                recipeId: 'r2',
                mealType: 'lunch'),
            _makeMeal(
                day: 2,
                recipeName: 'C',
                servings: 3,
                recipeId: 'r3',
                mealType: 'dinner'),
          ],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        final shopping = provider.generateShoppingList();
        expect(shopping.length, 3);
        expect(shopping['A'], 1.0);
        expect(shopping['B'], 2.0);
        expect(shopping['C'], 3.0);
      });
    });

    group('isLoading behavior', () {
      test('isLoading is false initially', () {
        expect(provider.isLoading, isFalse);
      });

      test('isLoading becomes false after stream emits', () async {
        provider.init(userId);
        await Future.delayed(Duration.zero);

        expect(provider.isLoading, isFalse);
      });
    });

    group('listener notifications', () {
      test('stream emission notifies listeners', () async {
        int notifyCount = 0;
        provider.addListener(() => notifyCount++);

        final weekStart = provider.selectedWeekStart;
        await service.createMealPlan(_makePlan(
          userId: userId,
          weekStartDate: weekStart,
          meals: [_makeMeal(recipeName: 'Trigger')],
        ));

        provider.init(userId);
        await Future.delayed(Duration.zero);

        expect(notifyCount, greaterThanOrEqualTo(1));
      });
    });

    group('dispose', () {
      test('cancels stream subscription without error', () async {
        provider.init(userId);
        await Future.delayed(Duration.zero);

        // Should not throw
        provider.dispose();
      });

      test('dispose without init does not throw', () {
        // Should not throw
        provider.dispose();
      });
    });
  });
}
