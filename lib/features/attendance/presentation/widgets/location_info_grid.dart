import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/presentation/models/location_ui_model.dart';

class LocationInfoGrid extends StatelessWidget {
  const LocationInfoGrid({super.key, this.location});

  final LocationUiModel? location;

  static const _border = Color(0xFFEEEDF2);
  static const _title = Color(0xFF1A1A2E);
  static const _label = Color(0xFF888888);
  static const _badgeBg = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    final name = location?.employeeName ?? 'Employee';
    final employeeId = location?.employeeId ?? '—';
    final locationName = location?.name ?? '—';
    final coords = location?.coordinatesLabel ?? '—';
    final assigned = location?.locationsAssignedLabel ?? '0';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoCard(
                  iconAsset: 'assets/icons/attendance/location/ic_loc_user.svg',
                  title: name,
                  subtitle: 'Employee',
                  badge: employeeId,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: _InfoCard(
                  iconAsset:
                      'assets/icons/attendance/location/ic_loc_count.svg',
                  title: assigned,
                  subtitle: 'Locations assigned',
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoCard(
                  iconAsset: 'assets/icons/attendance/location/ic_loc_pin.svg',
                  title: locationName,
                  subtitle: 'Primary location name',
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: _InfoCard(
                  iconAsset: 'assets/icons/attendance/location/ic_loc_nav.svg',
                  title: coords,
                  subtitle: 'Coordinates lat, long',
                  titleSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    this.badge,
    this.titleSize = 16,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final String? badge;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LocationInfoGrid._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SvgPicture.asset(iconAsset, width: 34, height: 34),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: LocationInfoGrid._badgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: portalText(
                      fontSize: 9.8,
                      fontWeight: FontWeight.w400,
                      color: LocationInfoGrid._label,
                      height: 12 / 9.8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 1,
              style: portalText(
                fontSize: titleSize,
                fontWeight: FontWeight.w500,
                color: LocationInfoGrid._title,
                height: 26 / 16,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 9.3,
              fontWeight: FontWeight.w400,
              color: LocationInfoGrid._label,
              height: 11 / 9.3,
            ),
          ),
        ],
      ),
    );
  }
}
