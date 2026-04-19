import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/trending_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_header.dart';
import '../home/widgets/recipe_card.dart';

class TrendingRecipesScreen extends StatefulWidget {
  const TrendingRecipesScreen({super.key});

  @override
  State<TrendingRecipesScreen> createState() => _TrendingRecipesScreenState();
}

class _TrendingRecipesScreenState extends State<TrendingRecipesScreen> {
  String _timeWindow = '7d';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TrendingProvider>()
          .loadTrending(timeWindow: _timeWindow, limit: 50, force: true);
    });
  }

  void _selectWindow(String window) {
    if (window == _timeWindow) return;
    setState(() => _timeWindow = window);
    context
        .read<TrendingProvider>()
        .loadTrending(timeWindow: window, limit: 50, force: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<TrendingProvider>();
    final recipes = provider.trendingRecipes;

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: l10n.trendingRecipes,
            icon: Icons.local_fire_department,
            iconColor: Colors.deepOrange,
          ),
          _buildFilterBar(l10n),
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : recipes.isEmpty
                    ? EmptyState(
                        icon: Icons.local_fire_department_outlined,
                        title: l10n.noRecipes,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RecipeCard(
                              recipe: recipes[index],
                              showTrendingBadge: true,
                              trendingRank: index + 1,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _buildChip(l10n.thisWeek, '7d'),
          const SizedBox(width: 8),
          _buildChip(l10n.thisMonth, '30d'),
          const SizedBox(width: 8),
          _buildChip(l10n.allTime, 'all'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    final selected = _timeWindow == value;
    return GestureDetector(
      onTap: () => _selectWindow(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryColor
              : AppTheme.neutralLightOf(context),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.textSecondaryOf(context),
          ),
        ),
      ),
    );
  }
}
