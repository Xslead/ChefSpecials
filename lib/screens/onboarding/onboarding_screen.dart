import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final List<bool> _pageVisible = [true, false, false, false];

  void _onPageChanged(int page) {
    setState(() {
      for (int i = 0; i < _pageVisible.length; i++) {
        _pageVisible[i] = i == page;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: back + skip
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 16, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (visible on pages 1-3)
                  AnimatedOpacity(
                    opacity: provider.currentPage > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                      onPressed: provider.currentPage > 0
                          ? () => provider.previousPage()
                          : null,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  // Skip button (visible on pages 2-3)
                  AnimatedOpacity(
                    opacity: provider.currentPage >= 2 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: provider.currentPage >= 2
                          ? () async {
                              await provider.completeOnboarding();
                              if (context.mounted) context.go('/home');
                            }
                          : null,
                      child: Text(l10n.skip),
                    ),
                  ),
                ],
              ),
            ),
            // Page content
            Expanded(
              child: PageView(
                controller: provider.pageController,
                onPageChanged: (page) {
                  provider.onPageChanged(page);
                  _onPageChanged(page);
                },
                physics: const ClampingScrollPhysics(),
                children: [
                  _WelcomePage(visible: _pageVisible[0]),
                  _FeaturesPage(visible: _pageVisible[1]),
                  _DietaryPage(visible: _pageVisible[2]),
                  _NutritionGoalsPage(visible: _pageVisible[3]),
                ],
              ),
            ),
            // Dot indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isActive = provider.currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isActive
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withValues(alpha: 0.25),
                    ),
                  );
                }),
              ),
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (provider.isLastPage) {
                        await provider.completeOnboarding();
                        if (context.mounted) context.go('/home');
                      } else {
                        provider.nextPage();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                    ),
                    child: Text(
                      provider.isLastPage ? l10n.getStarted : l10n.next,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final bool visible;
  const _WelcomePage({required this.visible});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'assets/animations/cooking.json',
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.welcomeToChefSpecials,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.discoverCookShare,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondaryOf(context),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturesPage extends StatelessWidget {
  final bool visible;
  const _FeaturesPage({required this.visible});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FeatureRow(
              icon: Icons.restaurant_outlined,
              title: l10n.trackYourNutrition,
              subtitle: l10n.logMealsMonitor,
            ),
            const SizedBox(height: 24),
            _FeatureRow(
              icon: Icons.calendar_month_outlined,
              title: l10n.planYourMeals,
              subtitle: l10n.organizeWeeklyMealPlan,
            ),
            const SizedBox(height: 24),
            _FeatureRow(
              icon: Icons.share_outlined,
              title: l10n.shareRecipes,
              subtitle: l10n.connectWithFoodLovers,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryOf(context),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DietaryPage extends StatelessWidget {
  final bool visible;
  const _DietaryPage({required this.visible});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<OnboardingProvider>();
    final preferences = [
      (l10n.vegan, 'Vegan'),
      (l10n.vegetarian, 'Vegetarian'),
      (l10n.glutenFree, 'Gluten Free'),
      (l10n.keto, 'Keto'),
      (l10n.halal, 'Halal'),
      (l10n.dairyFree, 'Dairy Free'),
      (l10n.nutFree, 'Nut-Free'),
      (l10n.lowCarb, 'Low Carb'),
    ];

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.selectDietaryPreferences,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: preferences.map((pref) {
                final isSelected = provider.selectedDietaryPreferences
                    .contains(pref.$2);
                return FilterChip(
                  label: Text(pref.$1),
                  selected: isSelected,
                  onSelected: (_) =>
                      provider.toggleDietaryPreference(pref.$2),
                  selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                  checkmarkColor: AppTheme.primaryColor,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionGoalsPage extends StatelessWidget {
  final bool visible;
  const _NutritionGoalsPage({required this.visible});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<OnboardingProvider>();

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.setDailyGoals,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            _GoalSlider(
              label: l10n.calories,
              value: provider.calorieTarget,
              min: 1000,
              max: 4000,
              unit: l10n.kcal,
              onChanged: provider.setCalorieTarget,
            ),
            const SizedBox(height: 24),
            _GoalSlider(
              label: l10n.protein,
              value: provider.proteinTarget,
              min: 30,
              max: 300,
              unit: l10n.gram,
              onChanged: provider.setProteinTarget,
            ),
            const SizedBox(height: 24),
            _GoalSlider(
              label: l10n.carbs,
              value: provider.carbsTarget,
              min: 50,
              max: 500,
              unit: l10n.gram,
              onChanged: provider.setCarbsTarget,
            ),
            const SizedBox(height: 24),
            _GoalSlider(
              label: l10n.fat,
              value: provider.fatTarget,
              min: 20,
              max: 200,
              unit: l10n.gram,
              onChanged: provider.setFatTarget,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _GoalSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  const _GoalSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '${value.round()} $unit',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 10).round(),
          activeColor: AppTheme.primaryColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
