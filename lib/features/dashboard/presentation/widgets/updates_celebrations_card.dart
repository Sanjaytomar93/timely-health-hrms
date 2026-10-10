import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';

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
    final label = monthLabel ?? '';
    final rows = items;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 30, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 17, 17, 31),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/icons/updates/ic_updates_header.svg',
                width: 18,
                height: 18,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Updates & Celebrations',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 16 / 13,
                  ),
                ),
              ),
              Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 11),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PortalColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PortalColors.border),
                ),
                child: Text(
                  label,
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.secondaryText,
                    height: 13 / 10.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Divider(
              height: 1,
              thickness: 0.8,
              color: PortalColors.border,
            ),
          ),
          const SizedBox(height: 19),
          if (rows.isEmpty)
            Text(
              'No updates right now',
              style: portalText(fontSize: 12, color: PortalColors.muted),
            )
          else
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _UpdateRow(
                item: rows[i],
                onDetails: onDetails == null ? null : () => onDetails!(rows[i]),
              ),
            ],
        ],
      ),
    );
  }
}

class _UpdateRow extends StatelessWidget {
  const _UpdateRow({required this.item, this.onDetails});

  final DashboardUpdateItemUi item;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      decoration: BoxDecoration(
        color: PortalColors.brandTint,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: PortalColors.brand),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 11, 12, 11),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/updates/ic_updates_shift.svg',
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
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
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: PortalColors.brand,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: PortalColors.muted,
                              height: 13 / 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: onDetails,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 23,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: PortalColors.border),
                          ),
                          child: Text(
                            'DETAILS',
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: PortalColors.brand,
                              height: 12 / 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
