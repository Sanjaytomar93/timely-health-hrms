import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/dashboard/domain/entities/volunteer_dashboard.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

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

  static const empty = CampDashboardUi(
    greeting: 'Welcome back',
    title: '',
    subtitle: 'Manage your assigned camps and patients.',
    dateLabel: '',
    stats: [],
    distribution: [],
    distributionTotal: 0,
    participation: [],
    bmi: [],
    bpSlices: [],
    bpPatients: 0,
    sugarSlices: [],
    sugarPatients: 0,
  );
}

class CampDashboardUiMapper {
  const CampDashboardUiMapper._();

  static CampDashboardUi fromEntity(
    VolunteerDashboard dashboard, {
    required String employeeName,
  }) {
    final stats = dashboard.stats;
    final charts = dashboard.charts;
    final dist = charts.campDistribution;
    final total = dist.total;

    return CampDashboardUi(
      greeting: 'Welcome back',
      title: employeeName,
      subtitle: 'Manage your assigned camps and patients.',
      dateLabel: _todayLabel(),
      stats: [
        CampStatUi(
          title: 'Total',
          value: '${stats.totalCamps}',
          subtitle: 'assigned camps',
          icon: Icons.location_on_outlined,
          accent: CampColors.primary,
          tint: CampColors.primaryTint,
        ),
        CampStatUi(
          title: 'Active',
          value: '${stats.activeCamps}',
          subtitle: 'currently running',
          icon: Icons.monitor_heart_outlined,
          accent: CampColors.green,
          tint: CampColors.greenTint,
          isPulse: true,
        ),
        CampStatUi(
          title: 'Patients',
          value: '${stats.totalPatients}',
          subtitle: 'total patients',
          icon: Icons.groups_outlined,
          accent: CampColors.orange,
          tint: CampColors.orangeTint,
        ),
        CampStatUi(
          title: 'Upcoming',
          value: '${stats.upcomingCamps}',
          subtitle: 'scheduled camps',
          icon: Icons.calendar_month_outlined,
          accent: CampColors.blue,
          tint: CampColors.blueTint,
        ),
        CampStatUi(
          title: 'Screened',
          value: '${stats.screenedPatients}',
          subtitle: 'screened patients',
          icon: Icons.verified_user_outlined,
          accent: CampColors.slate,
          tint: CampColors.slateTint,
        ),
      ],
      distribution: [
        _slice('Live', dist.live, total, CampColors.red),
        _slice('Today', dist.today, total, CampColors.green),
        _slice('Upcoming', dist.upcoming, total, CampColors.orange),
        _slice('Completed', dist.completed, total, CampColors.primary),
      ],
      distributionTotal: total,
      participation: charts.campParticipation
          .map(
            (e) => CampParticipationUi(
              label: e.campName,
              volunteers: e.screened.toDouble(),
              patients: e.patients.toDouble(),
            ),
          )
          .toList(growable: false),
      bmi: _bmiFromDistribution(charts.bmiDistribution),
      bpSlices: _metricSlices(charts.healthMetrics.bp),
      bpPatients: _sumValues(charts.healthMetrics.bp),
      sugarSlices: _metricSlices(charts.healthMetrics.sugar),
      sugarPatients: _sumValues(charts.healthMetrics.sugar),
    );
  }

  static CampSliceUi _slice(String label, int count, int total, Color color) {
    final percent = total <= 0 ? 0.0 : (count / total) * 100;
    return CampSliceUi(
      label: label,
      count: count,
      percent: percent,
      color: color,
    );
  }

  static List<CampBmiUi> _bmiFromDistribution(
    List<VolunteerNamedCount> items,
  ) {
    double under = 0, healthy = 0, over = 0, obese = 0;
    for (final item in items) {
      final key = item.name.trim().toLowerCase();
      final value = item.value.toDouble();
      if (key == 'underweight' || key == 'under') {
        under = value;
      } else if (key == 'healthy' || key == 'normal') {
        healthy = value;
      } else if (key == 'overweight' || key == 'over') {
        over = value;
      } else if (key == 'obese') {
        obese = value;
      }
    }
    return [
      CampBmiUi(label: 'Under', under: under, healthy: 0, over: 0, obese: 0),
      CampBmiUi(
        label: 'Healthy',
        under: 0,
        healthy: healthy,
        over: 0,
        obese: 0,
      ),
      CampBmiUi(label: 'Over', under: 0, healthy: 0, over: over, obese: 0),
      CampBmiUi(label: 'Obese', under: 0, healthy: 0, over: 0, obese: obese),
    ];
  }

  static List<CampSliceUi> _metricSlices(List<VolunteerNamedCount> items) {
    final total = _sumValues(items);
    return [
      for (final item in items)
        CampSliceUi(
          label: item.name,
          count: item.value,
          percent: total <= 0 ? 0 : (item.value / total) * 100,
          color: _metricColor(item.name),
        ),
    ];
  }

  static int _sumValues(List<VolunteerNamedCount> items) =>
      items.fold<int>(0, (sum, e) => sum + e.value);

  static Color _metricColor(String name) {
    switch (name.trim().toLowerCase()) {
      case 'normal':
        return CampColors.green;
      case 'elevated':
      case 'borderline':
        return CampColors.orange;
      case 'high':
        return CampColors.red;
      default:
        return CampColors.primary;
    }
  }

  static String _todayLabel() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
