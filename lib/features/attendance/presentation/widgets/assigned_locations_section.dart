import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/presentation/models/location_ui_model.dart';

class AssignedLocationsSection extends StatelessWidget {
  const AssignedLocationsSection({super.key, this.location});

  final LocationUiModel? location;

  @override
  Widget build(BuildContext context) {
    final name = location?.name ?? '—';
    final address = location?.fullAddress ?? 'Address not available';
    final lat = location?.latitudeLabel ?? '—';
    final lng = location?.longitudeLabel ?? '—';

    return Padding(
      padding: const EdgeInsets.fromLTRB(11, 20, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📍 Assigned Locations',
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000),
              height: 16 / 13,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: BoxDecoration(
              color: PortalColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PortalColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A2E),
                    height: 26 / 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  address,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: PortalColors.muted,
                    height: 13 / 11,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFEFEDF5),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Spacer(),
                    _CoordBlock(value: lat, label: 'Lat'),
                    const SizedBox(width: 36),
                    _CoordBlock(value: lng, label: 'Long'),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordBlock extends StatelessWidget {
  const _CoordBlock({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: portalText(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: PortalColors.purple,
            height: 26 / 13,
          ),
        ),
        Text(
          label,
          style: portalText(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: PortalColors.muted,
            height: 13 / 11,
          ),
        ),
      ],
    );
  }
}
