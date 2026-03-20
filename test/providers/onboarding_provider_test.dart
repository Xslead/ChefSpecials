import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chef_specials/providers/onboarding_provider.dart';

void main() {
  group('OnboardingProvider', () {
    late OnboardingProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      OnboardingProvider.resetCache();
      provider = OnboardingProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('initial state is correct', () {
      expect(provider.currentPage, 0);
      expect(provider.selectedDietaryPreferences, isEmpty);
      expect(provider.calorieTarget, 2000);
      expect(provider.proteinTarget, 50);
      expect(provider.carbsTarget, 250);
      expect(provider.fatTarget, 65);
      expect(provider.isLastPage, false);
    });

    test('onPageChanged updates currentPage', () {
      provider.onPageChanged(2);
      expect(provider.currentPage, 2);
    });

    test('isLastPage returns true on page 3', () {
      provider.onPageChanged(3);
      expect(provider.isLastPage, true);
    });

    test('toggleDietaryPreference adds and removes', () {
      provider.toggleDietaryPreference('Vegan');
      expect(provider.selectedDietaryPreferences, ['Vegan']);

      provider.toggleDietaryPreference('Keto');
      expect(provider.selectedDietaryPreferences, ['Vegan', 'Keto']);

      provider.toggleDietaryPreference('Vegan');
      expect(provider.selectedDietaryPreferences, ['Keto']);
    });

    test('setCalorieTarget updates value', () {
      provider.setCalorieTarget(2500);
      expect(provider.calorieTarget, 2500);
    });

    test('setProteinTarget updates value', () {
      provider.setProteinTarget(100);
      expect(provider.proteinTarget, 100);
    });

    test('setCarbsTarget updates value', () {
      provider.setCarbsTarget(300);
      expect(provider.carbsTarget, 300);
    });

    test('setFatTarget updates value', () {
      provider.setFatTarget(80);
      expect(provider.fatTarget, 80);
    });

    test('completeOnboarding saves hasCompletedOnboarding', () async {
      await provider.completeOnboarding();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('hasCompletedOnboarding'), true);
    });

    test('completeOnboarding saves dietary preferences when non-empty',
        () async {
      provider.toggleDietaryPreference('Vegan');
      provider.toggleDietaryPreference('Halal');
      await provider.completeOnboarding();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('pendingDietaryPreferences'),
          ['Vegan', 'Halal']);
    });

    test('completeOnboarding does not save dietary preferences when empty',
        () async {
      await provider.completeOnboarding();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('pendingDietaryPreferences'), isNull);
    });

    test('completeOnboarding saves nutrition goals when non-default', () async {
      provider.setCalorieTarget(2500);
      await provider.completeOnboarding();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('pendingCalorieTarget'), 2500);
      expect(prefs.getDouble('pendingProteinTarget'), 50);
      expect(prefs.getDouble('pendingCarbsTarget'), 250);
      expect(prefs.getDouble('pendingFatTarget'), 65);
    });

    test('completeOnboarding does not save nutrition goals when all default',
        () async {
      await provider.completeOnboarding();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('pendingCalorieTarget'), isNull);
    });

    test('hasCompletedOnboarding returns false by default', () async {
      expect(await OnboardingProvider.hasCompletedOnboarding(), false);
    });

    test('hasCompletedOnboarding returns true after completing', () async {
      await provider.completeOnboarding();
      expect(await OnboardingProvider.hasCompletedOnboarding(), true);
    });

    test('selectedDietaryPreferences returns unmodifiable list', () {
      provider.toggleDietaryPreference('Vegan');
      expect(
        () => provider.selectedDietaryPreferences.add('Keto'),
        throwsUnsupportedError,
      );
    });
  });
}
