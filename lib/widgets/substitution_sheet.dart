import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/ingredient_substitution.dart';
import '../providers/auth_provider.dart';
import '../services/substitution_service.dart';

class SubstitutionSheet extends StatefulWidget {
  final String ingredientName;
  final SubstitutionService? service;

  const SubstitutionSheet({
    super.key,
    required this.ingredientName,
    this.service,
  });

  static Future<void> show(
    BuildContext context, {
    required String ingredientName,
    SubstitutionService? service,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SubstitutionSheet(
        ingredientName: ingredientName,
        service: service,
      ),
    );
  }

  @override
  State<SubstitutionSheet> createState() => _SubstitutionSheetState();
}

class _SubstitutionSheetState extends State<SubstitutionSheet> {
  late final SubstitutionService _service;
  late Future<List<IngredientSubstitution>> _future;
  String? _activeTag;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? SubstitutionService();
    _future = _load();
  }

  Future<List<IngredientSubstitution>> _load() {
    if (_activeTag == null) {
      return _service.getSubstitutions(widget.ingredientName);
    }
    return _service.getSubstitutionsByTag(widget.ingredientName, _activeTag!);
  }

  void _setFilter(String? tag) {
    setState(() {
      _activeTag = tag;
      _future = _load();
    });
  }

  Future<void> _openSuggestForm() async {
    final loc = AppLocalizations.of(context)!;
    final submitted = await showDialog<IngredientSubstitution>(
      context: context,
      builder: (_) => _SuggestSubstitutionDialog(
        originalIngredient: widget.ingredientName,
      ),
    );
    if (submitted == null || !mounted) return;

    final authorId = context.read<AuthProvider>().userModel?.uid;
    await _service.submitSubstitution(
      submitted.copyWith(submittedBy: authorId),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.thankYouSubstitution)),
    );
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            _buildHandle(),
            _buildHeader(loc),
            _buildFilters(loc),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<List<IngredientSubstitution>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snap.data ?? const [];
                  if (items.isEmpty) {
                    return _buildEmpty(loc);
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemBuilder: (_, i) =>
                        _SubstitutionCard(sub: items[i], loc: loc),
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemCount: items.length,
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(loc.suggestSubstitution),
                    onPressed: _openSuggestForm,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHandle() => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.textTertiary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _buildHeader(AppLocalizations loc) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            const Icon(Icons.swap_horiz, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                loc.substitutesFor(widget.ingredientName),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildFilters(AppLocalizations loc) {
    final tags = AppConstants.defaultDietaryTags;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(loc.filterAll),
              selected: _activeTag == null,
              onSelected: (_) => _setFilter(null),
            ),
          ),
          for (final tag in tags)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(tag),
                selected: _activeTag == tag,
                onSelected: (_) => _setFilter(tag),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations loc) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off,
                  size: 48, color: AppTheme.textTertiary),
              const SizedBox(height: 12),
              Text(
                loc.noSubstitutions,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
}

class _SubstitutionCard extends StatelessWidget {
  final IngredientSubstitution sub;
  final AppLocalizations loc;

  const _SubstitutionCard({required this.sub, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: sub.isVerified
              ? AppTheme.primaryColor.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sub.substituteName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (sub.isVerified)
                Tooltip(
                  message: loc.verified,
                  child: Icon(Icons.verified,
                      size: 18, color: AppTheme.primaryColor),
                )
              else
                Tooltip(
                  message: loc.communitySubmitted,
                  child: Icon(Icons.people_outline,
                      size: 18, color: AppTheme.textTertiary),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.balance, size: 14, color: AppTheme.textTertiary),
              const SizedBox(width: 4),
              Text(
                '${loc.ratio}: ${sub.ratio}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (sub.notes != null && sub.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              sub.notes!,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          if (sub.dietaryTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: sub.dietaryTags
                  .map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuggestSubstitutionDialog extends StatefulWidget {
  final String originalIngredient;

  const _SuggestSubstitutionDialog({required this.originalIngredient});

  @override
  State<_SuggestSubstitutionDialog> createState() =>
      _SuggestSubstitutionDialogState();
}

class _SuggestSubstitutionDialogState
    extends State<_SuggestSubstitutionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ratioController = TextEditingController(text: '1:1');
  final _notesController = TextEditingController();
  final Set<String> _tags = {};

  @override
  void dispose() {
    _nameController.dispose();
    _ratioController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(loc.suggestSubstitution),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: loc.substituteName),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ratioController,
                decoration: InputDecoration(labelText: loc.ratio),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: loc.notesOptional),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: AppConstants.defaultDietaryTags
                    .map((t) => FilterChip(
                          label: Text(t),
                          selected: _tags.contains(t),
                          onSelected: (s) => setState(() {
                            if (s) {
                              _tags.add(t);
                            } else {
                              _tags.remove(t);
                            }
                          }),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(loc.submit),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final notes = _notesController.text.trim();
    final sub = IngredientSubstitution(
      originalIngredient: widget.originalIngredient,
      substituteName: _nameController.text.trim(),
      ratio: _ratioController.text.trim().isEmpty
          ? '1:1'
          : _ratioController.text.trim(),
      notes: notes.isEmpty ? null : notes,
      dietaryTags: _tags.toList(),
      isVerified: false,
    );
    Navigator.of(context).pop(sub);
  }
}
