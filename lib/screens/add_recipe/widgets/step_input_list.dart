import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/recipe_form_provider.dart';

class StepInputList extends StatelessWidget {
  const StepInputList({super.key});

  @override
  Widget build(BuildContext context) {
    final formProvider = context.watch<RecipeFormProvider>();
    final l10n = AppLocalizations.of(context)!;
    final steps = formProvider.steps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.steps,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: formProvider.addStep,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final step = steps[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: step.instruction,
                        decoration: const InputDecoration(
                          labelText: 'Instruction',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        maxLines: 2,
                        onChanged: (value) => formProvider.updateStep(
                          index,
                          instruction: value,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: step.timerSeconds?.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Timer (seconds)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final seconds = int.tryParse(value);
                          formProvider.updateStep(
                            index,
                            timerSeconds: seconds,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                if (steps.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 20,
                    onPressed: () => formProvider.removeStep(index),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
