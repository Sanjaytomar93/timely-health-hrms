import 'package:flutter/material.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';

class OpQuickActionUi {
  const OpQuickActionUi({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.tint,
    this.tabIndex,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color tint;
  final int? tabIndex;
}

class OpMetricUi {
  const OpMetricUi({
    required this.title,
    required this.value,
    required this.accent,
    required this.icon,
    required this.tint,
    this.subtitle = '',
    this.activeLabel,
    this.inactiveLabel,
    this.wide = false,
    this.breakdown = const [],
  });

  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final Color tint;
  final String? activeLabel;
  final String? inactiveLabel;
  final bool wide;
  final List<({String label, String value, Color color})> breakdown;
}

class OpSliceUi {
  const OpSliceUi({
    required this.label,
    required this.count,
    required this.percent,
    required this.color,
  });

  final String label;
  final int count;
  final double percent;
  final Color color;
}

class OpMonthRevenueUi {
  const OpMonthRevenueUi({
    required this.label,
    required this.opd,
    required this.lab,
    required this.pharmacy,
  });

  final String label;
  final double opd;
  final double lab;
  final double pharmacy;
}

class OpSummaryRowUi {
  const OpSummaryRowUi({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}

class OpPatientUi {
  const OpPatientUi({
    required this.name,
    required this.id,
    required this.age,
    required this.gender,
    required this.status,
    required this.amount,
    required this.doctor,
    required this.date,
    required this.statusColor,
  });

  final String name;
  final String id;
  final int age;
  final String gender;
  final String status;
  final String amount;
  final String doctor;
  final String date;
  final Color statusColor;
}

class OpBookingUi {
  const OpBookingUi({
    required this.patient,
    required this.doctor,
    required this.slot,
    required this.dept,
    required this.status,
    required this.statusColor,
  });

  final String patient;
  final String doctor;
  final String slot;
  final String dept;
  final String status;
  final Color statusColor;
}

class OpRevenueChannelUi {
  const OpRevenueChannelUi({
    required this.title,
    required this.icon,
    required this.footfall,
    required this.amount,
    required this.bg,
    required this.accent,
    required this.lines,
    this.isTotal = false,
  });

  final String title;
  final IconData icon;
  final int footfall;
  final String amount;
  final Color bg;
  final Color accent;
  final List<({String label, String value, Color color})> lines;
  final bool isTotal;
}

class OpDashboardUi {
  const OpDashboardUi({
    required this.greeting,
    required this.fyLabel,
    required this.periodFilters,
    required this.selectedPeriod,
    required this.quickActions,
    required this.metrics,
    required this.trend,
    required this.summaryRows,
    required this.paymentStatus,
    required this.paymentModes,
    required this.gender,
    required this.genderTotal,
    required this.fyTrend,
    required this.fyFooter,
    required this.patients,
    required this.bookings,
    required this.revenueChannels,
  });

  final String greeting;
  final String fyLabel;
  final List<String> periodFilters;
  final String selectedPeriod;
  final List<OpQuickActionUi> quickActions;
  final List<OpMetricUi> metrics;
  final List<OpMonthRevenueUi> trend;
  final List<OpSummaryRowUi> summaryRows;
  final List<OpSliceUi> paymentStatus;
  final List<OpSliceUi> paymentModes;
  final List<OpSliceUi> gender;
  final int genderTotal;
  final List<OpMonthRevenueUi> fyTrend;
  final List<OpSummaryRowUi> fyFooter;
  final List<OpPatientUi> patients;
  final List<OpBookingUi> bookings;
  final List<OpRevenueChannelUi> revenueChannels;

  static OpDashboardUi get demo {
    final hour = DateTime.now().hour;
    final greet = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return OpDashboardUi(
      greeting: '$greet 👋',
      fyLabel: 'FY 2025-26',
      periodFilters: const [
        'All',
        'Today',
        'Yesterday',
        'This Week',
        'This Month',
        'Last Month',
        'This Year',
      ],
      selectedPeriod: 'All',
      quickActions: const [
        OpQuickActionUi(
          label: 'Doctors',
          subtitle: '12 active doctors',
          icon: Icons.medical_services_outlined,
          accent: Color(0xFF3B82F6),
          tint: Color(0xFFEAF2FF),
          tabIndex: 4,
        ),
        OpQuickActionUi(
          label: 'Slots',
          subtitle: '48 slots today',
          icon: Icons.calendar_month_outlined,
          accent: Color(0xFFA855F7),
          tint: Color(0xFFF3E8FF),
          tabIndex: 4,
        ),
        OpQuickActionUi(
          label: 'Walkin',
          subtitle: '46 outpatient visits',
          icon: Icons.directions_walk_rounded,
          accent: Color(0xFF22C55E),
          tint: Color(0xFFE8F8EF),
          tabIndex: 1,
        ),
        OpQuickActionUi(
          label: 'Bookings',
          subtitle: '64 appointments',
          icon: Icons.menu_book_outlined,
          accent: Color(0xFFF59E0B),
          tint: Color(0xFFFFF6E5),
          tabIndex: 2,
        ),
      ],
      metrics: const [
        OpMetricUi(
          title: 'TOTAL CLINIC PATIENTS',
          value: '800',
          accent: Color(0xFF3B82F6),
          icon: Icons.groups_rounded,
          tint: Color(0xFFE8F1FF),
          activeLabel: 'Active: 800',
          inactiveLabel: 'Inactive: 0',
        ),
        OpMetricUi(
          title: 'PAID',
          value: '780',
          subtitle: 'Completed payments',
          accent: Color(0xFF22C55E),
          icon: Icons.check_circle_rounded,
          tint: Color(0xFFE8F8EF),
        ),
        OpMetricUi(
          title: 'PARTIAL',
          value: '1',
          subtitle: 'Partially paid',
          accent: Color(0xFF3B82F6),
          icon: Icons.schedule_rounded,
          tint: Color(0xFFE8F1FF),
        ),
        OpMetricUi(
          title: 'PENDING',
          value: '0',
          subtitle: 'Awaiting payment',
          accent: Color(0xFFF59E0B),
          icon: Icons.access_time_rounded,
          tint: Color(0xFFFFF4E5),
        ),
        OpMetricUi(
          title: 'DUE',
          value: '19',
          subtitle: 'Overdue payments',
          accent: Color(0xFFEF4444),
          icon: Icons.error_rounded,
          tint: Color(0xFFFEECEC),
        ),
        OpMetricUi(
          title: 'TOTAL COLLECTED',
          value: '₹7,65,670',
          accent: Color(0xFF22C55E),
          icon: Icons.currency_rupee_rounded,
          tint: Color(0xFFE8F8EF),
          breakdown: [
            (label: 'Clinic', value: '₹1,88,500', color: Color(0xFF3B82F6)),
            (label: 'Lab', value: '₹4,75,377', color: Color(0xFFA855F7)),
            (label: 'Pharmacy', value: '₹1,01,793', color: Color(0xFF22C55E)),
          ],
        ),
      ],
      trend: const [
        OpMonthRevenueUi(label: 'Apr', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'May', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Jun', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Jul', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Aug', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Sep', opd: 130000, lab: 250000, pharmacy: 20000),
        OpMonthRevenueUi(label: 'Oct', opd: 120000, lab: 200000, pharmacy: 110000),
        OpMonthRevenueUi(label: 'Nov', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Dec', opd: 40000, lab: 70000, pharmacy: 35000),
        OpMonthRevenueUi(label: 'Jan', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Feb', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Mar', opd: 0, lab: 0, pharmacy: 0),
      ],
      summaryRows: const [
        OpSummaryRowUi(label: 'Total Patients', value: '800', color: OpColors.blue),
        OpSummaryRowUi(
          label: 'Total Collective',
          value: '₹7,65,670',
          color: OpColors.green,
        ),
        OpSummaryRowUi(label: 'Total Due', value: '₹11,463', color: OpColors.red),
        OpSummaryRowUi(label: 'Refund', value: '0', color: OpColors.purple),
        OpSummaryRowUi(label: 'Offers Applied', value: '1', color: OpColors.orange),
      ],
      paymentStatus: const [
        OpSliceUi(label: 'Paid', count: 780, percent: 97.5, color: OpColors.green),
        OpSliceUi(label: 'Partial', count: 1, percent: 0.1, color: OpColors.orange),
        OpSliceUi(label: 'Pending', count: 19, percent: 2.4, color: OpColors.red),
      ],
      paymentModes: const [
        OpSliceUi(label: 'Cash', count: 236, percent: 30.3, color: OpColors.green),
        OpSliceUi(label: 'Online', count: 542, percent: 69.5, color: OpColors.purple),
        OpSliceUi(label: 'Insurance', count: 1, percent: 0.1, color: OpColors.blue),
        OpSliceUi(label: 'Card', count: 1, percent: 0.1, color: OpColors.cyan),
      ],
      gender: const [
        OpSliceUi(
          label: 'Male',
          count: 426,
          percent: 62,
          color: Color(0xFF3B82F6),
        ),
        OpSliceUi(
          label: 'Female',
          count: 258,
          percent: 38,
          color: Color(0xFFEC4899),
        ),
        OpSliceUi(
          label: 'Other',
          count: 0,
          percent: 0,
          color: Color(0xFFA855F7),
        ),
      ],
      genderTotal: 804,
      fyTrend: const [
        OpMonthRevenueUi(label: 'Apr', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'May', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Jun', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Jul', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Aug', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Sep', opd: 130000, lab: 250000, pharmacy: 20000),
        OpMonthRevenueUi(label: 'Oct', opd: 120000, lab: 200000, pharmacy: 110000),
        OpMonthRevenueUi(label: 'Nov', opd: 90000, lab: 160000, pharmacy: 50000),
        OpMonthRevenueUi(label: 'Dec', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Jan', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Feb', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Mar', opd: 0, lab: 0, pharmacy: 0),
      ],
      fyFooter: const [
        OpSummaryRowUi(
          label: 'YEAR',
          value: 'FY 2025-26',
          color: Color(0xFF6B6880),
        ),
        OpSummaryRowUi(
          label: 'TOTAL REVENUE',
          value: '₹7,58,516',
          color: Color(0xFF3B82F6),
        ),
        OpSummaryRowUi(
          label: 'PEAK MONTH',
          value: 'Oct',
          color: Color(0xFF22C55E),
        ),
        OpSummaryRowUi(
          label: 'CATEGORIES',
          value: 'Clinic, Lab, Pharmacy',
          color: Color(0xFF8B5CF6),
        ),
      ],
      patients: const [
        OpPatientUi(
          name: 'Rahul Sharma',
          id: 'OP-1001',
          age: 34,
          gender: 'Male',
          status: 'Paid',
          amount: '₹1,250',
          doctor: 'Dr. Mehta',
          date: '09 Nov 2026',
          statusColor: OpColors.green,
        ),
        OpPatientUi(
          name: 'Priya Verma',
          id: 'OP-1002',
          age: 28,
          gender: 'Female',
          status: 'Due',
          amount: '₹2,800',
          doctor: 'Dr. Khan',
          date: '09 Nov 2026',
          statusColor: OpColors.red,
        ),
        OpPatientUi(
          name: 'Amit Patel',
          id: 'OP-1003',
          age: 41,
          gender: 'Male',
          status: 'Paid',
          amount: '₹980',
          doctor: 'Dr. Singh',
          date: '08 Nov 2026',
          statusColor: OpColors.green,
        ),
        OpPatientUi(
          name: 'Sneha Iyer',
          id: 'OP-1004',
          age: 22,
          gender: 'Female',
          status: 'Partial',
          amount: '₹1,500',
          doctor: 'Dr. Mehta',
          date: '08 Nov 2026',
          statusColor: OpColors.orange,
        ),
        OpPatientUi(
          name: 'Vikram Joshi',
          id: 'OP-1005',
          age: 55,
          gender: 'Male',
          status: 'Paid',
          amount: '₹3,420',
          doctor: 'Dr. Rao',
          date: '07 Nov 2026',
          statusColor: OpColors.green,
        ),
        OpPatientUi(
          name: 'Ananya Das',
          id: 'OP-1006',
          age: 31,
          gender: 'Female',
          status: 'Paid',
          amount: '₹760',
          doctor: 'Dr. Khan',
          date: '07 Nov 2026',
          statusColor: OpColors.green,
        ),
      ],
      bookings: const [
        OpBookingUi(
          patient: 'Rahul Sharma',
          doctor: 'Dr. Mehta',
          slot: '10:00 AM',
          dept: 'General OP',
          status: 'Confirmed',
          statusColor: OpColors.green,
        ),
        OpBookingUi(
          patient: 'Priya Verma',
          doctor: 'Dr. Khan',
          slot: '10:30 AM',
          dept: 'Cardiology',
          status: 'Waiting',
          statusColor: OpColors.orange,
        ),
        OpBookingUi(
          patient: 'Amit Patel',
          doctor: 'Dr. Singh',
          slot: '11:00 AM',
          dept: 'Ortho',
          status: 'Completed',
          statusColor: OpColors.blue,
        ),
        OpBookingUi(
          patient: 'Sneha Iyer',
          doctor: 'Dr. Mehta',
          slot: '11:30 AM',
          dept: 'General OP',
          status: 'Confirmed',
          statusColor: OpColors.green,
        ),
        OpBookingUi(
          patient: 'Vikram Joshi',
          doctor: 'Dr. Rao',
          slot: '12:00 PM',
          dept: 'Lab',
          status: 'Confirmed',
          statusColor: OpColors.green,
        ),
        OpBookingUi(
          patient: 'Ananya Das',
          doctor: 'Dr. Khan',
          slot: '12:30 PM',
          dept: 'Pharmacy',
          status: 'Cancelled',
          statusColor: OpColors.red,
        ),
      ],
      revenueChannels: const [
        OpRevenueChannelUi(
          title: 'CLINIC REVENUE',
          icon: Icons.local_hospital_outlined,
          footfall: 592,
          amount: '₹1,89,100',
          bg: Color(0xFFEAF2FF),
          accent: Color(0xFF2563EB),
          lines: [
            (label: 'Cash', value: '₹26,400', color: Color(0xFF16A34A)),
            (label: 'Online', value: '₹1,62,700', color: Color(0xFF2563EB)),
            (label: 'Due', value: '₹0', color: Color(0xFFDC2626)),
          ],
        ),
        OpRevenueChannelUi(
          title: 'LAB REVENUE',
          icon: Icons.biotech_outlined,
          footfall: 280,
          amount: '₹4,80,887',
          bg: Color(0xFFF3EEFF),
          accent: Color(0xFF7C3AED),
          lines: [
            (label: 'Cash', value: '₹62,062', color: Color(0xFF16A34A)),
            (label: 'Online', value: '₹4,06,931', color: Color(0xFF2563EB)),
            (label: 'Due', value: '₹11,463', color: Color(0xFFDC2626)),
          ],
        ),
        OpRevenueChannelUi(
          title: 'PHARMACY REVENUE',
          icon: Icons.local_pharmacy_outlined,
          footfall: 180,
          amount: '₹1,01,793',
          bg: Color(0xFFE8F8F0),
          accent: Color(0xFF15803D),
          lines: [
            (label: 'Cash', value: '₹2,883', color: Color(0xFF16A34A)),
            (label: 'Online', value: '₹98,910', color: Color(0xFF2563EB)),
            (label: 'Due', value: '₹0', color: Color(0xFFDC2626)),
          ],
        ),
        OpRevenueChannelUi(
          title: 'TOTAL COLLECTED',
          icon: Icons.payments_outlined,
          footfall: 1052,
          amount: '₹7,71,780',
          bg: Color(0xFFFFFFFF),
          accent: Color(0xFF1C1B29),
          isTotal: true,
          lines: [
            (label: 'Clinic', value: '₹1,89,100', color: Color(0xFF2563EB)),
            (label: 'Lab', value: '₹4,80,887', color: Color(0xFF7C3AED)),
            (label: 'Pharmacy', value: '₹1,01,793', color: Color(0xFF15803D)),
          ],
        ),
      ],
    );
  }
}
