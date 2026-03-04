import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';

class ShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade100),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _buildNavItem(
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: l10n.home,
                ),
                _buildNavItem(
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book,
                  label: l10n.myRecipes,
                ),
                _buildNavItem(
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.track_changes_outlined,
                  activeIcon: Icons.track_changes,
                  label: l10n.dailyTracker,
                ),
                _buildNavItem(
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.kitchen_outlined,
                  activeIcon: Icons.kitchen,
                  label: l10n.materials,
                ),
                _buildNavItem(
                  index: 4,
                  currentIndex: currentIndex,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: l10n.profile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          navigationShell.goBranch(
            index,
            initialLocation: index == currentIndex,
          );
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 24,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.grey.shade400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
