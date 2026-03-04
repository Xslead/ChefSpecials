import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/nutrition_goal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/daily_tracker_provider.dart';

class NutritionGoalsScreen extends StatefulWidget {
  const NutritionGoalsScreen({super.key});

  @override
  State<NutritionGoalsScreen> createState() => _NutritionGoalsScreenState();
}

class _NutritionGoalsScreenState extends State<NutritionGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _calorieController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final goal = context.read<DailyTrackerProvider>().nutritionGoal;
    _calorieController = TextEditingController(
      text: (goal?.calorieTarget ?? 2000).toInt().toString(),
    );
    _proteinController = TextEditingController(
      text: (goal?.proteinTarget ?? 50).toInt().toString(),
    );
    _carbsController = TextEditingController(
      text: (goal?.carbsTarget ?? 250).toInt().toString(),
    );
    _fatController = TextEditingController(
      text: (goal?.fatTarget ?? 65).toInt().toString(),
    );
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _saveGoals() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final userId = context.read<AuthProvider>().userModel?.uid ?? '';
    final goal = NutritionGoal(
      userId: userId,
      calorieTarget: double.tryParse(_calorieController.text) ?? 2000,
      proteinTarget: double.tryParse(_proteinController.text) ?? 50,
      carbsTarget: double.tryParse(_carbsController.text) ?? 250,
      fatTarget: double.tryParse(_fatController.text) ?? 65,
    );

    await context.read<DailyTrackerProvider>().saveNutritionGoal(goal);

    if (mounted) {
      setState(() => _isSaving = false);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.goalsSaved),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      context.pop();
    }
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final number = double.tryParse(value);
    if (number == null || number <= 0) return 'Enter a valid number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nutritionGoals),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(
              Icons.track_changes,
              size: 64,
              color: AppTheme.primaryColor.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.nutritionGoals,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 32),
            _GoalTextField(
              controller: _calorieController,
              label: l10n.calorieTarget,
              suffix: l10n.kcal,
              icon: Icons.local_fire_department,
              color: AppTheme.primaryColor,
              validator: _validateNumber,
            ),
            const SizedBox(height: 16),
            _GoalTextField(
              controller: _proteinController,
              label: l10n.proteinTarget,
              suffix: l10n.gram,
              icon: Icons.fitness_center,
              color: AppTheme.secondaryColor,
              validator: _validateNumber,
            ),
            const SizedBox(height: 16),
            _GoalTextField(
              controller: _carbsController,
              label: l10n.carbsTarget,
              suffix: l10n.gram,
              icon: Icons.grain,
              color: const Color(0xFFF59E0B),
              validator: _validateNumber,
            ),
            const SizedBox(height: 16),
            _GoalTextField(
              controller: _fatController,
              label: l10n.fatTarget,
              suffix: l10n.gram,
              icon: Icons.water_drop,
              color: const Color(0xFFEF4444),
              validator: _validateNumber,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveGoals,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;
  final Color color;
  final String? Function(String?)? validator;

  const _GoalTextField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
    required this.color,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: color),
      ),
    );
  }
}
