import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

enum PatientGender { male, female, other }

enum PatientCampStatus { test, campLabel, na }

enum PatientHealthStatus { pending, screened }

class PatientUi {
  const PatientUi({
    required this.id,
    required this.initials,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.address,
    required this.campId,
    required this.campName,
    this.campTag,
    this.statusTag,
    this.healthStatus = PatientHealthStatus.pending,
    this.reportPdfUrl,
    this.avatarBg,
    this.avatarFg,
    this.vitals,
    this.testCount = 0,
  });

  final String id;
  final String initials;
  final String name;
  final int age;
  final PatientGender gender;
  final String phone;
  final String address;
  final String campId;
  final String campName;
  final String? campTag;
  final String? statusTag;
  final PatientHealthStatus healthStatus;
  final String? reportPdfUrl;
  final Color? avatarBg;
  final Color? avatarFg;
  final CampPatientVitals? vitals;
  final int testCount;

  String get genderLabel => switch (gender) {
        PatientGender.male => 'Male',
        PatientGender.female => 'Female',
        PatientGender.other => 'Other',
      };

  String get healthStatusLabel => switch (healthStatus) {
        PatientHealthStatus.pending => 'Pending',
        PatientHealthStatus.screened => 'Screened',
      };

  String get ageGenderLine => '$age yrs · $genderLabel';

  Color get resolvedAvatarBg =>
      avatarBg ??
      switch (gender) {
        PatientGender.female => const Color(0xFFE1F5EE),
        PatientGender.male => const Color(0xFFE6F1FB),
        PatientGender.other => CampColors.primaryTint,
      };

  Color get resolvedAvatarFg =>
      avatarFg ??
      switch (gender) {
        PatientGender.female => const Color(0xFF0F6E56),
        PatientGender.male => const Color(0xFF185FA5),
        PatientGender.other => const Color(0xFF534AB7),
      };
}

class PatientStatUi {
  const PatientStatUi({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.valueColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final Color valueColor;
}

class PatientListUi {
  const PatientListUi({
    required this.totalPatients,
    required this.registeredCamps,
    required this.stats,
    required this.patients,
  });

  final int totalPatients;
  final int registeredCamps;
  final List<PatientStatUi> stats;
  final List<PatientUi> patients;

  String get subtitle => '$totalPatients registered across all camps';

  static const empty = PatientListUi(
    totalPatients: 0,
    registeredCamps: 0,
    stats: [],
    patients: [],
  );
}

class PatientListUiMapper {
  const PatientListUiMapper._();

  static PatientListUi fromPatients(List<CampPatient> source) {
    final patients = <PatientUi>[
      for (final patient in source) toUi(patient),
    ];

    final female =
        patients.where((p) => p.gender == PatientGender.female).length;
    final male = patients.where((p) => p.gender == PatientGender.male).length;
    final campsCovered = source
        .map((p) => p.campId.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .length;

    return PatientListUi(
      totalPatients: patients.length,
      registeredCamps: campsCovered,
      stats: [
        PatientStatUi(
          title: 'Total',
          value: '${patients.length}',
          subtitle: 'patients',
          icon: Icons.people_alt_rounded,
          iconBg: CampColors.primaryTint,
          iconFg: CampColors.primary,
          valueColor: CampColors.primary,
        ),
        PatientStatUi(
          title: 'Female',
          value: '$female',
          subtitle: 'patients',
          icon: Icons.female_rounded,
          iconBg: const Color(0xFFE7F7F0),
          iconFg: const Color(0xFF1FA971),
          valueColor: const Color(0xFF1FA971),
        ),
        PatientStatUi(
          title: 'Male',
          value: '$male',
          subtitle: 'patients',
          icon: Icons.male_rounded,
          iconBg: const Color(0xFFE8F3FC),
          iconFg: const Color(0xFF378ADD),
          valueColor: const Color(0xFF378ADD),
        ),
        PatientStatUi(
          title: 'Camps',
          value: '$campsCovered',
          subtitle: 'covered',
          icon: Icons.location_on_rounded,
          iconBg: const Color(0xFFFDF3E3),
          iconFg: const Color(0xFFF0A72E),
          valueColor: const Color(0xFFF0A72E),
        ),
      ],
      patients: patients,
    );
  }

  static PatientUi toUi(CampPatient patient) {
    final name = patient.displayName.trim().isEmpty
        ? 'Unknown Patient'
        : patient.displayName.trim();
    final gender = switch (patient.gender) {
      CampPatientGender.female => PatientGender.female,
      CampPatientGender.male => PatientGender.male,
      CampPatientGender.other => PatientGender.other,
    };

    return PatientUi(
      id: patient.id,
      initials: _initials(name),
      name: name,
      age: patient.age,
      gender: gender,
      phone: patient.contact.trim().isEmpty ? '—' : patient.contact.trim(),
      address: patient.address.trim(),
      campId: patient.campId,
      campName: patient.campName,
      campTag: patient.campName.trim().isEmpty ? null : patient.campName.trim(),
      statusTag: patient.testCount > 0 ? 'Test' : null,
      healthStatus: patient.isScreened
          ? PatientHealthStatus.screened
          : PatientHealthStatus.pending,
      reportPdfUrl: patient.reportPdfUrl,
      vitals: patient.vitals,
      testCount: patient.testCount,
    );
  }

  static String _initials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final first = parts.first;
      return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
