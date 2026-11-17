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

class OpCollectedUi {
  const OpCollectedUi({required this.amount, required this.breakdown});

  final String amount;
  final List<({String label, String value, Color color})> breakdown;
}

class OpDueInvoiceUi {
  const OpDueInvoiceUi({required this.count, required this.amount});

  final int count;
  final String amount;
}

class OpDashboardUi {
  const OpDashboardUi({
    required this.greeting,
    required this.fyLabel,
    required this.periodFilters,
    required this.selectedPeriod,
    required this.quickActions,
    required this.collected,
    required this.metrics,
    required this.dueInvoices,
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
  final OpCollectedUi collected;
  final List<OpMetricUi> metrics;
  final OpDueInvoiceUi dueInvoices;
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
          subtitle: 'Quick Action',
          icon: Icons.medical_services_outlined,
          accent: Color(0xFF2563EB),
          tint: Color(0xFFEFF6FF),
          tabIndex: 2,
        ),
        OpQuickActionUi(
          label: 'Slots',
          subtitle: 'Quick Action',
          icon: Icons.calendar_month_outlined,
          accent: Color(0xFF7C3AED),
          tint: Color(0xFFF5F3FF),
        ),
        OpQuickActionUi(
          label: 'OP',
          subtitle: 'Quick Action',
          icon: Icons.person_add_alt_1_rounded,
          accent: Color(0xFF26204A),
          tint: Color(0xFFEEEDF0),
          tabIndex: 1,
        ),
        OpQuickActionUi(
          label: 'Bookings',
          subtitle: 'Quick Action',
          icon: Icons.menu_book_outlined,
          accent: Color(0xFFB45309),
          tint: Color(0xFFFFFBEB),
          tabIndex: 4,
        ),
      ],
      collected: const OpCollectedUi(
        amount: '₹8,12,565',
        breakdown: [
          (label: 'Clinic', value: '₹1,98,750', color: Color(0xFF93C5FD)),
          (label: 'Lab', value: '₹5,02,212', color: Color(0xFFC4B5FD)),
          (label: 'Pharmacy', value: '₹1,11,603', color: Color(0xFF6EE7B7)),
        ],
      ),
      metrics: const [
        OpMetricUi(
          title: 'Total Patients',
          value: '852',
          accent: Color(0xFF26204A),
          icon: Icons.groups_2_outlined,
          tint: Color(0x1A26204A),
          activeLabel: 'Active: 852',
          inactiveLabel: 'Inactive: 0',
        ),
        OpMetricUi(
          title: 'Paid',
          value: '830',
          subtitle: 'completed payments',
          accent: Color(0xFF059669),
          icon: Icons.check_rounded,
          tint: Color(0xFFECFDF5),
        ),
        OpMetricUi(
          title: 'Partial',
          value: '3',
          subtitle: 'partially paid',
          accent: Color(0xFFD97706),
          icon: Icons.schedule_rounded,
          tint: Color(0xFFFFFBEB),
        ),
        OpMetricUi(
          title: 'Pending',
          value: '0',
          subtitle: 'awaiting payment',
          accent: Color(0xFFB45309),
          icon: Icons.error_rounded,
          tint: Color(0xFFFFFBEB),
        ),
      ],
      dueInvoices: const OpDueInvoiceUi(count: 19, amount: '₹12,063'),
      trend: const [
        OpMonthRevenueUi(label: 'Apr', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'May', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Jun', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Jul', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Aug', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(
          label: 'Sep',
          opd: 130000,
          lab: 250000,
          pharmacy: 20000,
        ),
        OpMonthRevenueUi(
          label: 'Oct',
          opd: 120000,
          lab: 200000,
          pharmacy: 110000,
        ),
        OpMonthRevenueUi(label: 'Nov', opd: 36000, lab: 73000, pharmacy: 31000),
        OpMonthRevenueUi(label: 'Dec', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Jan', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Feb', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Mar', opd: 0, lab: 0, pharmacy: 0),
      ],
      summaryRows: const [
        OpSummaryRowUi(
          label: 'Total Patients',
          value: '852',
          color: Color(0xFF26204A),
        ),
        OpSummaryRowUi(
          label: 'Total Collected',
          value: '₹8,12,565',
          color: Color(0xFF059669),
        ),
        OpSummaryRowUi(
          label: 'Total Due',
          value: '₹12,063',
          color: Color(0xFFE11D48),
        ),
        OpSummaryRowUi(
          label: 'Reviews',
          value: '0',
          color: Color(0xFF7C3AED),
        ),
        OpSummaryRowUi(
          label: 'Offers Applied',
          value: '1',
          color: Color(0xFFD97706),
        ),
      ],
      paymentStatus: const [
        OpSliceUi(
          label: 'Paid',
          count: 830,
          percent: 97.4,
          color: Color(0xFF10B981),
        ),
        OpSliceUi(
          label: 'Partial',
          count: 3,
          percent: 0.4,
          color: Color(0xFFF59E0B),
        ),
        OpSliceUi(
          label: 'Pending',
          count: 19,
          percent: 2.2,
          color: Color(0xFFF43F5E),
        ),
      ],
      paymentModes: const [
        OpSliceUi(
          label: 'Online UPI / Netbanking',
          count: 552,
          percent: 66.5,
          color: Color(0xFF26204A),
        ),
        OpSliceUi(
          label: 'Cash Counter',
          count: 276,
          percent: 33.2,
          color: Color(0xFF10B981),
        ),
        OpSliceUi(
          label: 'Insurance TPA',
          count: 1,
          percent: 0.1,
          color: Color(0xFF8B5CF6),
        ),
        OpSliceUi(
          label: 'Credit / Debit Card',
          count: 1,
          percent: 0.1,
          color: Color(0xFF0EA5E9),
        ),
      ],
      gender: const [
        OpSliceUi(
          label: 'Male',
          count: 443,
          percent: 61,
          color: Color(0xFF26204A),
        ),
        OpSliceUi(
          label: 'Female',
          count: 284,
          percent: 39,
          color: Color(0xFFEC4899),
        ),
        OpSliceUi(
          label: 'Other',
          count: 0,
          percent: 0,
          color: Color(0xFFCBD5E1),
        ),
      ],
      genderTotal: 727,
      fyTrend: const [
        OpMonthRevenueUi(label: 'Apr', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'May', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Jun', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Jul', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Aug', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(
          label: 'Sep',
          opd: 130000,
          lab: 250000,
          pharmacy: 20000,
        ),
        OpMonthRevenueUi(
          label: 'Oct',
          opd: 120000,
          lab: 200000,
          pharmacy: 110000,
        ),
        OpMonthRevenueUi(
          label: 'Nov',
          opd: 90000,
          lab: 160000,
          pharmacy: 50000,
        ),
        OpMonthRevenueUi(label: 'Dec', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Jan', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Feb', opd: 0, lab: 0, pharmacy: 0),
        OpMonthRevenueUi(label: 'Mar', opd: 0, lab: 0, pharmacy: 0),
      ],
      fyFooter: const [
        OpSummaryRowUi(
          label: 'Total Revenue',
          value: '₹8,04,811',
          color: Color(0xFF26204A),
        ),
        OpSummaryRowUi(
          label: 'Peak Month',
          value: 'Oct',
          color: Color(0xFF047857),
        ),
        OpSummaryRowUi(
          label: 'FY Range',
          value: '2025-26',
          color: Color(0xFF7C3AED),
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
          icon: Icons.favorite_rounded,
          footfall: 625,
          amount: '₹1,98,750',
          bg: Color(0xFFEFF6FF),
          accent: Color(0xFF1D4ED8),
          lines: [
            (label: 'Cash', value: '₹26,750', color: Color(0xFF047857)),
            (label: 'Online', value: '₹1,71,400', color: Color(0xFF4338CA)),
            (label: 'Due', value: '₹600', color: Color(0xFFE11D48)),
          ],
        ),
        OpRevenueChannelUi(
          title: 'LAB REVENUE',
          icon: Icons.science_outlined,
          footfall: 296,
          amount: '₹5,02,212',
          bg: Color(0xFFF5F3FF),
          accent: Color(0xFF6D28D9),
          lines: [
            (label: 'Cash', value: '₹63,661', color: Color(0xFF047857)),
            (label: 'Online', value: '₹4,26,657', color: Color(0xFF4338CA)),
            (label: 'Due', value: '₹11,463', color: Color(0xFFE11D48)),
          ],
        ),
        OpRevenueChannelUi(
          title: 'PHARMACY REVENUE',
          icon: Icons.local_pharmacy_outlined,
          footfall: 202,
          amount: '₹1,11,603',
          bg: Color(0xFFECFDF5),
          accent: Color(0xFF047857),
          lines: [
            (label: 'Cash', value: '₹2,883', color: Color(0xFF047857)),
            (label: 'Online', value: '₹1,08,720', color: Color(0xFF4338CA)),
            (label: 'Due', value: '₹0', color: Color(0xFF64748B)),
          ],
        ),
        OpRevenueChannelUi(
          title: 'TOTAL COLLECTED',
          icon: Icons.currency_rupee_rounded,
          footfall: 1123,
          amount: '₹8,12,565',
          bg: Color(0xFFF8FAFC),
          accent: Color(0xFF1E293B),
          isTotal: true,
          lines: [
            (label: 'Clinic', value: '₹1,98,750', color: Color(0xFF1D4ED8)),
            (label: 'Lab', value: '₹5,02,212', color: Color(0xFF6D28D9)),
            (label: 'Pharmacy', value: '₹1,11,603', color: Color(0xFF047857)),
          ],
        ),
      ],
    );
  }
}
