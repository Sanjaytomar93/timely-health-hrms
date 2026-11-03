class VolunteerDashboardStats {
  const VolunteerDashboardStats({
    required this.totalCamps,
    required this.activeCamps,
    required this.upcomingCamps,
    required this.totalPatients,
    required this.screenedPatients,
  });

  final int totalCamps;
  final int activeCamps;
  final int upcomingCamps;
  final int totalPatients;
  final int screenedPatients;
}

class VolunteerCampDistribution {
  const VolunteerCampDistribution({
    required this.live,
    required this.today,
    required this.upcoming,
    required this.completed,
  });

  final int live;
  final int today;
  final int upcoming;
  final int completed;

  int get total => live + today + upcoming + completed;
}

class VolunteerCampParticipation {
  const VolunteerCampParticipation({
    required this.campName,
    required this.patients,
    required this.screened,
  });

  final String campName;
  final int patients;
  final int screened;
}

class VolunteerNamedCount {
  const VolunteerNamedCount({
    required this.name,
    required this.value,
  });

  final String name;
  final int value;
}

class VolunteerHealthMetrics {
  const VolunteerHealthMetrics({
    required this.bp,
    required this.sugar,
  });

  final List<VolunteerNamedCount> bp;
  final List<VolunteerNamedCount> sugar;
}

class VolunteerDashboardCharts {
  const VolunteerDashboardCharts({
    required this.campDistribution,
    required this.campParticipation,
    required this.bmiDistribution,
    required this.healthMetrics,
  });

  final VolunteerCampDistribution campDistribution;
  final List<VolunteerCampParticipation> campParticipation;
  final List<VolunteerNamedCount> bmiDistribution;
  final VolunteerHealthMetrics healthMetrics;
}

class VolunteerDashboard {
  const VolunteerDashboard({
    required this.stats,
    required this.charts,
  });

  final VolunteerDashboardStats stats;
  final VolunteerDashboardCharts charts;
}
