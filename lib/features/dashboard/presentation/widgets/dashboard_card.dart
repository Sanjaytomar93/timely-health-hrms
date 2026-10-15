import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

const double kDashboardGutter = 16;
const double kDashboardSectionGap = 16;

BoxDecoration dashboardCardDecoration({double radius = 18}) => BoxDecoration(
  color: PortalColors.surface,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: PortalColors.border),
  boxShadow: [
    BoxShadow(
      color: PortalColors.brand.withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ],
);

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.topSpacing = kDashboardSectionGap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double topSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        kDashboardGutter,
        topSpacing,
        kDashboardGutter,
        0,
      ),
      padding: padding,
      decoration: dashboardCardDecoration(),
      child: child,
    );
  }
}

class DashboardCardHeader extends StatelessWidget {
  const DashboardCardHeader({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final sub = subtitle?.trim() ?? '';
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                  height: 18 / 14,
                ),
              ),
              if (sub.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: PortalColors.muted,
                    height: 13 / 10.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

class DashboardSectionTitle extends StatelessWidget {
  const DashboardSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10),
      child: Text(
        title,
        style: portalText(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: PortalColors.heading,
          height: 17 / 14,
        ),
      ),
    );
  }
}

class DashboardEmptyState extends StatelessWidget {
  const DashboardEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: PortalColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: PortalColors.muted),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: PortalColors.muted,
              height: 15 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
