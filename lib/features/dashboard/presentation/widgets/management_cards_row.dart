import 'package:flutter/material.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/dashboard_card.dart';

class ManagementCardsRow extends StatelessWidget {
  const ManagementCardsRow({super.key});

  static const double _cardHeight = 82;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        kDashboardGutter,
        8,
        kDashboardGutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionTitle('Management'),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: _cardHeight,
                  child: _ManagementCard(
                    title: 'OP Management',
                    subtitle: 'Outpatient work',
                    icon: Icons.monitor_heart_rounded,
                    color: PortalColors.brand,
                    tint: PortalColors.brandTint,
                    onTap: () => AppRoutes.push(
                      context,
                      AppRoutes.placeholder,
                      arguments: 'OP Management',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: _cardHeight,
                  child: _ManagementCard(
                    title: 'Camp Management',
                    subtitle: 'Health camps',
                    icon: Icons.medical_services_rounded,
                    color: PortalColors.green,
                    tint: PortalColors.greenTint,
                    onTap: () => AppRoutes.push(
                      context,
                      AppRoutes.campManagement,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  const _ManagementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tint,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PortalColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: PortalColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PortalColors.border),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 14 / 12,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: PortalColors.muted,
                    height: 12 / 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dart indicator ───────────────────────────────────────────────────────────

class _ManagementDartIndicator extends StatelessWidget {
  const _ManagementDartIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PortalColors.brand.withValues(alpha: 0.0),
                PortalColors.brand.withValues(alpha: 0.18),
              ],
            ),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(4),
            ),
          ),
        ),
        CustomPaint(
          size: const Size(14, 8),
          painter: _DartPainter(
            color: PortalColors.brand.withValues(alpha: 0.35),
          ),
        ),
        Container(
          width: 28,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PortalColors.brand.withValues(alpha: 0.18),
                PortalColors.brand.withValues(alpha: 0.0),
              ],
            ),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}

class _DartPainter extends CustomPainter {
  const _DartPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DartPainter old) => old.color != color;
}
