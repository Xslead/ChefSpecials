import 'package:flutter/material.dart';

import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/ingredient.dart';
import '../../../models/recipe_step.dart';
import '../../../models/recipe_translation.dart';

class AddTranslationSheet extends StatefulWidget {
  final String originalLanguage;
  final List<String> alreadyAdded;
  final String originalTitle;
  final String originalDescription;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final void Function(String langCode, RecipeTranslation translation) onSave;

  const AddTranslationSheet({
    super.key,
    required this.originalLanguage,
    required this.alreadyAdded,
    required this.originalTitle,
    required this.originalDescription,
    required this.ingredients,
    required this.steps,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required String originalLanguage,
    required List<String> alreadyAdded,
    required String originalTitle,
    required String originalDescription,
    required List<Ingredient> ingredients,
    required List<RecipeStep> steps,
    required void Function(String, RecipeTranslation) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddTranslationSheet(
        originalLanguage: originalLanguage,
        alreadyAdded: alreadyAdded,
        originalTitle: originalTitle,
        originalDescription: originalDescription,
        ingredients: ingredients,
        steps: steps,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddTranslationSheet> createState() => _AddTranslationSheetState();
}

class _AddTranslationSheetState extends State<AddTranslationSheet> {
  String? _selectedLang;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  late final List<TextEditingController> _ingredientControllers;
  late final List<TextEditingController> _stepControllers;
  final _formKey = GlobalKey<FormState>();

  List<String> get _availableLanguages => kSupportedLanguages.keys
      .where((k) =>
          k != widget.originalLanguage &&
          !widget.alreadyAdded.contains(k))
      .toList();

  @override
  void initState() {
    super.initState();
    _ingredientControllers =
        List.generate(widget.ingredients.length, (_) => TextEditingController());
    _stepControllers =
        List.generate(widget.steps.length, (_) => TextEditingController());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (final c in _ingredientControllers) {
      c.dispose();
    }
    for (final c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLang == null) return;
    widget.onSave(
      _selectedLang!,
      RecipeTranslation(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        ingredientNames:
            _ingredientControllers.map((c) => c.text.trim()).toList(),
        stepInstructions:
            _stepControllers.map((c) => c.text.trim()).toList(),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.92,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiaryOf(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
              child: Row(
                children: [
                  Text(
                    l10n.addTranslation,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _selectedLang != null ? _save : null,
                    child: Text(
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
            ),
            const Divider(height: 1),
            // Scrollable content
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    _label(l10n.selectLanguage, context),
                    const SizedBox(height: 8),
                    if (_availableLanguages.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.allLanguagesAdded,
                          style: TextStyle(
                              color: AppTheme.textSecondaryOf(context)),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _selectedLang,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.language,
                              color: AppTheme.textTertiary),
                        ),
                        hint: Text(l10n.selectLanguage),
                        items: _availableLanguages
                            .map((k) => DropdownMenuItem(
                                  value: k,
                                  child: Text(kSupportedLanguages[k]!),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedLang = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    const SizedBox(height: 20),

                    _label(l10n.translatedTitle, context),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: widget.originalTitle,
                        prefixIcon: const Icon(Icons.title,
                            color: AppTheme.textTertiary),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    _label(l10n.translatedDescription, context),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      decoration: InputDecoration(
                        hintText: widget.originalDescription,
                        prefixIcon: const Icon(Icons.notes,
                            color: AppTheme.textTertiary),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),

                    if (widget.ingredients.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _label(l10n.ingredientNames, context),
                      const SizedBox(height: 12),
                      ...widget.ingredients.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextFormField(
                              controller: _ingredientControllers[e.key],
                              decoration: InputDecoration(
                                hintText: e.value.name,
                                labelText:
                                    '${l10n.ingredient} ${e.key + 1}',
                                prefixIcon: const Icon(Icons.eco_outlined,
                                    color: AppTheme.textTertiary, size: 20),
                              ),
                            ),
                          )),
                    ],

                    if (widget.steps.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _label(l10n.stepInstructions, context),
                      const SizedBox(height: 12),
                      ...widget.steps.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextFormField(
                              controller: _stepControllers[e.key],
                              decoration: InputDecoration(
                                hintText: e.value.instruction,
                                labelText: '${l10n.step} ${e.key + 1}',
                                prefixIcon: const Icon(
                                    Icons.format_list_numbered,
                                    color: AppTheme.textTertiary,
                                    size: 20),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textTertiaryOf(context),
        letterSpacing: 0.8,
      ),
    );
  }
}
