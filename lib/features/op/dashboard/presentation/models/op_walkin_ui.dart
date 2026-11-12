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
          'Today',
          'Yesterday',
          'This Week',
          'Last 7 Days',
          'This Month',
          'Last Month',
          'This Year',
          'All',
        ],
        selectedPeriod: 'Today',
        metrics: [
          OpMetricUi(
            title: 'Patients',
            value: '7',
            subtitle: 'active today',
            accent: OpColors.green,
            icon: Icons.groups_rounded,
            tint: OpColors.greenTint,
          ),
          OpMetricUi(
            title: 'Paid',
            value: '7',
            subtitle: 'completed',
            accent: OpColors.green,
            icon: Icons.check_circle_rounded,
            tint: OpColors.greenTint,
          ),
          OpMetricUi(
            title: 'Partial',
            value: '0',
            subtitle: 'partially paid',
            accent: OpColors.orange,
            icon: Icons.schedule_rounded,
            tint: OpColors.orangeTint,
          ),
          OpMetricUi(
            title: 'Due',
            value: '0',
            subtitle: 'overdue',
            accent: OpColors.red,
            icon: Icons.error_rounded,
            tint: OpColors.redTint,
          ),
          OpMetricUi(
            title: 'Collected',
            value: '₹6,910',
            subtitle: 'clinic · lab · pharmacy',
            accent: OpColors.primary,
            icon: Icons.currency_rupee_rounded,
            tint: OpColors.primaryTint,
            wide: true,
          ),
        ],
        patients: [
          OpWalkinPatientUi(
            index: 1,
            pid: 'TH251184',
            createdDate: '09/11/24',
            createdTime: '01:56 pm',
            name: 'Miss SHIRISHA',
            age: 16,
            gender: 'Female',
            phone: '8106338650',
            doctor: 'N/A',
            visitDate: '09/11/24',
            rType: 'R-WALKIN',
            status: 'CONFIRMED',
            clinic: '₹0',
            lab: '₹2910',
            pharmacy: '₹0',
            total: '₹2910',
            discount: '—',
            due: '₹0',
            paid: '₹2910',
            payType: 'ONLINE',
            payStatus: 'PAID',
            referredCustomer: 'No Customer',
            referredDoctor: 'No Doctor',
            bookedBy: 'K Akhill Kumar',
            bookedByCode: 'TX906',
          ),
          OpWalkinPatientUi(
            index: 2,
            pid: 'TH251185',
            createdDate: '09/11/24',
            createdTime: '02:18 pm',
            name: 'Mr RAVI TEJA',
            age: 41,
            gender: 'Male',
            phone: '9123456780',
            doctor: 'Dr. Vamshi Krishna',
            visitDate: '09/11/24',
            rType: 'N-WALKIN',
            status: 'CONFIRMED',
            clinic: '₹700',
            lab: '₹0',
            pharmacy: '₹0',
            total: '₹700',
            discount: '—',
            due: '₹0',
            paid: '₹700',
            payType: 'CASH',
            payStatus: 'PAID',
            referredCustomer: 'Self',
            referredDoctor: 'No Doctor',
            bookedBy: 'Front Desk',
            bookedByCode: 'TX901',
          ),
          OpWalkinPatientUi(
            index: 3,
            pid: 'TH251186',
            createdDate: '09/11/24',
            createdTime: '02:45 pm',
            name: 'Mrs SNEHA REDDY',
            age: 32,
            gender: 'Female',
            phone: '9988776655',
            doctor: 'Dr. Priya Nair',
            visitDate: '09/11/24',
            rType: 'R-WALKIN',
            status: 'CONFIRMED',
            clinic: '₹500',
            lab: '₹800',
            pharmacy: '₹200',
            total: '₹1500',
            discount: '₹50',
            due: '₹0',
            paid: '₹1450',
            payType: 'ONLINE',
            payStatus: 'PAID',
            referredCustomer: 'No Customer',
            referredDoctor: 'Dr. Rao',
            bookedBy: 'K Akhill Kumar',
            bookedByCode: 'TX906',
          ),
          OpWalkinPatientUi(
            index: 4,
            pid: 'TH251187',
            createdDate: '09/11/24',
            createdTime: '03:10 pm',
            name: 'Mr VIKRAM JOSHI',
            age: 48,
            gender: 'Male',
            phone: '9654321098',
            doctor: 'Dr. Mehta',
            visitDate: '09/11/24',
            rType: 'N-WALKIN',
            status: 'CONFIRMED',
            clinic: '₹860',
            lab: '₹300',
            pharmacy: '₹0',
            total: '₹1160',
            discount: '—',
            due: '₹0',
            paid: '₹1160',
            payType: 'CARD',
            payStatus: 'PAID',
            referredCustomer: 'Camp',
            referredDoctor: 'No Doctor',
            bookedBy: 'Reception',
            bookedByCode: 'TX910',
          ),
          OpWalkinPatientUi(
            index: 5,
            pid: 'TH251188',
            createdDate: '09/11/24',
            createdTime: '03:42 pm',
            name: 'Miss ANANYA DAS',
            age: 25,
            gender: 'Female',
            phone: '9012345678',
            doctor: 'N/A',
            visitDate: '09/11/24',
            rType: 'R-WALKIN',
            status: 'CONFIRMED',
            clinic: '₹600',
            lab: '₹0',
            pharmacy: '₹0',
            total: '₹600',
            discount: '—',
            due: '₹0',
            paid: '₹600',
            payType: 'ONLINE',
            payStatus: 'PAID',
            referredCustomer: 'No Customer',
            referredDoctor: 'No Doctor',
            bookedBy: 'App',
            bookedByCode: 'TX912',
          ),
          OpWalkinPatientUi(
            index: 6,
            pid: 'TH251189',
            createdDate: '09/11/24',
            createdTime: '04:05 pm',
            name: 'Mr MOHAMMED IRFAN',
            age: 36,
            gender: 'Male',
            phone: '9876501234',
            doctor: 'Dr. Vamshi Krishna',
            visitDate: '09/11/24',
            rType: 'R-WALKIN',
            status: 'CONFIRMED',
            clinic: '₹800',
            lab: '₹500',
            pharmacy: '₹0',
            total: '₹1300',
            discount: '—',
            due: '₹0',
            paid: '₹1300',
            payType: 'ONLINE',
            payStatus: 'PAID',
            referredCustomer: 'No Customer',
            referredDoctor: 'Dr. Mehta',
            bookedBy: 'K Akhill Kumar',
            bookedByCode: 'TX906',
          ),
          OpWalkinPatientUi(
            index: 7,
            pid: 'TH251190',
            createdDate: '09/11/24',
            createdTime: '04:28 pm',
            name: 'Mrs LAKSHMI PRIYA',
            age: 29,
            gender: 'Female',
            phone: '9765432109',
            doctor: 'Dr. Priya Nair',
            visitDate: '09/11/24',
            rType: 'N-WALKIN',
            status: 'CONFIRMED',
            clinic: '₹550',
            lab: '₹0',
            pharmacy: '₹0',
            total: '₹550',
            discount: '—',
            due: '₹0',
            paid: '₹550',
            payType: 'CASH',
            payStatus: 'PAID',
            referredCustomer: 'Self',
            referredDoctor: 'No Doctor',
            bookedBy: 'Front Desk',
            bookedByCode: 'TX901',
          ),
        ],
      );
}
