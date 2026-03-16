import 'package:flutter/material.dart';
import '../config/theme.dart';

class LoadingState extends StatelessWidget {
  final bool inline;

  const LoadingState({super.key, this.inline = false});

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      color: AppTheme.primaryColor,
      strokeWidth: 2,
    );

    if (inline) return indicator;

    return Center(child: indicator);
  }
}
