import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/ban_appeal.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';

class BannedScreen extends StatefulWidget {
  const BannedScreen({super.key});

  @override
  State<BannedScreen> createState() => _BannedScreenState();
}

class _BannedScreenState extends State<BannedScreen> {
  final _adminService = AdminService();
  final _appealController = TextEditingController();
  BanAppeal? _existingAppeal;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadAppeal();
  }

  @override
  void dispose() {
    _appealController.dispose();
    super.dispose();
  }

  Future<void> _loadAppeal() async {
    final user = context.read<AuthProvider>().userModel;
    if (user == null) return;
    try {
      final appeal = await _adminService.getUserAppeal(user.uid);
      if (mounted) {
        setState(() {
          _existingAppeal = appeal;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAppeal() async {
    final text = _appealController.text.trim();
    if (text.isEmpty) return;

    final user = context.read<AuthProvider>().userModel;
    if (user == null) return;

    setState(() => _isSubmitting = true);
    try {
      await _adminService.submitAppeal(
        userId: user.uid,
        userName: user.fullName,
        userEmail: user.email,
        appealText: text,
      );
      _appealController.clear();
      await _loadAppeal();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.appealSubmitted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().userModel;

    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 60),
                            // Block icon
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.block,
                                size: 80,
                                color: AppTheme.errorColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Title
                            Text(
                              l10n.accountSuspended,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryOf(context),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Suspended message
                            Text(
                              l10n.accountSuspendedMessage,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryOf(context),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            // Ban reason card
                            if (user?.banReason != null &&
                                user!.banReason!.isNotEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorColor
                                      .withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppTheme.errorColor
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.banReason,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.errorColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      user.banReason!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textPrimaryOf(
                                            context),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 32),
                            // Appeal section
                            if (_existingAppeal != null &&
                                _existingAppeal!.status == 'pending')
                              _buildAppealUnderReview(context, l10n)
                            else if (_existingAppeal == null)
                              _buildAppealForm(context, l10n),
                          ],
                        ),
                      ),
                    ),
                    // Sign out button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await context.read<AuthProvider>().signOut();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: Text(l10n.logout),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textSecondaryOf(context),
                            side: BorderSide(
                              color: AppTheme.neutralLightOf(context),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAppealUnderReview(
      BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.starColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.starColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.starColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.hourglass_top,
              color: AppTheme.starColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appealUnderReview,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.starColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _existingAppeal!.appealText,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryOf(context),
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppealForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.submitAppeal,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _appealController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: l10n.appealText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitAppeal,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l10n.submitAppeal),
          ),
        ),
      ],
    );
  }
}
