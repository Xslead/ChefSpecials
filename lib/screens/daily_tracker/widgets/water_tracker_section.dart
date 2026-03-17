import 'dart:math';
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';

class WaterTrackerSection extends StatefulWidget {
  final int currentMl;
  final int targetMl;
  final Function(int) onAdd;
  final Function(int) onRemove;

  const WaterTrackerSection({
    super.key,
    required this.currentMl,
    required this.targetMl,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<WaterTrackerSection> createState() => _WaterTrackerSectionState();
}

class _WaterTrackerSectionState extends State<WaterTrackerSection>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  final GlobalKey _waveBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.04), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 0.98), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.98, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(covariant WaterTrackerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMl != widget.currentMl) {
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleWaveBarTap(TapUpDetails details) {
    final renderBox =
        _waveBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final barWidth = renderBox.size.width;
    final tapX = details.localPosition.dx;
    final tapPercent = (tapX / barWidth).clamp(0.0, 1.0);
    final fillPercent = widget.targetMl > 0
        ? (widget.currentMl / widget.targetMl).clamp(0.0, 1.0)
        : 0.0;

    if (tapPercent > fillPercent) {
      widget.onAdd(250);
    } else if (widget.currentMl >= 250) {
      widget.onRemove(250);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fillPercent = widget.targetMl > 0
        ? (widget.currentMl / widget.targetMl).clamp(0.0, 1.0)
        : 0.0;
    final canRemove = widget.currentMl >= 250;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
        ),
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_drop,
                      color: Color(0xFF0EA5E9), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    l10n.waterTracking,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              Text(
                '${widget.currentMl} / ${widget.targetMl} ${l10n.ml}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryOf(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Wave progress bar
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: child,
              );
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: _handleWaveBarTap,
              child: SizedBox(
                key: _waveBarKey,
                height: 48,
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, _) {
                    return CustomPaint(
                      size: const Size(double.infinity, 48),
                      painter: _WaveBarPainter(
                        fillPercent: fillPercent,
                        wavePhase: _waveController.value * 2 * pi,
                        emptyColor: AppTheme.neutralLightOf(context)
                            .withValues(alpha: 0.3),
                        fillColorLeft: const Color(0xFF7DD3FC),
                        fillColorRight: const Color(0xFF0EA5E9),
                        borderColor: AppTheme.neutralLightOf(context),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Percentage label
          Center(
            child: Text(
              '${(fillPercent * 100).toInt()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondaryOf(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(
                child: _WaterButton(
                  label: '−250 ${l10n.ml}',
                  enabled: canRemove,
                  isRemove: true,
                  onTap: () => widget.onRemove(250),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WaterButton(
                  label: '+250 ${l10n.ml}',
                  enabled: true,
                  isRemove: false,
                  onTap: () => widget.onAdd(250),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WaterButton(
                  label: '+500 ${l10n.ml}',
                  enabled: true,
                  isRemove: false,
                  onTap: () => widget.onAdd(500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isRemove;
  final VoidCallback onTap;

  const _WaterButton({
    required this.label,
    required this.enabled,
    required this.isRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor =
        isRemove ? const Color(0xFFEF4444) : const Color(0xFF0EA5E9);
    final activeBorder =
        isRemove ? const Color(0xFFFECACA) : const Color(0xFFBAE6FD);
    final disabledColor = AppTheme.textTertiaryOf(context);
    final disabledBorder = AppTheme.neutralLightOf(context);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: enabled
              ? activeColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: enabled ? activeBorder : disabledBorder,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: enabled ? activeColor : disabledColor,
          ),
        ),
      ),
    );
  }
}

class _WaveBarPainter extends CustomPainter {
  final double fillPercent;
  final double wavePhase;
  final Color emptyColor;
  final Color fillColorLeft;
  final Color fillColorRight;
  final Color borderColor;

  _WaveBarPainter({
    required this.fillPercent,
    required this.wavePhase,
    required this.emptyColor,
    required this.fillColorLeft,
    required this.fillColorRight,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 12.0;
    final barRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final barRRect =
        RRect.fromRectAndRadius(barRect, const Radius.circular(radius));

    // Empty background
    final emptyPaint = Paint()..color = emptyColor;
    canvas.drawRRect(barRRect, emptyPaint);

    if (fillPercent > 0) {
      canvas.save();
      canvas.clipRRect(barRRect);

      final fillWidth = size.width * fillPercent;
      const waveHeight = 4.0;
      const waveCount = 3.0;

      // Build wave path
      final path = Path();
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(fillWidth - waveHeight, 0);

      // Draw wavy right edge
      final waveSegmentHeight = size.height / (waveCount * 2);
      for (int i = 0; i < (waveCount * 2).toInt(); i++) {
        final yStart = i * waveSegmentHeight;
        final yEnd = (i + 1) * waveSegmentHeight;
        final xOffset =
            (i.isEven ? 1 : -1) * waveHeight * sin(wavePhase + i * 0.8);
        path.quadraticBezierTo(
          fillWidth + xOffset,
          (yStart + yEnd) / 2,
          fillWidth,
          yEnd,
        );
      }

      path.lineTo(0, size.height);
      path.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [fillColorLeft, fillColorRight],
        ).createShader(Rect.fromLTWH(0, 0, fillWidth, size.height));

      canvas.drawPath(path, fillPaint);
      canvas.restore();
    }

    // Border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(barRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _WaveBarPainter oldDelegate) {
    return oldDelegate.fillPercent != fillPercent ||
        oldDelegate.wavePhase != wavePhase;
  }
}
