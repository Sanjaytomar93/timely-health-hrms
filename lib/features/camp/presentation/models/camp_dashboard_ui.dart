import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/presentation/theme/camp_colors.dart';

class CampStatUi {
  const CampStatUi({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.tint,
    this.isPulse = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color tint;
  final bool isPulse;
}

class CampSliceUi {
  const CampSliceUi({
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

class CampParticipationUi {
  const CampParticipationUi({
    required this.label,
    required this.volunteers,
    required this.patients,
  });

  final String label;
  final double volunteers;
  final double patients;
}

class CampBmiUi {
  const CampBmiUi({
    required this.label,
    required this.under,
    required this.healthy,
    required this.over,
    required this.obese,
  });

  final String label;
  final double under;
  final double healthy;
  final double over;
  final double obese;
}

class CampDashboardUi {
  const CampDashboardUi({
    required this.greeting,
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.stats,
    required this.distribution,
    required this.distributionTotal,
    required this.participation,
    required this.bmi,
    required this.bpSlices,
    required this.bpPatients,
    required this.sugarSlices,
    required this.sugarPatients,
  });

  final String greeting;
  final String title;
  final String subtitle;
  final String dateLabel;
  final List<CampStatUi> stats;
  final List<CampSliceUi> distribution;
  final int distributionTotal;
  final List<CampParticipationUi> participation;
  final List<CampBmiUi> bmi;
  final List<CampSliceUi> bpSlices;
  final int bpPatients;
  final List<CampSliceUi> sugarSlices;
  final int sugarPatients;

  static CampDashboardUi demo() {
    return const CampDashboardUi(
      greeting: 'Welcome back',
      title: 'K Akhil Kumar',
      subtitle: 'Manage your assigned camps and patients.',
      dateLabel: 'Tue, Oct 27, 2026',
      stats: [
        CampStatUi(
          title: 'Total',
          value: '4',
          subtitle: 'assigned camps',
          icon: Icons.location_on_outlined,
          accent: CampColors.primary,
          tint: CampColors.primaryTint,
        ),
        CampStatUi(
          title: 'Active',
          value: '0',
          subtitle: 'currently running',
          icon: Icons.monitor_heart_outlined,
          accent: CampColors.green,
          tint: CampColors.greenTint,
          isPulse: true,
        ),
        CampStatUi(
          title: 'Patients',
          value: '4',
          subtitle: 'total patients',
          icon: Icons.groups_outlined,
          accent: CampColors.orange,
          tint: CampColors.orangeTint,
        ),
        CampStatUi(
          title: 'Upcoming',
          value: '1',
          subtitle: 'scheduled camps',
          icon: Icons.calendar_month_outlined,
          accent: CampColors.blue,
          tint: CampColors.blueTint,
        ),
        CampStatUi(
          title: 'Screened',
          value: '4',
          subtitle: 'screened patients',
          icon: Icons.verified_user_outlined,
          accent: CampColors.slate,
          tint: CampColors.slateTint,
        ),
      ],
      distribution: [
        CampSliceUi(label: 'Live', count: 0, percent: 0, color: CampColors.red),
        CampSliceUi(
          label: 'Today',
          count: 1,
          percent: 5,
          color: CampColors.green,
        ),
        CampSliceUi(
          label: 'Upcoming',
          count: 0,
          percent: 0,
          color: CampColors.orange,
        ),
        CampSliceUi(
          label: 'Completed',
          count: 19,
          percent: 95,
          color: CampColors.primary,
        ),
      ],
      distributionTotal: 20,
      participation: [
        CampParticipationUi(label: 'Camp-4', volunteers: 8, patients: 42),
        CampParticipationUi(label: 'Camp-2', volunteers: 6, patients: 35),
        CampParticipationUi(label: 'Camp-7', volunteers: 10, patients: 48),
        CampParticipationUi(label: 'Camp-1', volunteers: 5, patients: 28),
        CampParticipationUi(label: 'Camp-9', volunteers: 7, patients: 40),
        CampParticipationUi(label: 'Camp-3', volunteers: 9, patients: 45),
        CampParticipationUi(label: 'Camp-5', volunteers: 4, patients: 22),
      ],
      bmi: [
        CampBmiUi(label: 'Camp-2', under: 1, healthy: 1, over: 1, obese: 2),
        CampBmiUi(label: 'Camp-7', under: 0, healthy: 1, over: 1, obese: 0),
        CampBmiUi(label: 'Camp-4', under: 0, healthy: 1, over: 1, obese: 0),
        CampBmiUi(label: 'Test', under: 0, healthy: 0, over: 1, obese: 0),
        CampBmiUi(label: 'Camp-3', under: 0, healthy: 1, over: 0, obese: 0),
      ],
      bpSlices: [
        CampSliceUi(
          label: 'Normal',
          count: 6,
          percent: 50,
          color: CampColors.green,
        ),
        CampSliceUi(label: 'High', count: 6, percent: 50, color: CampColors.red),
      ],
      bpPatients: 12,
      sugarSlices: [
        CampSliceUi(
          label: 'Normal',
          count: 8,
          percent: 67,
          color: CampColors.green,
        ),
        CampSliceUi(label: 'High', count: 4, percent: 33, color: CampColors.red),
      ],
      sugarPatients: 12,
    );
  }
}
