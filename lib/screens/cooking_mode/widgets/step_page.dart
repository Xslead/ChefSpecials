import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/recipe_step.dart';
import 'countdown_timer_widget.dart';

class StepPage extends StatelessWidget {
  final RecipeStep step;
  final int totalSteps;

  const StepPage({
    super.key,
    required this.step,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step number badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Step ${step.order} of $totalSteps',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Step image
          if (step.imageUrl != null && step.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: step.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, size: 60),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Instruction text
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                step.instruction,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Timer
          if (step.timerSeconds != null && step.timerSeconds! > 0)
            CountdownTimerWidget(totalSeconds: step.timerSeconds!),
        ],
      ),
    );
  }
}
