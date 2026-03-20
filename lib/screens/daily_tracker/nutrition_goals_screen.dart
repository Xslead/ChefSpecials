import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/nutrition_goal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/daily_tracker_provider.dart';
import '../../widgets/screen_header.dart';

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
  late TextEditingController _waterController;
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
    _waterController = TextEditingController(
      text: (goal?.waterTargetMl ?? 2500).toString(),
    );
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _waterController.dispose();
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
      waterTargetMl: int.tryParse(_waterController.text) ?? 2500,
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
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) return l10n.requiredField;
    final number = double.tryParse(value);
    if (number == null || number <= 0) return l10n.enterValidNumber;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: l10n.nutritionGoals,
            icon: Icons.track_changes,
            trailing: [
              TextButton(
                onPressed: _isSaving ? null : _saveGoals,
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        l10n.save,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
              ),
            ],
          ),
          // Body
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                children: [
                  // Calorie goal card
                  _buildGoalCard(
                    icon: Icons.local_fire_department,
                    color: AppTheme.primaryColor,
                    label: l10n.calorieTarget,
                    suffix: l10n.kcal,
                    controller: _calorieController,
                  ),
                  const SizedBox(height: 12),
                  // Macro goals row
                  Row(
                    children: [
                      Expanded(
                        child: _buildGoalCard(
                          icon: Icons.fitness_center,
                          color: AppTheme.secondaryColor,
                          label: l10n.protein,
                          suffix: l10n.gram,
                          controller: _proteinController,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildGoalCard(
                          icon: Icons.grain,
                          color: const Color(0xFFF59E0B),
                          label: l10n.carbsShort,
                          suffix: l10n.gram,
                          controller: _carbsController,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildGoalCard(
                          icon: Icons.water_drop,
                          color: const Color(0xFF10B981),
                          label: l10n.fat,
                          suffix: l10n.gram,
                          controller: _fatController,
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Water goal card
                  _buildGoalCard(
                    icon: Icons.local_drink,
                    color: const Color(0xFF0EA5E9),
                    label: l10n.waterTarget,
                    suffix: l10n.ml,
                    controller: _waterController,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required IconData icon,
    required Color color,
    required String label,
    required String suffix,
    required TextEditingController controller,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + label row
          Row(
            children: [
              Container(
                width: compact ? 32 : 40,
                height: compact ? 32 : 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(compact ? 8 : 10),
                ),
                child: Icon(icon, color: color, size: compact ? 18 : 22),
              ),
              SizedBox(width: compact ? 8 : 12),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: compact ? 9 : 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondaryOf(context),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 14),
          // Input field
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validateNumber,
            style: TextStyle(
              fontSize: compact ? 20 : 28,
              fontWeight: FontWeight.w900,
              color: color,
            ),
            textAlign: compact ? TextAlign.center : TextAlign.left,
            decoration: InputDecoration(
              suffixText: suffix,
              suffixStyle: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textTertiaryOf(context),
              ),
              filled: true,
              fillColor: AppTheme.neutralSoftOf(context),
              contentPadding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 16,
                vertical: compact ? 10 : 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: color, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.errorColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
