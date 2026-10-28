import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/presentation/theme/camp_colors.dart';

enum CampListStatus { today, live, upcoming, completed }

class CampListStatUi {
  const CampListStatUi({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
}

class CampPersonUi {
  const CampPersonUi({required this.initial, required this.bg, required this.fg});

  final String initial;
  final Color bg;
  final Color fg;
}

class CampItemUi {
  const CampItemUi({
    required this.name,
    required this.status,
    required this.location,
    required this.date,
    required this.time,
    required this.patients,
    required this.volunteers,
    required this.partners,
    this.createdBy = 'Unknown',
    this.assignedPartner = '—',
    this.volunteerExtra = 0,
    this.partnerExtra = 0,
    this.noVolunteers = false,
  });

  final String name;
  final CampListStatus status;
  final String location;
  final String date;
  final String time;
  final int patients;
  final List<CampPersonUi> volunteers;
  final List<CampPersonUi> partners;
  final String createdBy;
  final String assignedPartner;
  final int volunteerExtra;
  final int partnerExtra;
  final bool noVolunteers;

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

class CampListUi {
  const CampListUi({
    required this.stats,
    required this.camps,
  });

  final List<CampListStatUi> stats;
  final List<CampItemUi> camps;

  static const _volK = CampPersonUi(
    initial: 'K',
    bg: CampColors.primaryTint,
    fg: Color(0xFF534AB7),
  );
  static const _partnerS = CampPersonUi(
    initial: 'S',
    bg: Color(0xFFE1F5EE),
    fg: Color(0xFF0F6E56),
  );
  static const _partnerY = CampPersonUi(
    initial: 'Y',
    bg: CampColors.orangeTint,
    fg: Color(0xFF854F0B),
  );
  static const _volP = CampPersonUi(
    initial: 'P',
    bg: CampColors.primaryTint,
    fg: Color(0xFF534AB7),
  );
  static const _volD = CampPersonUi(
    initial: 'D',
    bg: Color(0xFFE1F5EE),
    fg: Color(0xFF0F6E56),
  );
  static const _volG = CampPersonUi(
    initial: 'G',
    bg: Color(0xFFFCEBEB),
    fg: Color(0xFFA32D2D),
  );

  static CampListUi demo() {
    return const CampListUi(
      stats: [
        CampListStatUi(
          title: 'TOTAL CAMPS',
          value: '4',
          subtitle: 'assigned camps',
          icon: Icons.location_on_rounded,
          iconColor: Color(0xFF378ADD),
          iconBg: Color(0xFFE8F3FC),
        ),
        CampListStatUi(
          title: 'ACTIVE CAMPS',
          value: '0',
          subtitle: 'currently running',
          icon: Icons.monitor_heart_outlined,
          iconColor: Color(0xFF1D9E75),
          iconBg: Color(0xFFE6F7F0),
        ),
        CampListStatUi(
          title: 'PATIENTS',
          value: '4',
          subtitle: 'total patients',
          icon: Icons.groups_rounded,
          iconColor: Color(0xFFEF9F27),
          iconBg: Color(0xFFFEF3E2),
        ),
        CampListStatUi(
          title: 'UPCOMING',
          value: '1',
          subtitle: 'scheduled camps',
          icon: Icons.calendar_month_rounded,
          iconColor: Color(0xFF0D9488),
          iconBg: Color(0xFFE0F7F5),
        ),
        CampListStatUi(
          title: 'COMPLETED',
          value: '3',
          subtitle: 'finished camps',
          icon: Icons.verified_rounded,
          iconColor: Color(0xFFE24B4A),
          iconBg: Color(0xFFFCEBEB),
        ),
      ],
      camps: [
        CampItemUi(
          name: 'Iryax Health',
          status: CampListStatus.completed,
          location: 'Road no. 50, Madhapur, Hyderabad.',
          date: '2026-08-09',
          time: '09:00 AM TO 06:00 PM',
          patients: 0,
          createdBy: 'Unknown',
          assignedPartner: 'pavan',
          volunteers: [_volD, _volK, _volK],
          partners: [_partnerS, _partnerY, _volP],
          volunteerExtra: 7,
          partnerExtra: 2,
        ),
        CampItemUi(
          name: 'Shiva_Test',
          status: CampListStatus.today,
          location: 'Hyderabad',
          date: '2026-06-22',
          time: '02:00 PM TO 05:00 PM',
          patients: 0,
          createdBy: 'Admin',
          assignedPartner: 'pavan',
          volunteers: [_volK],
          partners: [_partnerS, _partnerY],
        ),
        CampItemUi(
          name: 'Shivaram Clinic',
          status: CampListStatus.completed,
          location: 'Madhapur',
          date: '2026-06-21',
          time: '10:00 AM TO 05:00 PM',
          patients: 0,
          createdBy: 'Admin',
          assignedPartner: 'suresh',
          volunteers: [_volK],
          partners: [_partnerS, _partnerY],
        ),
        CampItemUi(
          name: 'Test Camp',
          status: CampListStatus.completed,
          location: 'Hyderabad',
          date: '2026-06-20',
          time: '10:00 AM TO 03:00 PM',
          patients: 1,
          createdBy: 'Unknown',
          assignedPartner: 'pavan',
          volunteers: [_volK],
          partners: [_partnerS, _partnerY],
        ),
        CampItemUi(
          name: 'Mega Camp – 1',
          status: CampListStatus.completed,
          location: 'Hyderabad',
          date: '2026-01-27',
          time: '10:00 AM TO 06:00 PM',
          patients: 0,
          createdBy: 'Admin',
          assignedPartner: 'pavan',
          volunteers: [_volP, _volD, _volG],
          partners: [_partnerS, _partnerY],
          volunteerExtra: 2,
        ),
        CampItemUi(
          name: 'Camp-3',
          status: CampListStatus.completed,
          location: 'Banjarahills',
          date: '2025-12-21',
          time: '10:00 AM TO 04:00 PM',
          patients: 2,
          createdBy: 'Unknown',
          assignedPartner: '—',
          volunteers: [],
          partners: [],
          noVolunteers: true,
        ),
        CampItemUi(
          name: 'Camp-2',
          status: CampListStatus.completed,
          location: 'Madhapur',
          date: '2025-12-20',
          time: '10:00 AM TO 04:00 PM',
          patients: 4,
          createdBy: 'Unknown',
          assignedPartner: '—',
          volunteers: [],
          partners: [],
          noVolunteers: true,
        ),
        CampItemUi(
          name: 'Camp-1',
          status: CampListStatus.completed,
          location: 'Tolichowki',
          date: '2025-12-20',
          time: '10:00 AM TO 04:00 PM',
          patients: 2,
          createdBy: 'Unknown',
          assignedPartner: '—',
          volunteers: [],
          partners: [],
          noVolunteers: true,
        ),
        CampItemUi(
          name: 'Camp-6',
          status: CampListStatus.completed,
          location: 'Madhapur, Ayyappa Society',
          date: '2026-01-04',
          time: '09:00 AM TO 06:00 PM',
          patients: 0,
          createdBy: 'Admin',
          assignedPartner: 'pavan',
          volunteers: [_volP, _volD, _volG],
          partners: [],
        ),
        CampItemUi(
          name: 'Camp-7',
          status: CampListStatus.completed,
          location: 'Hyderabad',
          date: '2025-12-28',
          time: '10:00 AM TO 04:00 PM',
          patients: 1,
          createdBy: 'Unknown',
          assignedPartner: '—',
          volunteers: [],
          partners: [],
          noVolunteers: true,
        ),
      ],
    );
  }
}
