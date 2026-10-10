import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:timelay_health/features/visits/domain/entities/visit.dart';

class VisitUiModel extends Equatable {
  const VisitUiModel({
    required this.id,
    required this.index,
    required this.status,
    required this.statusBg,
    required this.statusColor,
    required this.center,
    required this.date,
    required this.contact,
    required this.phone,
    required this.address,
    required this.addressLink,
    required this.remark,
    required this.locationExtra,
    required this.createdAt,
  });

  final String id;
  final String index;
  final String status;
  final Color statusBg;
  final Color statusColor;
  final String center;
  final String date;
  final String contact;
  final String phone;
  final String address;
  final String addressLink;
  final String remark;
  final String? locationExtra;
  final DateTime? createdAt;

  String get remarksValue => remark == '--' ? '' : remark;

  @override
  List<Object?> get props => [
    id,
    index,
    status,
    center,
    date,
    contact,
    phone,
    address,
    addressLink,
    remark,
    locationExtra,
    createdAt,
  ];
}

class VisitStatsUiModel extends Equatable {
  const VisitStatsUiModel({
    required this.total,
    required this.pending,
    required this.leads,
    required this.rejected,
  });

  final int total;
  final int pending;
  final int leads;
  final int rejected;

  static const empty = VisitStatsUiModel(
    total: 0,
    pending: 0,
    leads: 0,
    rejected: 0,
  );

  @override
  List<Object?> get props => [total, pending, leads, rejected];
}

class VisitUiMapper {
  const VisitUiMapper._();

  static List<VisitUiModel> toUiList(List<Visit> visits) {
    return [for (var i = 0; i < visits.length; i++) toUi(visits[i], i + 1)];
  }

  static VisitUiModel toUi(Visit visit, int index) {
    final colors = _statusColors(visit.status);
    return VisitUiModel(
      id: visit.id,
      index: '#$index',
      status: visit.status.isEmpty ? 'Pending' : visit.status,
      statusBg: colors.$1,
      statusColor: colors.$2,
      center: visit.centerName.isEmpty ? '—' : visit.centerName,
      date: _dateLabel(visit.createdAt),
      contact: visit.clientName.isEmpty ? '—' : visit.clientName,
      phone: visit.contact.isEmpty ? '—' : visit.contact,
      address: visit.address.isEmpty ? '—' : visit.address,
      addressLink: visit.addressLink,
      remark: visit.remarks.trim().isEmpty ? '--' : visit.remarks.trim(),
      locationExtra: visit.employeeLocation != null ? 'My location' : null,
      createdAt: visit.createdAt,
    );
  }

  static VisitStatsUiModel toStatsFromUi(List<VisitUiModel> visits) {
    var pending = 0;
    var leads = 0;
    var rejected = 0;
    for (final v in visits) {
      switch (v.status.toLowerCase()) {
        case 'pending':
          pending++;
        case 'lead':
          leads++;
        case 'rejected':
          rejected++;
      }
    }
    return VisitStatsUiModel(
      total: visits.length,
      pending: pending,
      leads: leads,
      rejected: rejected,
    );
  }

  static VisitStatsUiModel toStats(List<Visit> visits) {
    var pending = 0;
    var leads = 0;
    var rejected = 0;
    for (final v in visits) {
      switch (v.status.toLowerCase()) {
        case 'pending':
          pending++;
        case 'lead':
          leads++;
        case 'rejected':
          rejected++;
      }
    }
    return VisitStatsUiModel(
      total: visits.length,
      pending: pending,
      leads: leads,
      rejected: rejected,
    );
  }

  static (Color, Color) _statusColors(String status) {
    switch (status.toLowerCase()) {
      case 'lead':
        return (const Color(0x36319DF0), const Color(0xFF319DF0));
      case 'rejected':
        return (const Color(0xFFFEECEC), const Color(0xFFE0483E));
      case 'pending':
      default:
        return (const Color(0xFFFEF4E3), const Color(0xFFF0A831));
    }
  }

  static String _dateLabel(DateTime? date) {
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
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  static String? monthLabel(DateTime? date) {
    if (date == null) return null;
    final local = date.toLocal();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[local.month - 1]} ${local.year}';
  }
}
