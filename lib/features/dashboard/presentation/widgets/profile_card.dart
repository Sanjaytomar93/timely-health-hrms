import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, this.data});

  final DashboardProfileUi? data;

  @override
  Widget build(BuildContext context) {
    final initials = data?.initials ?? '?';
    final name = data?.name ?? '—';
    final department = data?.department ?? '—';
    final employeeId = data?.employeeId ?? '—';
    final statusLabel = data?.statusLabel ?? '—';
    final locationLabel = data?.locationLabel ?? '📍 —';
    final shiftLabel = data?.shiftLabel ?? '🕒 —';
    final isActive = statusLabel.toLowerCase() == 'active';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(21)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: PortalColors.brandGradient,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 18 / 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 0,
                child: Container(
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
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.secondaryText,
                      height: 13 / 10.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 9,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? PortalColors.green : PortalColors.muted,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    statusLabel,
                    style: portalText(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: PortalColors.muted,
                      height: 14 / 11.5,
                    ),
                  ),
                ],
              ),
              Text(
                locationLabel,
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: PortalColors.muted,
                  height: 14 / 11.5,
                ),
              ),
              Text(
                shiftLabel,
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: PortalColors.muted,
                  height: 14 / 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
