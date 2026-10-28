import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/leaves/domain/entities/comp_off_request.dart';
import 'package:timelay_health/features/leaves/presentation/widgets/leave_empty_state.dart';

class CompOffRequestsTable extends StatelessWidget {
  const CompOffRequestsTable({super.key, required this.requests});

  final CompOffRequests requests;

  @override
  Widget build(BuildContext context) {
    final records = requests.records;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Column(
        children: [
          if (records.isEmpty)
            const LeaveEmptyState(
              title: 'No Comp Off requests yet',
              subtitle: 'When you raise a comp-off, it will show up here.',
            )
          else
            for (var i = 0; i < records.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _CompOffCard(item: records[i]),
            ],
          const SizedBox(height: 12),
          Text(
            'Showing ${records.length} of ${records.length} records',
            textAlign: TextAlign.center,
            style: portalText(fontSize: 11, color: PortalColors.muted),
          ),
        ],
      ),
    );
  }
}

class _CompOffCard extends StatelessWidget {
  const _CompOffCard({required this.item});

  final CompOffRequest item;

  @override
  Widget build(BuildContext context) {
    final workType = item.workType?.isNotEmpty == true
        ? item.workType!
        : 'Extra Work';
    final reviewer = item.approvedBy?.isNotEmpty == true
        ? 'Approved by ${item.approvedBy}'
        : 'Requested ${_formatDate(item.requestedOn)}';

    return Container(
      height: 134,
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 17,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _WorkTypeLabel(text: workType),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _StatusBadge(status: item.status),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_formatDate(item.workDate)}  →  ${_formatDate(item.leaveDate)}',
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.reason.isEmpty ? '—' : item.reason,
            style: portalText(fontSize: 10, color: PortalColors.muted),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: PortalColors.border),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Comp-off: ${_titleCase(item.status)}',
                  overflow: TextOverflow.ellipsis,
                  style: portalText(fontSize: 10.5, color: PortalColors.muted),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reviewer,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: portalText(
                    fontSize: 10.5,
                    color: item.status.toLowerCase() == 'approved'
                        ? const Color(0xFF1FA971)
                        : PortalColors.muted,
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

String _formatDate(DateTime? date) {
  if (date == null) return '—';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

String _titleCase(String value) {
  final text = value.trim();
  if (text.isEmpty) return 'Pending';
  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}

class _WorkTypeLabel extends StatelessWidget {
  const _WorkTypeLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 5,
        height: 5,
        decoration: const BoxDecoration(
          color: PortalColors.purpleNav,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: portalText(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: PortalColors.purpleNav,
          ),
        ),
      ),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = normalized == 'approved'
        ? const Color(0xFF1FA971)
        : normalized == 'rejected'
        ? const Color(0xFFE5484D)
        : const Color(0xFFD99700);
    final background = normalized == 'approved'
        ? const Color(0xFFE7F7F0)
        : normalized == 'rejected'
        ? const Color(0xFFFFE3E4)
        : const Color(0xFFFFF5C7);
    return Container(
      height: 17,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status.isEmpty
                ? 'Pending'
                : '${status[0].toUpperCase()}${status.substring(1)}',
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
