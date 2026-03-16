import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/services/daily_tracker_service.dart';
import 'package:chef_specials/models/daily_log.dart';
import 'package:chef_specials/models/meal_entry.dart';
import 'package:chef_specials/models/nutrition_goal.dart';

DailyLog _makeLog({
  String userId = 'user1',
  String date = '2024-01-15',
  List<MealEntry>? meals,
  int waterMl = 0,
}) {
  return DailyLog(
    userId: userId,
    date: date,
    meals: meals ?? [],
    waterMl: waterMl,
  );
}

MealEntry _makeMealEntry({
  String name = 'Chicken Breast',
  MealType mealType = MealType.lunch,
  double quantity = 200,
  double calories = 330,
  double protein = 62,
  double carbs = 0,
  double fat = 7.2,
}) {
  return MealEntry(
    name: name,
    mealType: mealType,
    quantity: quantity,
    unit: 'g',
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late DailyTrackerService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = DailyTrackerService(firestore: fakeFirestore);
  });

  group('DailyTrackerService', () {
    group('createDailyLog', () {
      test('should create a daily log and return its ID', () async {
        final log = _makeLog(userId: 'user1', date: '2024-01-15');
        final id = await service.createDailyLog(log);

        expect(id, isNotEmpty);

        final doc =
            await fakeFirestore.collection('daily_logs').doc(id).get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['userId'], 'user1');
        expect(doc.data()!['date'], '2024-01-15');
      });

      test('should store meals correctly', () async {
        final log = _makeLog(meals: [
          _makeMealEntry(name: 'Eggs', mealType: MealType.breakfast),
          _makeMealEntry(name: 'Rice', mealType: MealType.lunch),
        ]);
        final id = await service.createDailyLog(log);

        final doc =
            await fakeFirestore.collection('daily_logs').doc(id).get();
        final meals = doc.data()!['meals'] as List;
        expect(meals.length, 2);
      });
    });

    group('getDailyLog', () {
      test('should return a daily log matching userId and date', () async {
        await service.createDailyLog(
            _makeLog(userId: 'user1', date: '2024-01-15', waterMl: 1500));

        final log = await service.getDailyLog('user1', '2024-01-15').first;

        expect(log, isNotNull);
        expect(log!.userId, 'user1');
        expect(log.date, '2024-01-15');
        expect(log.waterMl, 1500);
      });

      test('should return null when no log exists for the date', () async {
        final log = await service.getDailyLog('user1', '2024-01-15').first;
        expect(log, isNull);
      });

      test('should not return logs for a different user', () async {
        await service
            .createDailyLog(_makeLog(userId: 'user2', date: '2024-01-15'));

        final log = await service.getDailyLog('user1', '2024-01-15').first;
        expect(log, isNull);
      });

      test('should not return logs for a different date', () async {
        await service
            .createDailyLog(_makeLog(userId: 'user1', date: '2024-01-16'));

        final log = await service.getDailyLog('user1', '2024-01-15').first;
        expect(log, isNull);
      });
    });

    group('updateDailyLog', () {
      test('should update an existing daily log', () async {
        final id = await service.createDailyLog(
            _makeLog(userId: 'user1', date: '2024-01-15', waterMl: 500));

        final updatedLog = _makeLog(
          userId: 'user1',
          date: '2024-01-15',
          waterMl: 2000,
          meals: [_makeMealEntry()],
        );

        await service.updateDailyLog(id, updatedLog);

        final doc =
            await fakeFirestore.collection('daily_logs').doc(id).get();
        expect(doc.data()!['waterMl'], 2000);
        expect((doc.data()!['meals'] as List).length, 1);
      });
    });

    group('getNutritionGoal', () {
      test('should return nutrition goal for a user', () async {
        final goal = NutritionGoal(
          userId: 'user1',
          calorieTarget: 2500,
          proteinTarget: 120,
          carbsTarget: 300,
          fatTarget: 80,
          waterTargetMl: 3000,
        );
        await service.setNutritionGoal(goal);

        final result = await service.getNutritionGoal('user1').first;

        expect(result, isNotNull);
        expect(result!.userId, 'user1');
        expect(result.calorieTarget, 2500);
        expect(result.proteinTarget, 120);
        expect(result.carbsTarget, 300);
        expect(result.fatTarget, 80);
        expect(result.waterTargetMl, 3000);
      });

      test('should return null when no goal exists', () async {
        final result = await service.getNutritionGoal('user1').first;
        expect(result, isNull);
      });
    });

    group('setNutritionGoal', () {
      test('should create a nutrition goal with userId as document ID',
          () async {
        final goal = NutritionGoal(
          userId: 'user1',
          calorieTarget: 2000,
          proteinTarget: 50,
          carbsTarget: 250,
          fatTarget: 65,
        );
        await service.setNutritionGoal(goal);

        final doc = await fakeFirestore
            .collection('nutrition_goals')
            .doc('user1')
            .get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['calorieTarget'], 2000);
      });

      test('should overwrite an existing nutrition goal', () async {
        final goal1 = NutritionGoal(
          userId: 'user1',
          calorieTarget: 2000,
          proteinTarget: 50,
          carbsTarget: 250,
          fatTarget: 65,
        );
        await service.setNutritionGoal(goal1);

        final goal2 = NutritionGoal(
          userId: 'user1',
          calorieTarget: 3000,
          proteinTarget: 150,
          carbsTarget: 350,
          fatTarget: 100,
        );
        await service.setNutritionGoal(goal2);

        final result = await service.getNutritionGoal('user1').first;
        expect(result!.calorieTarget, 3000);
        expect(result.proteinTarget, 150);
      });
    });
  });
}
