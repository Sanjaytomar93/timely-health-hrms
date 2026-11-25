import 'package:flutter/material.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_dashboard_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';

class OpWalkinPatientUi {
  const OpWalkinPatientUi({
    required this.index,
    required this.pid,
    required this.createdDate,
    required this.createdTime,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.doctor,
    required this.visitDate,
    required this.rType,
    required this.status,
    required this.clinic,
    required this.lab,
    required this.pharmacy,
    required this.total,
    required this.discount,
    required this.due,
    required this.paid,
    required this.payType,
    required this.payStatus,
    required this.referredCustomer,
    required this.referredDoctor,
    required this.bookedBy,
    required this.bookedByCode,
  });

  final int index;
  final String pid;
  final String createdDate;
  final String createdTime;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String doctor;
  final String visitDate;
  final String rType;
  final String status;
  final String clinic;
  final String lab;
  final String pharmacy;
  final String total;
  final String discount;
  final String due;
  final String paid;
  final String payType;
  final String payStatus;
  final String referredCustomer;
  final String referredDoctor;
  final String bookedBy;
  final String bookedByCode;

  String get initial {
    final parts = name.trim().split(RegExp(r'\s+'));
    for (final p in parts.reversed) {
      if (p.isEmpty) continue;
      final c = p[0].toUpperCase();
      if (RegExp(r'[A-Z]').hasMatch(c)) return c;
    }
    return '#';
  }

  Color get payStatusColor =>
      payStatus.toUpperCase() == 'PAID' ? OpColors.green : OpColors.orange;

  factory OpWalkinPatientUi.fromJson(
    Map<String, dynamic> json, {
    int index = 1,
  }) {
    final title = (json['patientTitle']?.toString() ?? '').trim();
    final pName = (json['patientName']?.toString() ?? '').trim();
    final displayName = title.isNotEmpty
        ? (pName.toLowerCase().startsWith(title.toLowerCase())
            ? pName
            : '$title $pName')
        : (pName.isNotEmpty ? pName : 'Unknown Patient');

    final slot = json['slotDetails'] is Map<String, dynamic>
        ? json['slotDetails'] as Map<String, dynamic>
        : null;

    final docName = slot?['doctorName']?.toString().trim();
    final doctor = (docName != null && docName.isNotEmpty) ? docName : 'N/A';

    final startTime = slot?['startTime']?.toString().trim() ?? '';
    final endTime = slot?['endTime']?.toString().trim() ?? '';
    String visitDate = 'N/A';
    if (startTime.isNotEmpty && endTime.isNotEmpty) {
      visitDate = '$startTime – $endTime';
    } else if (startTime.isNotEmpty) {
      visitDate = startTime;
    }

    final createdRaw = json['createdAt']?.toString() ??
        json['bookedAt']?.toString() ??
        '';
    String createdDate = '';
    String createdTime = '';
    if (createdRaw.isNotEmpty) {
      try {
        final dt = DateTime.tryParse(createdRaw)?.toLocal();
        if (dt != null) {
          createdDate =
              '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year.toString().substring(2)}';
          final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
          final minute = dt.minute.toString().padLeft(2, '0');
          final amPm = dt.hour >= 12 ? 'pm' : 'am';
          createdTime = '$hour:$minute $amPm';
        }
      } catch (_) {}
    }
    if (createdDate.isEmpty) {
      createdDate = json['appointmentDate']?.toString() ?? 'N/A';
    }

    final catPayment = json['categoryPayment'] is Map<String, dynamic>
        ? json['categoryPayment'] as Map<String, dynamic>
        : null;
    final clinicVal = catPayment?['clinic']?['paidAmount'] ?? 0;
    final labVal = catPayment?['lab']?['paidAmount'] ?? 0;
    final pharmVal = catPayment?['pharmacy']?['paidAmount'] ?? 0;

    final totalVal =
        json['finalPayable'] ?? json['totalAmount'] ?? json['totalFee'] ?? 0;
    final discountVal = json['discount'] ?? 0;
    final balanceVal = json['balanceAmount'] ?? 0;
    final paidVal = json['amountPaid'] ?? 0;

    final addedBy = json['addedBy'] is Map<String, dynamic>
        ? json['addedBy'] as Map<String, dynamic>
        : null;
    final bookedByName = addedBy?['name']?.toString() ?? 'Staff';
    final bookedByEmpId = addedBy?['empId']?.toString() ?? '';

    final refCustomer = json['referredByCustomer']?.toString().trim() ?? '';
    final refDoctor = json['referredByDoctor']?.toString().trim() ?? '';

    return OpWalkinPatientUi(
      index: index,
      pid: json['customPID']?.toString().trim().isNotEmpty == true
          ? json['customPID'].toString().trim()
          : (json['_id']?.toString() ?? 'PID'),
      createdDate: createdDate,
      createdTime: createdTime,
      name: displayName,
      age: int.tryParse(json['patientAge']?.toString() ?? '') ?? 0,
      gender: json['patientGender']?.toString().trim().isNotEmpty == true
          ? json['patientGender'].toString().trim()
          : 'N/A',
      phone: json['patientPhone']?.toString().trim() ?? '',
      doctor: doctor,
      visitDate: visitDate,
      rType: (json['bookingType']?.toString() ?? 'R-WALKIN').toUpperCase(),
      status: (json['status']?.toString() ?? 'CONFIRMED').toUpperCase(),
      clinic: '₹$clinicVal',
      lab: '₹$labVal',
      pharmacy: '₹$pharmVal',
      total: '₹$totalVal',
      discount:
          (discountVal is num && discountVal > 0) ? '₹$discountVal' : '—',
      due: '₹$balanceVal',
      paid: '₹$paidVal',
      payType: (json['paymentType']?.toString() ?? 'CASH').toUpperCase(),
      payStatus: (json['paymentStatus']?.toString() ?? 'PAID').toUpperCase(),
      referredCustomer:
          refCustomer.isNotEmpty ? 'Ref: $refCustomer' : 'Ref: Self',
      referredDoctor: refDoctor.isNotEmpty ? refDoctor : 'No Doctor',
      bookedBy: bookedByName,
      bookedByCode: bookedByEmpId,
    );
  }
}

class OpWalkinUi {
  const OpWalkinUi({
    required this.periodFilters,
    required this.selectedPeriod,
    required this.metrics,
    required this.patients,
  });

  final List<String> periodFilters;
  final String selectedPeriod;
  final List<OpMetricUi> metrics;
  final List<OpWalkinPatientUi> patients;

  static OpWalkinUi get demo => const OpWalkinUi(
        periodFilters: [
          'All',
          'Today',
          'Yesterday',
          'This Week',
          'Last 7 Days',
          'This Month',
          'Last Month',
          'This Year',
        ],
        selectedPeriod: 'Today',
        metrics: [
          OpMetricUi(
            title: 'TOTAL CLINIC PATIENTS',
            value: '930',
            activeLabel: 'Active: 930',
            inactiveLabel: 'Inactive: 0',
            accent: Color(0xFF4F46E5),
            icon: Icons.people_outline_rounded,
            tint: Color(0xFFEEF2FF),
          ),
          OpMetricUi(
            title: 'PAID',
            value: '906',
            subtitle: 'completed payments',
            accent: Color(0xFF059669),
            icon: Icons.person_outline_rounded,
            tint: Color(0xFFECFDF5),
          ),
          OpMetricUi(
            title: 'PARTIAL',
            value: '5',
            subtitle: 'partially paid',
            accent: Color(0xFF2563EB),
            icon: Icons.access_time_rounded,
            tint: Color(0xFFEFF6FF),
          ),
          OpMetricUi(
            title: 'DUE',
            value: '19',
            subtitle: 'overdue payments',
            accent: Color(0xFFEA580C),
            icon: Icons.cancel_outlined,
            tint: Color(0xFFFFF7ED),
          ),
          OpMetricUi(
            title: 'TOTAL COLLECTED',
            value: '₹8,72,488',
            subtitle: '',
            accent: Color(0xFF059669),
            icon: Icons.currency_rupee_rounded,
            tint: Color(0xFFECFDF5),
          ),
        ],
        patients: [
          OpWalkinPatientUi(
            index: 1,
            pid: 'TH2611109',
            createdDate: '16/11/26',
            createdTime: '12:12 pm',
            name: 'Mrs. ADILAKSHMI',
            age: 40,
            gender: 'Female',
            phone: '9642809761',
            doctor: 'DR VAMSHI KRISHNA',
            visitDate: '12:20 PM – 12:40 PM',
            rType: 'R-WALKIN',
            status: 'CONFIRMED',
            clinic: '₹300',
            lab: '₹100',
            pharmacy: '₹0',
            total: '₹400',
            discount: '—',
            due: '₹0',
            paid: '₹400',
            payType: 'ONLINE',
            payStatus: 'PAID',
            referredCustomer: 'Ref: Self',
            referredDoctor: 'No Doctor',
            bookedBy: 'srikanth',
            bookedByCode: 'TH062',
          ),
          OpWalkinPatientUi(
            index: 2,
            pid: 'TH2611109',
            createdDate: '16/11/26',
            createdTime: '10:49 am',
            name: 'Mr. V SANTOSH KUMAR',
            age: 43,
            gender: 'Male',
            phone: '7813447584',
            doctor: 'N/A (Direct Lab)',
            visitDate: 'N/A',
            rType: 'N-WALKIN',
            status: 'CONFIRMED',
            clinic: '₹0',
            lab: '₹899',
            pharmacy: '₹0',
            total: '₹899',
            discount: '—',
            due: '₹0',
            paid: '₹899',
            payType: 'ONLINE',
            payStatus: 'PAID',
            referredCustomer: 'Ref: Self',
            referredDoctor: 'No Doctor',
            bookedBy: 'srikanth',
            bookedByCode: 'TH062',
          ),
        ],
      );
}
