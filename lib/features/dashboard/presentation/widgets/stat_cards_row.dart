import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

class StatCardsRow extends StatelessWidget {
  const StatCardsRow({super.key, this.cards});

  final List<StatCardData>? cards;

  static const _fallback = <StatCardData>[
    StatCardData(
      title: 'Present',
      value: '0',
      subtitle: 'days this month',
      iconAsset: 'assets/icons/stat_cards/ic_stat_present.svg',
    ),
    StatCardData(
      title: 'Absent',
      value: '0',
      subtitle: 'days this month',
      iconAsset: 'assets/icons/stat_cards/ic_stat_absent.svg',
    ),
    StatCardData(
      title: 'Late',
      value: '0',
      subtitle: 'instances',
      iconAsset: 'assets/icons/stat_cards/ic_stat_late.svg',
    ),
    StatCardData(
      title: 'Attendance',
      value: '0',
      subtitle: 'of 0 days',
      iconAsset: 'assets/icons/stat_cards/ic_stat_attendance.svg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = cards ?? _fallback;
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 10));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _CompactStatCard(
                  data: items[i],
                  valueColor: _valueColors[i % _valueColors.length],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: i + 1 < items.length
                    ? _CompactStatCard(
                        data: items[i + 1],
                        valueColor: _valueColors[(i + 1) % _valueColors.length],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(children: rows),
    );
  }

  static const _valueColors = <Color>[
    PortalColors.green,
    PortalColors.red,
    PortalColors.orange,
    PortalColors.brand,
  ];
}

class _CompactStatCard extends StatelessWidget {
  const _CompactStatCard({required this.data, required this.valueColor});

  final StatCardData data;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          SvgPicture.asset(data.iconAsset, width: 44, height: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.muted,
                    letterSpacing: 0.4,
                    height: 12 / 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: data.value,
                        style: portalText(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: valueColor,
                          height: 24 / 20,
                        ),
                      ),
                      TextSpan(
                        text: ' ${data.subtitle}',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: PortalColors.muted,
                          height: 24 / 11,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatCardData {
  const StatCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.iconAsset,
  });

  final String title;
  final String value;
  final String subtitle;
  final String iconAsset;
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.data,
    this.width = 120,
    this.valueColor = PortalColors.green,
  });

  final StatCardData data;
  final double width;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.fromLTRB(13, 13, 10, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(data.iconAsset, width: 26, height: 26),
          const SizedBox(height: 10),
          Text(
            data.title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.4,
              height: 11 / 9.5,
            ),
          ),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 24 / 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: PortalColors.muted,
              height: 12 / 10,
            ),
          ),
        ],
      ),
    );
  }
}
