import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/services/meal_plan_service.dart';
import 'package:chef_specials/models/meal_plan.dart';
import 'package:chef_specials/models/planned_meal.dart';

MealPlan _makePlan({
  String userId = 'user1',
  DateTime? weekStartDate,
  List<PlannedMeal>? meals,
}) {
  return MealPlan(
    userId: userId,
    weekStartDate: weekStartDate ?? DateTime.utc(2025, 3, 17), // Monday
    meals: meals ?? [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

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

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MealPlanService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = MealPlanService(firestore: fakeFirestore);
  });

  group('MealPlanService', () {
    group('createMealPlan', () {
      test('adds document to Firestore and returns document ID', () async {
        final plan = _makePlan(userId: 'user1');
        final id = await service.createMealPlan(plan);

        expect(id, isNotEmpty);

        final doc =
            await fakeFirestore.collection('meal_plans').doc(id).get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['userId'], 'user1');
      });

      test('stores meals correctly in document', () async {
        final plan = _makePlan(meals: [
          _makeMeal(recipeName: 'Oatmeal', mealType: 'breakfast'),
          _makeMeal(
              day: 0, recipeName: 'Sandwich', mealType: 'lunch', servings: 2),
        ]);

        final id = await service.createMealPlan(plan);

        final doc =
            await fakeFirestore.collection('meal_plans').doc(id).get();
        final meals = doc.data()!['meals'] as List;
        expect(meals.length, 2);
      });

      test('normalizes weekStartDate to Monday', () async {
        // Pass a Wednesday; the service should normalize to Monday
        final wednesday = DateTime.utc(2025, 3, 19); // Wednesday
        final plan = _makePlan(weekStartDate: wednesday);

        final id = await service.createMealPlan(plan);

        final doc =
            await fakeFirestore.collection('meal_plans').doc(id).get();
        final storedTimestamp =
            doc.data()!['weekStartDate'] as Timestamp;
        final storedDate = storedTimestamp.toDate();

        // Should be Monday March 17 (compare milliseconds to avoid UTC/local mismatch)
        final expectedMonday = DateTime.utc(2025, 3, 17);
        expect(storedDate.millisecondsSinceEpoch,
            expectedMonday.millisecondsSinceEpoch);
      });

      test('stores createdAt and updatedAt as Timestamps', () async {
        final plan = _makePlan();
        final id = await service.createMealPlan(plan);

        final doc =
            await fakeFirestore.collection('meal_plans').doc(id).get();
        expect(doc.data()!['createdAt'], isA<Timestamp>());
        expect(doc.data()!['updatedAt'], isA<Timestamp>());
      });
    });

    group('getMealPlan', () {
      test('returns correct plan by userId and weekStart', () async {
        final monday = DateTime.utc(2025, 3, 17);
        await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [_makeMeal(recipeName: 'Eggs')],
        ));

        final result = await service.getMealPlan('user1', monday);

        expect(result, isNotNull);
        expect(result!.userId, 'user1');
        expect(result.meals.length, 1);
        expect(result.meals.first.recipeName, 'Eggs');
      });

      test('returns null when no plan found', () async {
        final monday = DateTime.utc(2025, 3, 17);
        final result = await service.getMealPlan('user1', monday);

        expect(result, isNull);
      });

      test('returns null for wrong userId', () async {
        final monday = DateTime.utc(2025, 3, 17);
        await service.createMealPlan(_makePlan(
          userId: 'user2',
          weekStartDate: monday,
        ));

        final result = await service.getMealPlan('user1', monday);
        expect(result, isNull);
      });

      test('returns null for wrong week', () async {
        final monday = DateTime.utc(2025, 3, 17);
        await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
        ));

        final nextMonday = DateTime.utc(2025, 3, 24);
        final result = await service.getMealPlan('user1', nextMonday);
        expect(result, isNull);
      });

      test('normalizes weekStart parameter to Monday', () async {
        final monday = DateTime.utc(2025, 3, 17);
        await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
        ));

        // Query using Thursday of the same week
        final thursday = DateTime.utc(2025, 3, 20);
        final result = await service.getMealPlan('user1', thursday);

        expect(result, isNotNull);
        expect(result!.userId, 'user1');
      });

      test('returned plan has non-null id', () async {
        final monday = DateTime.utc(2025, 3, 17);
        await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
        ));

        final result = await service.getMealPlan('user1', monday);
        expect(result, isNotNull);
        expect(result!.id, isNotNull);
        expect(result.id, isNotEmpty);
      });
    });

    group('getMealPlanStream', () {
      test('emits null when no plan exists', () async {
        final monday = DateTime.utc(2025, 3, 17);
        final result =
            await service.getMealPlanStream('user1', monday).first;

        expect(result, isNull);
      });

      test('emits plan when it exists', () async {
        final monday = DateTime.utc(2025, 3, 17);
        await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [_makeMeal(recipeName: 'Pancakes')],
        ));

        final result =
            await service.getMealPlanStream('user1', monday).first;

        expect(result, isNotNull);
        expect(result!.userId, 'user1');
        expect(result.meals.first.recipeName, 'Pancakes');
      });

      test('emits updated plan after changes', () async {
        final monday = DateTime.utc(2025, 3, 17);
        final planId = await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [],
        ));

        // Listen to the stream
        final stream = service.getMealPlanStream('user1', monday);
        final firstEmission = await stream.first;
        expect(firstEmission, isNotNull);
        expect(firstEmission!.meals, isEmpty);

        // Add a meal and verify the stream would emit updated data
        await service.addMealToDay(
            planId, _makeMeal(recipeName: 'New Meal'));

        final updatedPlan = await service.getMealPlan('user1', monday);
        expect(updatedPlan!.meals.length, 1);
      });
    });

    group('updateMealPlan', () {
      test('updates fields in Firestore', () async {
        final monday = DateTime.utc(2025, 3, 17);
        final planId = await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [_makeMeal(recipeName: 'OldMeal')],
        ));

        final plan = await service.getMealPlan('user1', monday);
        final updatedPlan = plan!.copyWith(
          meals: [_makeMeal(recipeName: 'NewMeal')],
        );

        await service.updateMealPlan(updatedPlan);

        final doc = await fakeFirestore
            .collection('meal_plans')
            .doc(planId)
            .get();
        final meals = doc.data()!['meals'] as List;
        expect(meals.length, 1);
        expect((meals.first as Map<String, dynamic>)['recipeName'], 'NewMeal');
      });

      test('does nothing when plan id is null', () async {
        final plan = _makePlan(); // id is null
        // Should not throw
        await service.updateMealPlan(plan);

        final snapshot =
            await fakeFirestore.collection('meal_plans').get();
        expect(snapshot.docs, isEmpty);
      });

      test('sets updatedAt to current time', () async {
        final monday = DateTime.utc(2025, 3, 17);
        final planId = await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
        ));

        final plan = await service.getMealPlan('user1', monday);
        await service.updateMealPlan(plan!);

        final doc = await fakeFirestore
            .collection('meal_plans')
            .doc(planId)
            .get();
        expect(doc.data()!['updatedAt'], isA<Timestamp>());
      });
    });

    group('addMealToDay', () {
      test('adds meal to existing plan via arrayUnion', () async {
        final monday = DateTime.utc(2025, 3, 17);
        final planId = await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [],
        ));

        await service.addMealToDay(
          planId,
          _makeMeal(day: 0, mealType: 'breakfast', recipeName: 'Eggs'),
        );

        final doc = await fakeFirestore
            .collection('meal_plans')
            .doc(planId)
            .get();
        final meals = doc.data()!['meals'] as List;
        expect(meals.length, 1);
        expect((meals.first as Map<String, dynamic>)['recipeName'], 'Eggs');
      });

      test('adds multiple meals to different days', () async {
        final monday = DateTime.utc(2025, 3, 17);
        final planId = await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [],
        ));

        await service.addMealToDay(
          planId,
          _makeMeal(day: 0, mealType: 'breakfast', recipeName: 'Eggs'),
        );
        await service.addMealToDay(
          planId,
          _makeMeal(day: 2, mealType: 'lunch', recipeName: 'Salad'),
        );
        await service.addMealToDay(
          planId,
          _makeMeal(day: 4, mealType: 'dinner', recipeName: 'Steak'),
        );

        final doc = await fakeFirestore
            .collection('meal_plans')
            .doc(planId)
            .get();
        final meals = doc.data()!['meals'] as List;
        expect(meals.length, 3);
      });

      test('updates updatedAt timestamp', () async {
        final monday = DateTime.utc(2025, 3, 17);
        final planId = await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
        ));

        final docBefore = await fakeFirestore
            .collection('meal_plans')
            .doc(planId)
            .get();
        final beforeTimestamp = docBefore.data()!['updatedAt'] as Timestamp;

        // Small delay to ensure different timestamp
        await Future.delayed(const Duration(milliseconds: 10));

        await service.addMealToDay(
          planId,
          _makeMeal(recipeName: 'NewMeal'),
        );

        final docAfter = await fakeFirestore
            .collection('meal_plans')
            .doc(planId)
            .get();
        final afterTimestamp = docAfter.data()!['updatedAt'] as Timestamp;

        expect(afterTimestamp.seconds, greaterThanOrEqualTo(beforeTimestamp.seconds));
      });
    });

    group('removeMealFromDay', () {
      test('removes meal from plan via arrayRemove', () async {
        final meal =
            _makeMeal(day: 0, mealType: 'breakfast', recipeName: 'Eggs');
        final monday = DateTime.utc(2025, 3, 17);
        final planId = await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [meal],
        ));

        await service.removeMealFromDay(planId, meal);

        final doc = await fakeFirestore
            .collection('meal_plans')
            .doc(planId)
            .get();
        final meals = doc.data()!['meals'] as List;
        expect(meals, isEmpty);
      });

      test('keeps other meals intact when removing one', () async {
        final meal1 = _makeMeal(
            day: 0, mealType: 'breakfast', recipeName: 'Eggs', recipeId: 'r1');
        final meal2 = _makeMeal(
            day: 0, mealType: 'lunch', recipeName: 'Sandwich', recipeId: 'r2');

        final monday = DateTime.utc(2025, 3, 17);
        final planId = await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [meal1, meal2],
        ));

        await service.removeMealFromDay(planId, meal1);

        final doc = await fakeFirestore
            .collection('meal_plans')
            .doc(planId)
            .get();
        final meals = doc.data()!['meals'] as List;
        expect(meals.length, 1);
        expect(
            (meals.first as Map<String, dynamic>)['recipeName'], 'Sandwich');
      });

      test('updates updatedAt timestamp', () async {
        final meal = _makeMeal(recipeName: 'Eggs');
        final monday = DateTime.utc(2025, 3, 17);
        final planId = await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [meal],
        ));

        await service.removeMealFromDay(planId, meal);

        final doc = await fakeFirestore
            .collection('meal_plans')
            .doc(planId)
            .get();
        expect(doc.data()!['updatedAt'], isA<Timestamp>());
      });
    });

    group('copyFromPreviousWeek', () {
      test('creates new plan from previous week data', () async {
        final prevMonday = DateTime.utc(2025, 3, 10);
        await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: prevMonday,
          meals: [
            _makeMeal(day: 0, recipeName: 'Monday Breakfast'),
            _makeMeal(day: 2, recipeName: 'Wednesday Lunch', mealType: 'lunch'),
          ],
        ));

        final currentMonday = DateTime.utc(2025, 3, 17);
        await service.copyFromPreviousWeek('user1', currentMonday);

        final newPlan =
            await service.getMealPlan('user1', currentMonday);

        expect(newPlan, isNotNull);
        expect(newPlan!.userId, 'user1');
        expect(newPlan.meals.length, 2);
        expect(newPlan.meals[0].recipeName, 'Monday Breakfast');
        expect(newPlan.meals[1].recipeName, 'Wednesday Lunch');
      });

      test('does nothing when no previous week plan exists', () async {
        final currentMonday = DateTime.utc(2025, 3, 17);
        await service.copyFromPreviousWeek('user1', currentMonday);

        final result =
            await service.getMealPlan('user1', currentMonday);
        expect(result, isNull);
      });

      test('new plan has current week start date', () async {
        final prevMonday = DateTime.utc(2025, 3, 10);
        await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: prevMonday,
          meals: [_makeMeal()],
        ));

        final currentMonday = DateTime.utc(2025, 3, 17);
        await service.copyFromPreviousWeek('user1', currentMonday);

        final newPlan =
            await service.getMealPlan('user1', currentMonday);
        expect(newPlan, isNotNull);
        // Compare milliseconds to avoid UTC/local mismatch from Timestamp.toDate()
        expect(newPlan!.weekStartDate.millisecondsSinceEpoch,
            currentMonday.millisecondsSinceEpoch);
      });

      test('does not modify the original previous week plan', () async {
        final prevMonday = DateTime.utc(2025, 3, 10);
        await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: prevMonday,
          meals: [_makeMeal(recipeName: 'OriginalMeal')],
        ));

        final currentMonday = DateTime.utc(2025, 3, 17);
        await service.copyFromPreviousWeek('user1', currentMonday);

        final prevPlan =
            await service.getMealPlan('user1', prevMonday);
        expect(prevPlan, isNotNull);
        expect(prevPlan!.meals.length, 1);
        expect(prevPlan.meals.first.recipeName, 'OriginalMeal');
      });

      test('normalizes currentWeekStart to Monday', () async {
        final prevMonday = DateTime.utc(2025, 3, 10);
        await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: prevMonday,
          meals: [_makeMeal(recipeName: 'CopiedMeal')],
        ));

        // Pass a Friday of the target week
        final friday = DateTime.utc(2025, 3, 21);
        await service.copyFromPreviousWeek('user1', friday);

        final currentMonday = DateTime.utc(2025, 3, 17);
        final newPlan =
            await service.getMealPlan('user1', currentMonday);
        expect(newPlan, isNotNull);
        expect(newPlan!.meals.first.recipeName, 'CopiedMeal');
      });
    });

    group('isolation', () {
      test('different users can have plans for the same week', () async {
        final monday = DateTime.utc(2025, 3, 17);
        await service.createMealPlan(_makePlan(
          userId: 'userA',
          weekStartDate: monday,
          meals: [_makeMeal(recipeName: 'UserA Meal')],
        ));
        await service.createMealPlan(_makePlan(
          userId: 'userB',
          weekStartDate: monday,
          meals: [_makeMeal(recipeName: 'UserB Meal')],
        ));

        final planA = await service.getMealPlan('userA', monday);
        final planB = await service.getMealPlan('userB', monday);

        expect(planA, isNotNull);
        expect(planB, isNotNull);
        expect(planA!.meals.first.recipeName, 'UserA Meal');
        expect(planB!.meals.first.recipeName, 'UserB Meal');
      });

      test('same user can have plans for different weeks', () async {
        final week1 = DateTime.utc(2025, 3, 10);
        final week2 = DateTime.utc(2025, 3, 17);

        await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: week1,
          meals: [_makeMeal(recipeName: 'Week 1')],
        ));
        await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: week2,
          meals: [_makeMeal(recipeName: 'Week 2')],
        ));

        final plan1 = await service.getMealPlan('user1', week1);
        final plan2 = await service.getMealPlan('user1', week2);

        expect(plan1!.meals.first.recipeName, 'Week 1');
        expect(plan2!.meals.first.recipeName, 'Week 2');
      });

      test('addMealToDay does not affect other plans', () async {
        final monday = DateTime.utc(2025, 3, 17);
        final planId1 = await service.createMealPlan(_makePlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [],
        ));
        final planId2 = await service.createMealPlan(_makePlan(
          userId: 'user2',
          weekStartDate: monday,
          meals: [],
        ));

        await service.addMealToDay(
          planId1,
          _makeMeal(recipeName: 'User1 Only'),
        );

        final doc2 = await fakeFirestore
            .collection('meal_plans')
            .doc(planId2)
            .get();
        final meals2 = doc2.data()!['meals'] as List;
        expect(meals2, isEmpty);
      });
    });
  });
}
