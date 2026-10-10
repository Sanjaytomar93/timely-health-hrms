import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/features/leaves/domain/entities/employee_leaves.dart';
import 'package:timelay_health/features/leaves/domain/entities/leave_record.dart';

class LeaveStatsUiModel extends Equatable {
  const LeaveStatsUiModel({
    required this.total,
    required this.approved,
    required this.pending,
    required this.rejected,
    required this.compOff,
    this.casual = 0,
    this.sick = 0,
    this.earned = 0,
    this.assignedDays = 0,
    this.presentDays = 0,
    this.absentDays = 0,
    this.extraDays = 0,
  });

  final int total;
  final int approved;
  final int pending;
  final int rejected;
  final int compOff;
  final int casual;
  final int sick;
  final int earned;
  final int assignedDays;
  final int presentDays;
  final int absentDays;
  final int extraDays;

  static const empty = LeaveStatsUiModel(
    total: 0,
    approved: 0,
    pending: 0,
    rejected: 0,
    compOff: 0,
  );

  @override
  List<Object?> get props => [
    total,
    approved,
    pending,
    rejected,
    compOff,
    casual,
    sick,
    earned,
    assignedDays,
    presentDays,
    absentDays,
    extraDays,
  ];
}

class LeaveHistoryUiModel extends Equatable {
  const LeaveHistoryUiModel({
    required this.id,
    required this.type,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.range,
    required this.note,
    required this.footer,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    required this.leaveTypeRaw,
    required this.statusRaw,
    required this.isConvertedToCompOff,
    this.createdLabel,
    this.updatedLabel,
    this.approvedBy,
    this.approvedAtLabel,
    this.extraDayDateLabel,
    this.totalHoursLabel,
    this.extraHoursLabel,
  });

  final String id;
  final String type;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final String range;
  final String note;
  final String footer;
  final DateTime? startDate;
  final DateTime? endDate;
  final double days;
  final String reason;
  final String leaveTypeRaw;
  final String statusRaw;
  final bool isConvertedToCompOff;
  final String? createdLabel;
  final String? updatedLabel;
  final String? approvedBy;
  final String? approvedAtLabel;
  final String? extraDayDateLabel;
  final String? totalHoursLabel;
  final String? extraHoursLabel;

  @override
  List<Object?> get props => [
    id,
    type,
    status,
    range,
    note,
    footer,
    startDate,
    endDate,
    days,
    reason,
    leaveTypeRaw,
    statusRaw,
    isConvertedToCompOff,
    createdLabel,
    updatedLabel,
    approvedBy,
    approvedAtLabel,
    extraDayDateLabel,
    totalHoursLabel,
    extraHoursLabel,
  ];
}

class LeaveUiMapper {
  const LeaveUiMapper._();

  static List<LeaveHistoryUiModel> toUiList(List<LeaveRecord> records) {
    return records.map(toUi).toList();
  }

  static LeaveHistoryUiModel toUi(LeaveRecord record) {
    final status = _titleCase(record.status);
    final colors = _statusColors(record.status);
    final approvedBy = record.approvedBy?.trim();
    final compOff = record.isConvertedToCompOff ? 'Approved' : 'Not Applied';
    final footer = (approvedBy != null && approvedBy.isNotEmpty)
        ? 'Approved by $approvedBy · Comp-off: $compOff'
        : 'Comp-off: $compOff';

    return LeaveHistoryUiModel(
      id: record.id,
      type: _titleCase(record.leaveType),
      status: status.isEmpty ? 'Pending' : status,
      statusColor: colors.$1,
      statusBg: colors.$2,
      range:
          '${_dateLabelUpper(record.startDate)} → ${_dateLabelUpper(record.endDate)}',
      note: record.reason.trim().isEmpty ? '—' : record.reason.trim(),
      footer: footer,
      startDate: record.startDate,
      endDate: record.endDate,
      days: record.days,
      reason: record.reason.trim().isEmpty ? '—' : record.reason.trim(),
      leaveTypeRaw: record.leaveType,
      statusRaw: record.status,
      isConvertedToCompOff: record.isConvertedToCompOff,
      createdLabel: _dateLabelPretty(record.appliedDate),
      updatedLabel: _dateLabelPretty(record.approvedDate ?? record.appliedDate),
      approvedBy: (approvedBy != null && approvedBy.isNotEmpty)
          ? approvedBy
          : (record.approvedByRole?.trim().isNotEmpty == true
                ? record.approvedByRole!.trim()
                : null),
      approvedAtLabel: _dateLabelPretty(record.approvedDate),
    );
  }

  static LeaveStatsUiModel toStats(LeaveStats s) {
    return LeaveStatsUiModel(
      total: s.totalLeaves,
      approved: s.approvedLeaves,
      pending: s.pendingLeaves,
      rejected: s.rejectedLeaves,
      compOff: s.compOffLeaves,
      casual: s.casualLeaves,
      sick: s.sickLeaves,
      earned: s.earnedLeaves,
      assignedDays: s.totalAssignedDays,
      presentDays: s.presentDays,
      absentDays: s.absentDays,
      extraDays: s.extraDaysWorked,
    );
  }

  static (Color, Color) _statusColors(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return (PortalColors.green, PortalColors.greenTint);
      case 'rejected':
        return (PortalColors.red, PortalColors.redTint);
      case 'pending':
      default:
        return (PortalColors.orange, const Color(0xFFFFF4E5));
    }
  }

  static String _titleCase(String value) {
    final v = value.trim();
    if (v.isEmpty) return v;
    if (v.length == 1) return v.toUpperCase();
    return '${v[0].toUpperCase()}${v.substring(1).toLowerCase()}';
  }

  static String _dateLabelUpper(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final day = local.day.toString().padLeft(2, '0');
    return '$day ${months[local.month - 1]} ${local.year}';
  }

  static String? _dateLabelPretty(DateTime? date) {
    if (date == null) return null;
    final local = date.toLocal();
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
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  static String dateLabelDetail(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
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
    final day = local.day.toString().padLeft(2, '0');
    return '$day ${months[local.month - 1]} ${local.year}';
  }
}
