import 'package:flutter/material.dart';
import '../../../models/recipe_step.dart';

class StepOverviewList extends StatelessWidget {
  final List<RecipeStep> steps;

  const StepOverviewList({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: steps.map((step) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    '${step.order}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.instruction,
                        style: theme.textTheme.bodyLarge,
                      ),
                      if (step.timerSeconds != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimer(step.timerSeconds!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    if (minutes == 0) return '${remaining}s';
    if (remaining == 0) return '${minutes}m';
    return '${minutes}m ${remaining}s';
  }
}
