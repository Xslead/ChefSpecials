import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success =
        await authProvider.sendPasswordResetEmail(_emailController.text.trim());

    if (mounted) {
      setState(() {
        _isLoading = false;
        _emailSent = success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/login')),
        title: Text(l10n.forgotPassword),
        elevation: 0,
      ),
      body: Container(
        color: AppTheme.backgroundOf(context),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _emailSent ? _buildSuccessView(textTheme, l10n) : _buildFormView(textTheme, l10n, authProvider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(TextTheme textTheme, AppLocalizations l10n, AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset_outlined, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.resetYourPassword,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.resetPasswordDescription,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryOf(context)),
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.email,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterEmail;
              }
              if (!value.contains('@')) {
                return l10n.pleaseEnterValidEmail;
              }
              return null;
            },
          ),
          if (authProvider.error != null) ...[
            const SizedBox(height: 16),
            Text(
              authProvider.error!,
              style: const TextStyle(color: AppTheme.errorColor),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          GradientButton(
            text: l10n.sendResetLink,
            onPressed: _isLoading ? null : _handleSend,
            icon: Icons.send,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(l10n.backToLogin),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(TextTheme textTheme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_outlined, size: 36, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.checkYourEmail,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.resetLinkSent(_emailController.text.trim()),
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryOf(context)),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.checkInboxDescription,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: AppTheme.textTertiaryOf(context)),
        ),
        const SizedBox(height: 40),
        GradientButton(
          text: l10n.backToLogin,
          onPressed: () => context.go('/login'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading ? null : _handleSend,
          child: Text(l10n.resendEmail),
        ),
      ],
    );
  }
}
