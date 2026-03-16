import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/recipe.dart';
import '../../l10n/generated/app_localizations.dart';
import 'widgets/step_page.dart';

class CookingModeScreen extends StatefulWidget {
  final Recipe recipe;

  const CookingModeScreen({super.key, required this.recipe});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = widget.recipe.steps;
    final isFirst = _currentPage == 0;
    final isLast = _currentPage == steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            width: double.infinity,
            color: AppTheme.neutralLightOf(context),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: steps.isEmpty ? 0 : (_currentPage + 1) / steps.length,
              child: Container(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ),
      body: steps.isEmpty
          ? Center(child: Text(l10n.error))
          : PageView.builder(
              controller: _pageController,
              itemCount: steps.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return StepPage(
                  step: steps[index],
                  totalSteps: steps.length,
                );
              },
            ),
      bottomNavigationBar: steps.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isFirst ? null : () => _goToPage(_currentPage - 1),
                        icon: const Icon(Icons.arrow_back),
                        label: Text(l10n.previous),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isLast
                            ? () => Navigator.of(context).pop()
                            : () => _goToPage(_currentPage + 1),
                        icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
                        label: Text(isLast ? l10n.done : l10n.next),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
