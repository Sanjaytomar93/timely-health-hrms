import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

/// Distinctive portal-switch chip that returns the user to HRMS.
class CampHrmsSwitchButton extends StatefulWidget {
  const CampHrmsSwitchButton({
    super.key,
    required this.onTap,
    this.compact = false,
  });

  final VoidCallback onTap;
  final bool compact;

  @override
  State<CampHrmsSwitchButton> createState() => _CampHrmsSwitchButtonState();
}

class _CampHrmsSwitchButtonState extends State<CampHrmsSwitchButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final height = compact ? 36.0 : 40.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            final t = _pulse.value;
            return Container(
              height: height,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 12 : 14,
                vertical: compact ? 6 : 7,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color.lerp(
                      const Color(0xFFF8F7FC),
                      CampColors.primaryTint,
                      t * 0.55,
                    )!,
                  ],
                ),
                border: Border.all(
                  color: Color.lerp(
                    CampColors.primary.withValues(alpha: 0.14),
                    CampColors.green.withValues(alpha: 0.35),
                    t * 0.4,
                  )!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CampColors.primary.withValues(alpha: 0.12 + t * 0.16),
                    blurRadius: 14,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: CampColors.green.withValues(alpha: 0.08 + t * 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'HRMS',
                        style: portalText(
                          fontSize: compact ? 11.5 : 12.5,
                          fontWeight: FontWeight.w800,
                          color: CampColors.heading,
                          letterSpacing: 0.6,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 5),
                      _LivePip(pulse: t),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Switch portal',
                    style: portalText(
                      fontSize: compact ? 8 : 8.5,
                      fontWeight: FontWeight.w600,
                      color: CampColors.muted,
                      letterSpacing: 0.15,
                      height: 1,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LivePip extends StatelessWidget {
  const _LivePip({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5.5,
      height: 5.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CampColors.green,
        boxShadow: [
          BoxShadow(
            color: CampColors.green.withValues(alpha: 0.35 + pulse * 0.45),
            blurRadius: 4 + pulse * 2,
          ),
        ],
      ),
    );
  }
}
