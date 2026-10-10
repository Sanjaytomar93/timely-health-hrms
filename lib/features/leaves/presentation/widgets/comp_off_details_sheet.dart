import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/leaves/presentation/models/leave_ui_model.dart';

Future<void> showCompOffDetailsSheet(
  BuildContext context, {
  required LeaveHistoryUiModel item,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x70000000),
    builder: (_) => CompOffDetailsSheet(item: item),
  );
}

class CompOffDetailsSheet extends StatelessWidget {
  const CompOffDetailsSheet({super.key, required this.item});

  final LeaveHistoryUiModel item;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth = (width - 35).clamp(300.0, 405.0);
    final daysLabel = item.days == item.days.roundToDouble()
        ? item.days.toInt().toString()
        : item.days.toString();
    final showExtra = item.isConvertedToCompOff;
    final showApproved =
        item.statusRaw.toLowerCase() == 'approved' &&
        (item.approvedBy != null || item.approvedAtLabel != null);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Comp-off Details',
                          style: portalText(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF9234EA),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE9E7F2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: PortalColors.border),
                    const SizedBox(height: 14),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: item.statusBg,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Status: ${item.status}',
                          style: portalText(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: item.statusColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Box(
                      color: const Color(0xFFF9FAFB),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request ID',
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6C7280),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.id.isEmpty ? '—' : item.id,
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF202020),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Box(
                      color: const Color(0xFFF1FDF4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leave Details',
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0E6C46),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _KvRow(
                            label: 'Type :',
                            value: item.type.isEmpty ? '—' : item.type,
                          ),
                          const SizedBox(height: 12),
                          _KvRow(
                            label: 'Start :',
                            value: LeaveUiMapper.dateLabelDetail(
                              item.startDate,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _KvRow(
                            label: 'End :',
                            value: LeaveUiMapper.dateLabelDetail(item.endDate),
                          ),
                          const SizedBox(height: 12),
                          _KvRow(label: 'Days :', value: daysLabel),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'Leaves Status :',
                                style: portalText(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: PortalColors.muted,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: item.statusBg,
                                  borderRadius: BorderRadius.circular(31),
                                  border: Border.all(
                                    color: item.statusColor.withValues(
                                      alpha: 0.24,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  item.status,
                                  style: portalText(
                                    fontSize: 8,
                                    color: item.statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (showExtra) ...[
                      const SizedBox(height: 12),
                      _Box(
                        color: const Color(0xFFFAF5FF),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Extra Day Details:',
                              style: portalText(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9234EA),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _KvRow(
                              label: 'Date :',
                              value: item.extraDayDateLabel ?? '—',
                            ),
                            const SizedBox(height: 12),
                            _KvRow(
                              label: 'Total Hours :',
                              value: item.totalHoursLabel ?? '—',
                            ),
                            const SizedBox(height: 12),
                            _KvRow(
                              label: 'Extra Hours :',
                              value: item.extraHoursLabel ?? '—',
                              valueColor: item.extraHoursLabel != null
                                  ? PortalColors.green
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _Box(
                      color: const Color(0xFFF9FAFB),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reason:',
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.reason,
                            style: portalText(
                              fontSize: 10,
                              color: PortalColors.muted,
                              height: 1.64,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetaCard(
                            label: 'Created',
                            value: item.createdLabel ?? '—',
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _MetaCard(
                            label: 'Updated',
                            value: item.updatedLabel ?? '—',
                          ),
                        ),
                      ],
                    ),
                    if (showApproved) ...[
                      const SizedBox(height: 12),
                      _Box(
                        color: const Color(0xFFF1FDF4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Approved by: ${item.approvedBy ?? '—'}',
                              style: portalText(
                                fontSize: 10,
                                color: PortalColors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Approved at: ${item.approvedAtLabel ?? '—'}',
                              style: portalText(
                                fontSize: 10,
                                color: const Color(0xFF158558),
                                height: 1.64,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 4, 48, 22),
              child: SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PortalColors.brand,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: PortalColors.brand,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PortalColors.border),
      ),
      child: child,
    );
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF7D7D7D),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _KvRow extends StatelessWidget {
  const _KvRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: portalText(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: PortalColors.muted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: portalText(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF38373B),
          ),
        ),
      ],
    );
  }
}
