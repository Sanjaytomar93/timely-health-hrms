import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/dashboard_card.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/weekly_bar_chart_card.dart';

class UpdatesCelebrationsCard extends StatelessWidget {
  const UpdatesCelebrationsCard({
    super.key,
    this.monthLabel,
    this.items = const [],
    this.onDetails,
  });

  final String? monthLabel;
  final List<DashboardUpdateItemUi> items;
  final ValueChanged<DashboardUpdateItemUi>? onDetails;

  @override
  Widget build(BuildContext context) {
    final label = monthLabel?.trim() ?? '';

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardCardHeader(
            icon: Icons.celebration_rounded,
            color: PortalColors.orange,
            title: 'Updates & Celebrations',
            subtitle: 'Shifts, birthdays & more',
            trailing: label.isEmpty ? null : DashboardMonthChip(label: label),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const DashboardEmptyState(
              icon: Icons.notifications_none_rounded,
              message: 'No updates right now',
            )
          else
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _UpdateRow(
                item: items[i],
                onDetails: onDetails == null ? null : () => onDetails!(items[i]),
              ),
            ],
        ],
      ),
    );
  }
}

class _UpdateStyle {
  const _UpdateStyle(this.icon, this.color);

  final IconData icon;
  final Color color;

  static _UpdateStyle of(String kind) {
    switch (kind) {
      case 'birthday':
        return const _UpdateStyle(Icons.cake_rounded, Color(0xFFEC407A));
      case 'anniversary':
        return const _UpdateStyle(
          Icons.workspace_premium_rounded,
          PortalColors.orange,
        );
      case 'leave':
        return const _UpdateStyle(Icons.beach_access_rounded, Color(0xFF29B6F6));
      default:
        return const _UpdateStyle(Icons.schedule_rounded, PortalColors.brand);
    }
  }
}

class _UpdateRow extends StatelessWidget {
  const _UpdateRow({required this.item, this.onDetails});

  final DashboardUpdateItemUi item;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final style = _UpdateStyle.of(item.kind);
    final radius = BorderRadius.circular(14);

    return Material(
      color: style.color.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: style.color.withValues(alpha: 0.14)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDetails,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(style.icon, size: 19, color: style.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                        height: 15 / 12.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: PortalColors.muted,
                        height: 14 / 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDetails != null)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: PortalColors.muted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
