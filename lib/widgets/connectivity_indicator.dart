import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/connectivity_provider.dart';

class ConnectivityIndicator extends StatelessWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConnectivityProvider>();
    final l10n = AppLocalizations.of(context)!;

    if (provider.isOnline && !provider.isSyncing) {
      return const SizedBox.shrink();
    }

    final isOffline = !provider.isOnline;
    final color = isOffline ? const Color(0xFFF59E0B) : Colors.green.shade600;
    final icon = isOffline ? Icons.wifi_off_rounded : Icons.sync_rounded;
    final message =
        isOffline ? l10n.youreOffline : l10n.backOnline;
    final subtitle =
        isOffline ? l10n.changesSyncWhenConnected : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
