import 'package:timelay_health/features/camp/dashboard/domain/entities/volunteer_dashboard.dart';

class VolunteerDashboardModel {
  const VolunteerDashboardModel({
    required this.stats,
    required this.charts,
  });

  final VolunteerDashboardStatsModel stats;
  final VolunteerDashboardChartsModel charts;

  factory VolunteerDashboardModel.fromJson(Map<String, dynamic> json) {
    final statsRaw = json['stats'];
    final chartsRaw = json['charts'];
    return VolunteerDashboardModel(
      stats: statsRaw is Map<String, dynamic>
          ? VolunteerDashboardStatsModel.fromJson(statsRaw)
          : const VolunteerDashboardStatsModel(),
      charts: chartsRaw is Map<String, dynamic>
          ? VolunteerDashboardChartsModel.fromJson(chartsRaw)
          : const VolunteerDashboardChartsModel(),
    );
  }

  VolunteerDashboard toEntity() => VolunteerDashboard(
        stats: stats.toEntity(),
        charts: charts.toEntity(),
      );
}

class VolunteerDashboardStatsModel {
  const VolunteerDashboardStatsModel({
    this.totalCamps = 0,
    this.activeCamps = 0,
    this.upcomingCamps = 0,
    this.totalPatients = 0,
    this.screenedPatients = 0,
  });

  final int totalCamps;
  final int activeCamps;
  final int upcomingCamps;
  final int totalPatients;
  final int screenedPatients;

  factory VolunteerDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return VolunteerDashboardStatsModel(
      totalCamps: _asInt(json['totalCamps']),
      activeCamps: _asInt(json['activeCamps']),
      upcomingCamps: _asInt(json['upcomingCamps']),
      totalPatients: _asInt(json['totalPatients']),
      screenedPatients: _asInt(json['screenedPatients']),
    );
  }

  VolunteerDashboardStats toEntity() => VolunteerDashboardStats(
        totalCamps: totalCamps,
        activeCamps: activeCamps,
        upcomingCamps: upcomingCamps,
        totalPatients: totalPatients,
        screenedPatients: screenedPatients,
      );
}

class VolunteerDashboardChartsModel {
  const VolunteerDashboardChartsModel({
    this.campDistribution = const VolunteerCampDistributionModel(),
    this.campParticipation = const [],
    this.bmiDistribution = const [],
    this.healthMetrics = const VolunteerHealthMetricsModel(),
  });

  final VolunteerCampDistributionModel campDistribution;
  final List<VolunteerCampParticipationModel> campParticipation;
  final List<VolunteerNamedCountModel> bmiDistribution;
  final VolunteerHealthMetricsModel healthMetrics;

  factory VolunteerDashboardChartsModel.fromJson(Map<String, dynamic> json) {
    final dist = json['campDistribution'];
    final participation = json['campParticipation'];
    final bmi = json['bmiDistribution'];
    final metrics = json['healthMetrics'];

    return VolunteerDashboardChartsModel(
      campDistribution: dist is Map<String, dynamic>
          ? VolunteerCampDistributionModel.fromJson(dist)
          : const VolunteerCampDistributionModel(),
      campParticipation: participation is List
          ? participation
              .whereType<Map<String, dynamic>>()
              .map(VolunteerCampParticipationModel.fromJson)
              .toList(growable: false)
          : const [],
      bmiDistribution: bmi is List
          ? bmi
              .whereType<Map<String, dynamic>>()
              .map(VolunteerNamedCountModel.fromJson)
              .toList(growable: false)
          : const [],
      healthMetrics: metrics is Map<String, dynamic>
          ? VolunteerHealthMetricsModel.fromJson(metrics)
          : const VolunteerHealthMetricsModel(),
    );
  }

  VolunteerDashboardCharts toEntity() => VolunteerDashboardCharts(
        campDistribution: campDistribution.toEntity(),
        campParticipation: campParticipation
            .map((e) => e.toEntity())
            .toList(growable: false),
        bmiDistribution:
            bmiDistribution.map((e) => e.toEntity()).toList(growable: false),
        healthMetrics: healthMetrics.toEntity(),
      );
}

class VolunteerCampDistributionModel {
  const VolunteerCampDistributionModel({
    this.live = 0,
    this.today = 0,
    this.upcoming = 0,
    this.completed = 0,
  });

  final int live;
  final int today;
  final int upcoming;
  final int completed;

  factory VolunteerCampDistributionModel.fromJson(Map<String, dynamic> json) {
    return VolunteerCampDistributionModel(
      live: _asInt(json['live']),
      today: _asInt(json['today']),
      upcoming: _asInt(json['upcoming']),
      completed: _asInt(json['completed']),
    );
  }

  VolunteerCampDistribution toEntity() => VolunteerCampDistribution(
        live: live,
        today: today,
        upcoming: upcoming,
        completed: completed,
      );
}

class VolunteerCampParticipationModel {
  const VolunteerCampParticipationModel({
    required this.campName,
    required this.patients,
    required this.screened,
  });

  final String campName;
  final int patients;
  final int screened;

  factory VolunteerCampParticipationModel.fromJson(Map<String, dynamic> json) {
    return VolunteerCampParticipationModel(
      campName: json['campName']?.toString().trim() ?? '',
      patients: _asInt(json['patients']),
      screened: _asInt(json['screened']),
    );
  }

  VolunteerCampParticipation toEntity() => VolunteerCampParticipation(
        campName: campName,
        patients: patients,
        screened: screened,
      );
}

class VolunteerNamedCountModel {
  const VolunteerNamedCountModel({
    required this.name,
    required this.value,
  });

  final String name;
  final int value;

  factory VolunteerNamedCountModel.fromJson(Map<String, dynamic> json) {
    return VolunteerNamedCountModel(
      name: json['name']?.toString().trim() ?? '',
      value: _asInt(json['value']),
    );
  }

  VolunteerNamedCount toEntity() =>
      VolunteerNamedCount(name: name, value: value);
}

class VolunteerHealthMetricsModel {
  const VolunteerHealthMetricsModel({
    this.bp = const [],
    this.sugar = const [],
  });

  final List<VolunteerNamedCountModel> bp;
  final List<VolunteerNamedCountModel> sugar;

  factory VolunteerHealthMetricsModel.fromJson(Map<String, dynamic> json) {
    final bp = json['bp'];
    final sugar = json['sugar'];
    return VolunteerHealthMetricsModel(
      bp: bp is List
          ? bp
              .whereType<Map<String, dynamic>>()
              .map(VolunteerNamedCountModel.fromJson)
              .toList(growable: false)
          : const [],
      sugar: sugar is List
          ? sugar
              .whereType<Map<String, dynamic>>()
              .map(VolunteerNamedCountModel.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  VolunteerHealthMetrics toEntity() => VolunteerHealthMetrics(
        bp: bp.map((e) => e.toEntity()).toList(growable: false),
        sugar: sugar.map((e) => e.toEntity()).toList(growable: false),
      );
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
