import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

enum CampListStatus { today, live, upcoming, completed }

class CampListStatUi {
  const CampListStatUi({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.filter = 'All camps',
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  /// Camp list filter applied when this stat card is tapped.
  final String filter;
}

class CampPersonUi {
  const CampPersonUi({
    required this.name,
    required this.initial,
    required this.bg,
    required this.fg,
    this.role,
    this.status,
  });

  final String name;
  final String initial;
  final Color bg;
  final Color fg;
  final String? role;
  final String? status;
}

class CampPatientUi {
  const CampPatientUi({
    required this.id,
    required this.name,
    required this.contact,
    required this.age,
    required this.genderLabel,
    required this.isScreened,
    this.initial = '?',
  });

  final String id;
  final String name;
  final String contact;
  final int age;
  final String genderLabel;
  final bool isScreened;
  final String initial;

  String get ageGenderLabel => '$age yrs / $genderLabel';

  String get healthLabel => isScreened ? 'Screened' : 'Pending';
}

class CampItemUi {
  const CampItemUi({
    required this.name,
    required this.status,
    required this.location,
    required this.date,
    required this.time,
    required this.patients,
    required this.patientItems,
    required this.volunteers,
    required this.partners,
    this.id = '',
    this.createdBy = 'Unknown',
    this.assignedPartner = '—',
    this.noVolunteers = false,
  });

  final String id;
  final String name;
  final CampListStatus status;
  final String location;
  final String date;
  final String time;
  final int patients;
  final List<CampPatientUi> patientItems;
  final List<CampPersonUi> volunteers;
  final List<CampPersonUi> partners;
  final String createdBy;
  final String assignedPartner;
  final bool noVolunteers;

  int get volunteerExtra =>
      volunteers.length > 3 ? volunteers.length - 3 : 0;

  int get partnerExtra => partners.length > 3 ? partners.length - 3 : 0;

  String get statusLabel => switch (status) {
        CampListStatus.today => 'Today',
        CampListStatus.live => 'Live',
        CampListStatus.upcoming => 'Upcoming',
        CampListStatus.completed => 'Completed',
      };

  Color get accent => switch (status) {
        CampListStatus.today || CampListStatus.live => CampColors.primary,
        CampListStatus.upcoming => CampColors.orange,
        CampListStatus.completed => const Color(0xFFB0AEA6),
      };

  Color get badgeBg => switch (status) {
        CampListStatus.today || CampListStatus.live => CampColors.primaryTint,
        CampListStatus.upcoming => CampColors.orangeTint,
        CampListStatus.completed => const Color(0xFFF1EFE8),
      };

  Color get badgeFg => switch (status) {
        CampListStatus.today || CampListStatus.live => const Color(0xFF534AB7),
        CampListStatus.upcoming => const Color(0xFF854F0B),
        CampListStatus.completed => const Color(0xFF5F5E5A),
      };
}

class CampListUiMapper {
  const CampListUiMapper._();

  static const _tones = <(Color, Color)>[
    (Color(0xFFE8E4FF), Color(0xFF5B52D6)),
    (CampColors.primaryTint, Color(0xFF534AB7)),
    (CampColors.orangeTint, Color(0xFF854F0B)),
    (Color(0xFFFCEBEB), Color(0xFFA32D2D)),
    (Color(0xFFE8F3FC), Color(0xFF378ADD)),
  ];

  static List<CampItemUi> toUiList(List<Camp> camps) {
    return [for (final camp in camps) toUi(camp)];
  }

  static CampItemUi toUi(Camp camp) {
    final volunteers = [
      for (var i = 0; i < camp.volunteers.length; i++)
        _personUi(camp.volunteers[i], i),
    ];
    final partners = [
      for (var i = 0; i < camp.partners.length; i++)
        _personUi(camp.partners[i], i),
    ];

    final patientItems = [
      for (final p in camp.patients) _patientUi(p),
    ];

    return CampItemUi(
      id: camp.id,
      name: camp.name.trim().isEmpty ? 'Untitled camp' : camp.name.trim(),
      status: switch (camp.status) {
        CampStatus.today => CampListStatus.today,
        CampStatus.live => CampListStatus.live,
        CampStatus.upcoming => CampListStatus.upcoming,
        CampStatus.completed => CampListStatus.completed,
      },
      location: camp.location.trim().isEmpty ? '—' : camp.location.trim(),
      date: camp.date,
      time: camp.time,
      patients: patientItems.length,
      patientItems: patientItems,
      volunteers: volunteers,
      partners: partners,
      createdBy: camp.createdBy,
      assignedPartner: camp.assignedPartner,
      noVolunteers: volunteers.isEmpty,
    );
  }

  static CampPatientUi _patientUi(CampPatient patient) {
    final name = patient.displayName.trim().isEmpty
        ? 'Unknown Patient'
        : patient.displayName.trim();
    final gender = switch (patient.gender) {
      CampPatientGender.female => 'Female',
      CampPatientGender.male => 'Male',
      CampPatientGender.other => 'Other',
    };
    return CampPatientUi(
      id: patient.id,
      name: name,
      contact: patient.contact.trim().isEmpty ? '—' : patient.contact.trim(),
      age: patient.age,
      genderLabel: gender,
      isScreened: patient.isScreened,
      initial: name[0].toUpperCase(),
    );
  }

  static List<CampListStatUi> toStats(List<CampItemUi> camps) {
    final active = camps
        .where(
          (c) =>
              c.status == CampListStatus.today ||
              c.status == CampListStatus.live,
        )
        .length;
    final upcoming =
        camps.where((c) => c.status == CampListStatus.upcoming).length;
    final completed =
        camps.where((c) => c.status == CampListStatus.completed).length;
    final patients = camps.fold<int>(0, (sum, c) => sum + c.patients);

    return [
      CampListStatUi(
        title: 'TOTAL CAMPS',
        value: '${camps.length}',
        subtitle: 'assigned camps',
        icon: Icons.location_on_rounded,
        iconColor: const Color(0xFF378ADD),
        iconBg: const Color(0xFFE8F3FC),
        filter: 'All camps',
      ),
      CampListStatUi(
        title: 'ACTIVE CAMPS',
        value: '$active',
        subtitle: 'currently running',
        icon: Icons.monitor_heart_outlined,
        iconColor: const Color(0xFF1D9E75),
        iconBg: const Color(0xFFE6F7F0),
        filter: 'Today',
      ),
      CampListStatUi(
        title: 'PATIENTS',
        value: '$patients',
        subtitle: 'total patients',
        icon: Icons.groups_rounded,
        iconColor: const Color(0xFFEF9F27),
        iconBg: const Color(0xFFFEF3E2),
        filter: 'All camps',
      ),
      CampListStatUi(
        title: 'UPCOMING',
        value: '$upcoming',
        subtitle: 'scheduled camps',
        icon: Icons.calendar_month_rounded,
        iconColor: const Color(0xFF0D9488),
        iconBg: const Color(0xFFE0F7F5),
        filter: 'Upcoming',
      ),
      CampListStatUi(
        title: 'COMPLETED',
        value: '$completed',
        subtitle: 'finished camps',
        icon: Icons.verified_rounded,
        iconColor: const Color(0xFFE24B4A),
        iconBg: const Color(0xFFFCEBEB),
        filter: 'Completed',
      ),
    ];
  }

  static CampPersonUi _personUi(CampPerson person, int index) {
    final name = person.name.trim().isEmpty ? 'Unknown' : person.name.trim();
    final tone = _tones[index % _tones.length];
    return CampPersonUi(
      name: name,
      initial: name[0].toUpperCase(),
      bg: tone.$1,
      fg: tone.$2,
      role: person.role,
      status: person.status,
    );
  }
}
