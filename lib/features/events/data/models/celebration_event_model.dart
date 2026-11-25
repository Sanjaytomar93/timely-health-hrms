import 'package:flutter/material.dart';

enum CelebrationType {
  birthday('Birthday', '🎂'),
  anniversary('Anniversary', '🎗️');

  const CelebrationType(this.label, this.emoji);

  final String label;
  final String emoji;

  static CelebrationType fromApi(String? value) {
    final v = value?.trim().toLowerCase() ?? '';
    if (v.contains('anniv')) return CelebrationType.anniversary;
    return CelebrationType.birthday;
  }
}

class CompanyEventStats {
  const CompanyEventStats({
    required this.totalEvents,
    required this.totalBirthdays,
    required this.totalAnniversaries,
  });

  final int totalEvents;
  final int totalBirthdays;
  final int totalAnniversaries;

  factory CompanyEventStats.fromJson(Map<String, dynamic>? json) {
    return CompanyEventStats(
      totalEvents: int.tryParse('${json?['totalEvents'] ?? 0}') ?? 0,
      totalBirthdays: int.tryParse('${json?['totalBirthdays'] ?? 0}') ?? 0,
      totalAnniversaries:
          int.tryParse('${json?['totalAnniversaries'] ?? 0}') ?? 0,
    );
  }

  static const empty = CompanyEventStats(
    totalEvents: 0,
    totalBirthdays: 0,
    totalAnniversaries: 0,
  );
}

class CompanyEventsResult {
  const CompanyEventsResult({
    required this.stats,
    required this.events,
    this.totalFiltered = 0,
  });

  final CompanyEventStats stats;
  final List<CelebrationEvent> events;
  final int totalFiltered;
}

class CelebrationEvent {
  final String id;
  final String name;
  final String employeeCode;
  final String role;
  final String department;
  final CelebrationType type;
  final DateTime date;
  final int? anniversaryYears;
  final int? apiDaysRemaining;
  final Color avatarBg;
  final Color avatarTextColor;

  const CelebrationEvent({
    required this.id,
    required this.name,
    required this.employeeCode,
    required this.role,
    required this.department,
    required this.type,
    required this.date,
    this.anniversaryYears,
    this.apiDaysRemaining,
    required this.avatarBg,
    required this.avatarTextColor,
  });

  static const _avatarPalette = <(Color, Color)>[
    (Color(0xFFFDE8E8), Color(0xFFE11D48)),
    (Color(0xFFFEF3C7), Color(0xFFB45309)),
    (Color(0xFFE0E7FF), Color(0xFF4338CA)),
    (Color(0xFFEDE9FE), Color(0xFF6D28D9)),
    (Color(0xFFECFDF5), Color(0xFF047857)),
    (Color(0xFFFFFBEB), Color(0xFFD97706)),
    (Color(0xFFEFF6FF), Color(0xFF1D4ED8)),
    (Color(0xFFFDF2F8), Color(0xFFBE185D)),
    (Color(0xFFF3E8FF), Color(0xFF7E22CE)),
    (Color(0xFFE0F2FE), Color(0xFF0369A1)),
  ];

  factory CelebrationEvent.fromJson(Map<String, dynamic> json) {
    final parsed = DateTime.tryParse(json['date']?.toString() ?? '')?.toUtc();
    final date = parsed == null
        ? DateTime.now()
        : DateTime(parsed.year, parsed.month, parsed.day);
    final seed = (json['id'] ?? json['employeeId'] ?? json['name'] ?? '')
        .toString()
        .hashCode
        .abs();
    final colors = _avatarPalette[seed % _avatarPalette.length];
    final dept = json['dept']?.toString() ?? '';
    final milestone = json['milestone'];
    int? years;
    if (milestone is int) {
      years = milestone;
    } else if (milestone != null) {
      years = int.tryParse(milestone.toString());
    }

    return CelebrationEvent(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      employeeCode:
          (json['empCode'] ?? json['empId'])?.toString() ?? '',
      role: dept,
      department: dept,
      type: CelebrationType.fromApi(json['type']?.toString()),
      date: date,
      anniversaryYears: years,
      apiDaysRemaining: int.tryParse('${json['daysRemaining'] ?? ''}'),
      avatarBg: colors.$1,
      avatarTextColor: colors.$2,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  int get daysRemaining {
    if (apiDaysRemaining != null) return apiDaysRemaining!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var target = DateTime(now.year, date.month, date.day);
    if (target.isBefore(today)) {
      target = DateTime(now.year + 1, date.month, date.day);
    }
    return target.difference(today).inDays;
  }

  String get relativeDaysText {
    final days = daysRemaining;
    if (days == 0) return 'Today 🎉';
    if (days == 1) return 'Tomorrow';
    return 'In $days days';
  }

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = date.day.toString().padLeft(2, '0');
    final m = months[date.month - 1];
    return '$d $m ${date.year}';
  }

  static List<CelebrationEvent> sampleCelebrations() {
    return [
      CelebrationEvent(
        id: '1',
        name: 'Saquiba Wasi',
        employeeCode: 'TH011',
        role: 'Developer',
        department: 'Engineering',
        type: CelebrationType.birthday,
        date: DateTime(2027, 11, 9),
        avatarBg: const Color(0xFFFDE8E8),
        avatarTextColor: const Color(0xFFE11D48),
      ),
      CelebrationEvent(
        id: '2',
        name: 'G Naresh Kumar',
        employeeCode: 'TH001',
        role: 'Consultant',
        department: 'Consulting',
        type: CelebrationType.anniversary,
        date: DateTime(2026, 11, 18),
        anniversaryYears: 3,
        avatarBg: const Color(0xFFFEF3C7),
        avatarTextColor: const Color(0xFFB45309),
      ),
      CelebrationEvent(
        id: '3',
        name: 'Kardam Kumar',
        employeeCode: 'TH012',
        role: 'Developer',
        department: 'Engineering',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 24),
        avatarBg: const Color(0xFFE0E7FF),
        avatarTextColor: const Color(0xFF4338CA),
      ),
      CelebrationEvent(
        id: '4',
        name: 'Sanjay Tomar',
        employeeCode: 'TH063',
        role: 'Flutter Developer',
        department: 'Mobile Apps',
        type: CelebrationType.anniversary,
        date: DateTime(2026, 11, 28),
        anniversaryYears: 1,
        avatarBg: const Color(0xFFEDE9FE),
        avatarTextColor: const Color(0xFF6D28D9),
      ),
      CelebrationEvent(
        id: '5',
        name: 'Manideep Reddy',
        employeeCode: 'TH005',
        role: 'Marketing Lead',
        department: 'Marketing',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 12),
        avatarBg: const Color(0xFFECFDF5),
        avatarTextColor: const Color(0xFF047857),
      ),
      CelebrationEvent(
        id: '6',
        name: 'Aarif Khan',
        employeeCode: 'TH018',
        role: 'Operations Head',
        department: 'Operations',
        type: CelebrationType.anniversary,
        date: DateTime(2026, 11, 15),
        anniversaryYears: 2,
        avatarBg: const Color(0xFFFFFBEB),
        avatarTextColor: const Color(0xFFD97706),
      ),
      CelebrationEvent(
        id: '7',
        name: 'Rohith Reddy',
        employeeCode: 'TH022',
        role: 'Doctor Specialist',
        department: 'Clinical',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 30),
        avatarBg: const Color(0xFFEFF6FF),
        avatarTextColor: const Color(0xFF1D4ED8),
      ),
      CelebrationEvent(
        id: '8',
        name: 'Julee Perween',
        employeeCode: 'TH034',
        role: 'Lab Technician',
        department: 'Diagnostics',
        type: CelebrationType.anniversary,
        date: DateTime(2026, 11, 21),
        anniversaryYears: 4,
        avatarBg: const Color(0xFFFDF2F8),
        avatarTextColor: const Color(0xFFBE185D),
      ),
      CelebrationEvent(
        id: '9',
        name: 'Bharath Origin',
        employeeCode: 'TH009',
        role: 'UI/UX Designer',
        department: 'Design',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 5),
        avatarBg: const Color(0xFFF3E8FF),
        avatarTextColor: const Color(0xFF7E22CE),
      ),
      CelebrationEvent(
        id: '10',
        name: 'Madhukar Muktala',
        employeeCode: 'TH042',
        role: 'Quality Analyst',
        department: 'Quality',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 8),
        avatarBg: const Color(0xFFFEF2F2),
        avatarTextColor: const Color(0xFFB91C1C),
      ),
      CelebrationEvent(
        id: '11',
        name: 'Asif Wasi',
        employeeCode: 'TH015',
        role: 'Content Strategist',
        department: 'Content',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 16),
        avatarBg: const Color(0xFFF0FDF4),
        avatarTextColor: const Color(0xFF15803D),
      ),
      CelebrationEvent(
        id: '12',
        name: 'Virat Sharma',
        employeeCode: 'TH002',
        role: 'Consultant',
        department: 'Consulting',
        type: CelebrationType.anniversary,
        date: DateTime(2026, 11, 25),
        anniversaryYears: 5,
        avatarBg: const Color(0xFFFEF3C7),
        avatarTextColor: const Color(0xFFB45309),
      ),
      CelebrationEvent(
        id: '13',
        name: 'Hamza Wasi',
        employeeCode: 'TH027',
        role: 'Backend Architect',
        department: 'Engineering',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 19),
        avatarBg: const Color(0xFFE0F2FE),
        avatarTextColor: const Color(0xFF0369A1),
      ),
      CelebrationEvent(
        id: '14',
        name: 'Krishna Murthy',
        employeeCode: 'TH055',
        role: 'Security Specialist',
        department: 'IT',
        type: CelebrationType.anniversary,
        date: DateTime(2026, 11, 10),
        anniversaryYears: 2,
        avatarBg: const Color(0xFFFEF3C7),
        avatarTextColor: const Color(0xFFB45309),
      ),
      CelebrationEvent(
        id: '15',
        name: 'Rahul Sharma',
        employeeCode: 'TH060',
        role: 'Data Scientist',
        department: 'Engineering',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 27),
        avatarBg: const Color(0xFFFCE7F3),
        avatarTextColor: const Color(0xFF9D174D),
      ),
      CelebrationEvent(
        id: '16',
        name: 'Priya Patel',
        employeeCode: 'TH045',
        role: 'HR Specialist',
        department: 'Human Resources',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 2),
        avatarBg: const Color(0xFFECFDF5),
        avatarTextColor: const Color(0xFF047857),
      ),
      CelebrationEvent(
        id: '17',
        name: 'Ananya Roy',
        employeeCode: 'TH048',
        role: 'DevOps Engineer',
        department: 'Engineering',
        type: CelebrationType.anniversary,
        date: DateTime(2026, 11, 22),
        anniversaryYears: 2,
        avatarBg: const Color(0xFFFEF3C7),
        avatarTextColor: const Color(0xFFB45309),
      ),
      CelebrationEvent(
        id: '18',
        name: 'Vikram Joshi',
        employeeCode: 'TH050',
        role: 'Product Manager',
        department: 'Product',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 14),
        avatarBg: const Color(0xFFEDE9FE),
        avatarTextColor: const Color(0xFF6D28D9),
      ),
      CelebrationEvent(
        id: '19',
        name: 'Sneha Rao',
        employeeCode: 'TH052',
        role: 'Frontend Developer',
        department: 'Engineering',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 17),
        avatarBg: const Color(0xFFFEE2E2),
        avatarTextColor: const Color(0xFFDC2626),
      ),
      CelebrationEvent(
        id: '20',
        name: 'Arjun Das',
        employeeCode: 'TH056',
        role: 'Business Analyst',
        department: 'Operations',
        type: CelebrationType.anniversary,
        date: DateTime(2026, 11, 29),
        anniversaryYears: 1,
        avatarBg: const Color(0xFFFEF3C7),
        avatarTextColor: const Color(0xFFB45309),
      ),
      CelebrationEvent(
        id: '21',
        name: 'Deepak Varma',
        employeeCode: 'TH058',
        role: 'QA Engineer',
        department: 'Quality',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 20),
        avatarBg: const Color(0xFFE0E7FF),
        avatarTextColor: const Color(0xFF4338CA),
      ),
      CelebrationEvent(
        id: '22',
        name: 'Pooja Hegde',
        employeeCode: 'TH062',
        role: 'Marketing Associate',
        department: 'Marketing',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 23),
        avatarBg: const Color(0xFFFCE7F3),
        avatarTextColor: const Color(0xFFDB2777),
      ),
      CelebrationEvent(
        id: '23',
        name: 'Rohan Mehra',
        employeeCode: 'TH065',
        role: 'Operations Executive',
        department: 'Operations',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 26),
        avatarBg: const Color(0xFFDCFCE7),
        avatarTextColor: const Color(0xFF15803D),
      ),
      CelebrationEvent(
        id: '24',
        name: 'Tanvi Shah',
        employeeCode: 'TH068',
        role: 'Copywriter',
        department: 'Marketing',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 1),
        avatarBg: const Color(0xFFFEF3C7),
        avatarTextColor: const Color(0xFFD97706),
      ),
      CelebrationEvent(
        id: '25',
        name: 'Naveen Kumar',
        employeeCode: 'TH070',
        role: 'System Administrator',
        department: 'IT',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 4),
        avatarBg: const Color(0xFFDBEAFE),
        avatarTextColor: const Color(0xFF1D4ED8),
      ),
      CelebrationEvent(
        id: '26',
        name: 'Swati Reddy',
        employeeCode: 'TH072',
        role: 'Clinical Researcher',
        department: 'Clinical',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 6),
        avatarBg: const Color(0xFFF3E8FF),
        avatarTextColor: const Color(0xFF7E22CE),
      ),
      CelebrationEvent(
        id: '27',
        name: 'Alok Singh',
        employeeCode: 'TH075',
        role: 'Mobile Developer',
        department: 'Engineering',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 11),
        avatarBg: const Color(0xFFEDE9FE),
        avatarTextColor: const Color(0xFF6D28D9),
      ),
      CelebrationEvent(
        id: '28',
        name: 'Megha Nair',
        employeeCode: 'TH078',
        role: 'Accountant',
        department: 'Finance',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 13),
        avatarBg: const Color(0xFFFEE2E2),
        avatarTextColor: const Color(0xFFB91C1C),
      ),
      CelebrationEvent(
        id: '29',
        name: 'Kiran Goud',
        employeeCode: 'TH080',
        role: 'Consultant',
        department: 'Consulting',
        type: CelebrationType.anniversary,
        date: DateTime(2026, 11, 7),
        anniversaryYears: 3,
        avatarBg: const Color(0xFFFEF3C7),
        avatarTextColor: const Color(0xFFB45309),
      ),
      CelebrationEvent(
        id: '30',
        name: 'Harish Babu',
        employeeCode: 'TH082',
        role: 'Lab Supervisor',
        department: 'Diagnostics',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 18),
        avatarBg: const Color(0xFFECFDF5),
        avatarTextColor: const Color(0xFF047857),
      ),
      CelebrationEvent(
        id: '31',
        name: 'Ritu Sen',
        employeeCode: 'TH085',
        role: 'HR Executive',
        department: 'Human Resources',
        type: CelebrationType.birthday,
        date: DateTime(2026, 11, 28),
        avatarBg: const Color(0xFFFCE7F3),
        avatarTextColor: const Color(0xFFDB2777),
      ),
    ];
  }
}
