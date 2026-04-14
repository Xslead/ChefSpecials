import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/screen_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn =
        context.watch<LocaleProvider>().locale.languageCode == 'en';

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: l10n.settings,
            icon: Icons.settings_outlined,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              children: [
                _SectionLabel(label: l10n.account),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.edit_outlined,
                      iconColor: AppTheme.primaryColor,
                      title: l10n.editProfile,
                      onTap: () => context.push('/edit-profile'),
                    ),
                    _Divider(context),
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      iconColor: AppTheme.snackColor,
                      title: l10n.notificationSettings,
                      onTap: () => context.push('/notification-settings'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionLabel(label: l10n.appearance),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      iconColor: isDark
                          ? AppTheme.starColor
                          : const Color(0xFF6366F1),
                      title: isDark ? l10n.lightMode : l10n.darkMode,
                      onTap: () =>
                          context.read<ThemeProvider>().toggleTheme(),
                    ),
                    _Divider(context),
                    _SettingsTile(
                      icon: Icons.language_outlined,
                      iconColor: AppTheme.secondaryColor,
                      title: isEn ? 'Türkçe' : 'English',
                      trailing: Text(
                        isEn ? 'EN' : 'TR',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textTertiaryOf(context),
                        ),
                      ),
                      onTap: () =>
                          context.read<LocaleProvider>().toggleLocale(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.logout,
                      iconColor: AppTheme.errorColor,
                      title: l10n.logout,
                      titleColor: AppTheme.errorColor,
                      onTap: () => _showLogoutDialog(context, l10n),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<AuthProvider>().signOut();
              if (context.mounted) context.go('/home');
            },
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorColor),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textTertiaryOf(context),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
        ),
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: AppTheme.textTertiaryOf(context),
          ),
      onTap: onTap,
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

Widget _Divider(BuildContext context) => Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
    );
