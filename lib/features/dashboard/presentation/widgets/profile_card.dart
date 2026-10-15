import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, this.data});

  final DashboardProfileUi? data;

  static String _stripPrefix(String label, String prefix) {
    final trimmed = label.trim();
    return trimmed.startsWith(prefix)
        ? trimmed.substring(prefix.length).trim()
        : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final initials = data?.initials ?? '?';
    final name = data?.name ?? '—';
    final department = data?.department ?? '—';
    final employeeId = data?.employeeId ?? '—';
    final statusLabel = data?.statusLabel ?? '—';
    final location = _stripPrefix(data?.locationLabel ?? '—', '📍');
    final shift = _stripPrefix(data?.shiftLabel ?? '—', '🕒');
    final isActive = statusLabel.toLowerCase() == 'active';
    final statusColor = isActive ? PortalColors.green : PortalColors.muted;

    final metaStyle = portalText(
      fontSize: 11.5,
      fontWeight: FontWeight.w400,
      color: PortalColors.muted,
      height: 14 / 11.5,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          _Avatar(initials: initials, statusColor: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.heading,
                            height: 19 / 15.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _IdBadge(employeeId: employeeId),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  department,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.brand,
                    height: 15 / 12.5,
                  ),
                ),
                const SizedBox(height: 13),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(statusLabel, style: metaStyle),
                      const SizedBox(width: 9),
                      Text('📍 $location', style: metaStyle),
                      const SizedBox(width: 9),
                      Text('🕒 $shift', style: metaStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, required this.statusColor});

  final String initials;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: PortalColors.brandGradient,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: PortalColors.brand.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              initials,
              textAlign: TextAlign.center,
              style: portalText(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 18 / 15,
              ),
            ),
          ),
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: PortalColors.surface, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdBadge extends StatelessWidget {
  const _IdBadge({required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: PortalColors.border),
      ),
      child: Text(
        'ID: $employeeId',
        maxLines: 1,
        style: portalText(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: PortalColors.secondaryText,
          height: 13 / 10.5,
        ),
      ),
    );
  }
}
