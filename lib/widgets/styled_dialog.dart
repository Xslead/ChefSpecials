import 'package:flutter/material.dart';
import '../config/theme.dart';

class StyledDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    Widget? content,
    String? cancelText,
    String? confirmText,
    Color? confirmColor,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    bool isDestructive = false,
  }) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title),
        content: content,
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: onCancel ?? () => Navigator.pop(ctx),
              child: Text(cancelText),
            ),
          if (confirmText != null)
            isDestructive
                ? TextButton(
                    onPressed: onConfirm ?? () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          confirmColor ?? AppTheme.errorColor,
                    ),
                    child: Text(confirmText),
                  )
                : FilledButton(
                    onPressed: onConfirm ?? () => Navigator.pop(ctx),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          confirmColor ?? AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusS),
                      ),
                    ),
                    child: Text(confirmText),
                  ),
        ],
      ),
    );
  }

  static Future<String?> showInput({
    required BuildContext context,
    required String title,
    String? hintText,
    String? cancelText,
    String? confirmText,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: maxLines,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20)
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(cancelText ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
            ),
            child: Text(confirmText ?? 'Save'),
          ),
        ],
      ),
    );
  }
}
