import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/leaves/presentation/models/leave_ui_model.dart';
import 'package:timelay_health/features/leaves/presentation/widgets/comp_off_details_sheet.dart';
import 'package:timelay_health/features/leaves/presentation/widgets/leave_empty_state.dart';

class LeaveHistoryList extends StatelessWidget {
  const LeaveHistoryList({super.key, this.items = const []});

  final List<LeaveHistoryUiModel> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Column(
        children: [
          if (items.isEmpty)
            const LeaveEmptyState(
              title: 'No leave records yet',
              subtitle: 'Your leave applications will appear here.',
            )
          else
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _LeaveCard(item: items[i]),
            ],
          const SizedBox(height: 12),
          Text(
            'Showing ${items.length} of ${items.length} records',
            textAlign: TextAlign.center,
            style: portalText(fontSize: 11, color: PortalColors.muted),
          ),
        ],
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.item});

  final LeaveHistoryUiModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DotLabel(color: PortalColors.purpleNav, text: item.type),
              const Spacer(),
              Container(
                height: 17,
                padding: const EdgeInsets.symmetric(horizontal: 9),
                decoration: BoxDecoration(
                  color: item.statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: item.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.status,
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: item.statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.range,
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.note,
            style: portalText(fontSize: 10, color: PortalColors.muted),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: PortalColors.border),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.footer,
                  style: portalText(fontSize: 10.5, color: PortalColors.muted),
                ),
              ),
              InkWell(
                onTap: () => showCompOffDetailsSheet(context, item: item),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: SvgPicture.asset(
                    'assets/icons/leaves/ic_view.svg',
                    width: 18,
                    height: 18,
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

class _DotLabel extends StatelessWidget {
  const _DotLabel({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: portalText(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
