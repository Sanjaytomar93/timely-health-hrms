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
            title: 'Patients',
            value: '2',
            subtitle: 'Active: 2',
            accent: OpColors.green,
            icon: Icons.groups_rounded,
            tint: OpColors.greenTint,
          ),
          OpMetricUi(
            title: 'Paid',
            value: '2',
            subtitle: 'Completed p...',
            accent: OpColors.green,
            icon: Icons.check_circle_rounded,
            tint: OpColors.greenTint,
          ),
          OpMetricUi(
            title: 'Partial',
            value: '0',
            subtitle: 'Partially paid',
            accent: OpColors.orange,
            icon: Icons.schedule_rounded,
            tint: OpColors.orangeTint,
          ),
          OpMetricUi(
            title: 'Due',
            value: '0',
            subtitle: 'Overdue payments',
            accent: OpColors.orange,
            icon: Icons.warning_amber_rounded,
            tint: OpColors.orangeTint,
          ),
          OpMetricUi(
            title: 'Collected',
            value: '₹1.3k',
            subtitle: 'Total revenue',
            accent: OpColors.primary,
            icon: Icons.account_balance_wallet_rounded,
            tint: OpColors.primaryTint,
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
