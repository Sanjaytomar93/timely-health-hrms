import 'package:flutter/material.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';

class OpDoctorUi {
  const OpDoctorUi({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.specialization,
    required this.qualification,
    required this.experienceYrs,
    required this.fee,
    required this.scheduleDays,
    required this.startTime,
    required this.endTime,
    required this.active,
    required this.joinedAt,
    required this.avatarColor,
    this.address = '',
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String specialization;
  final String qualification;
  final int experienceYrs;
  final int fee;
  final List<String> scheduleDays;
  final String startTime;
  final String endTime;
  final bool active;
  final String joinedAt;
  final Color avatarColor;
  final String address;

  String get scheduleTime => '$startTime - $endTime';

  String get initials {
    final cleaned = name
        .replaceFirst(RegExp(r'^dr\.?\s*', caseSensitive: false), '')
        .trim();
    final parts =
        cleaned.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'DR';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String get feeLabel => '₹$fee';
  String get experienceLabel => '$experienceYrs yrs';
  String get statusLabel => active ? 'ACTIVE' : 'INACTIVE';

  OpDoctorUi copyWith({
    String? name,
    String? phone,
    String? email,
    String? specialization,
    String? qualification,
    int? experienceYrs,
    int? fee,
    List<String>? scheduleDays,
    String? startTime,
    String? endTime,
    bool? active,
    String? joinedAt,
    String? address,
  }) {
    return OpDoctorUi(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      specialization: specialization ?? this.specialization,
      qualification: qualification ?? this.qualification,
      experienceYrs: experienceYrs ?? this.experienceYrs,
      fee: fee ?? this.fee,
      scheduleDays: scheduleDays ?? this.scheduleDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      active: active ?? this.active,
      joinedAt: joinedAt ?? this.joinedAt,
      avatarColor: avatarColor,
      address: address ?? this.address,
    );
  }

  static Color specializationColor(String value) {
    switch (value.toLowerCase()) {
      case 'gynecologist':
        return OpColors.pink;
      case 'orthopedic':
        return OpColors.purple;
      case 'cardiologist':
        return OpColors.orange;
      default:
        return OpColors.blue;
    }
  }

  static Color specializationTint(String value) {
    switch (value.toLowerCase()) {
      case 'gynecologist':
        return OpColors.pinkTint;
      case 'orthopedic':
        return OpColors.purpleTint;
      case 'cardiologist':
        return OpColors.orangeTint;
      default:
        return OpColors.blueTint;
    }
  }
}

class OpDoctorsUi {
  const OpDoctorsUi({
    required this.specializations,
    required this.doctors,
  });

  final List<String> specializations;
  final List<OpDoctorUi> doctors;

  static const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const timeSlots = [
    '06:00 AM',
    '06:30 AM',
    '07:00 AM',
    '07:30 AM',
    '08:00 AM',
    '08:30 AM',
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
    '05:00 PM',
    '05:30 PM',
    '06:00 PM',
    '06:30 PM',
    '07:00 PM',
    '07:30 PM',
    '08:00 PM',
    '08:30 PM',
    '09:00 PM',
    '09:30 PM',
    '10:00 PM',
  ];

  static OpDoctorsUi get demo {
    const daysMonSat = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const daysMonFri = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    return const OpDoctorsUi(
      specializations: [
        'General Physician',
        'Gynecologist',
        'Orthopedic',
        'Cardiologist',
        'Pediatrician',
        'Dermatologist',
      ],
      doctors: [
        OpDoctorUi(
          id: 'd1',
          name: 'DR VAMSHI KRISHNA',
          phone: '9876543210',
          email: 'vamshi.krishna@timely.health',
          specialization: 'General Physician',
          qualification: 'MBBS',
          experienceYrs: 2,
          fee: 300,
          scheduleDays: daysMonSat,
          startTime: '09:00 AM',
          endTime: '08:30 PM',
          active: true,
          joinedAt: '02 Oct 2026 01:04 pm',
          avatarColor: Color(0xFF3B82F6),
          address: 'OPD Room 12, Main Clinic',
        ),
        OpDoctorUi(
          id: 'd2',
          name: 'DR PRIYA',
          phone: '9876501234',
          email: 'priya@timely.health',
          specialization: 'Gynecologist',
          qualification: 'BHMS',
          experienceYrs: 15,
          fee: 500,
          scheduleDays: daysMonSat,
          startTime: '09:00 AM',
          endTime: '08:30 PM',
          active: true,
          joinedAt: '02 Oct 2026 01:04 pm',
          avatarColor: Color(0xFFEC4899),
          address: 'Women Wellness Wing',
        ),
        OpDoctorUi(
          id: 'd3',
          name: 'DR ANUSHA',
          phone: '9876512345',
          email: 'anusha@timely.health',
          specialization: 'Gynecologist',
          qualification: 'BHMS',
          experienceYrs: 5,
          fee: 500,
          scheduleDays: daysMonSat,
          startTime: '09:00 AM',
          endTime: '08:30 PM',
          active: true,
          joinedAt: '02 Oct 2026 01:04 pm',
          avatarColor: Color(0xFF8B5CF6),
          address: 'OPD Room 8',
        ),
        OpDoctorUi(
          id: 'd4',
          name: 'DR RAJESH',
          phone: '9876523456',
          email: 'rajesh@timely.health',
          specialization: 'Orthopedic',
          qualification: 'MBBS',
          experienceYrs: 8,
          fee: 400,
          scheduleDays: daysMonFri,
          startTime: '10:00 AM',
          endTime: '06:00 PM',
          active: true,
          joinedAt: '15 Sep 2026 11:20 am',
          avatarColor: Color(0xFF10B981),
          address: 'Ortho Block A',
        ),
        OpDoctorUi(
          id: 'd5',
          name: 'DR MEHTA',
          phone: '9876534567',
          email: 'mehta@timely.health',
          specialization: 'General Physician',
          qualification: 'MBBS',
          experienceYrs: 12,
          fee: 350,
          scheduleDays: daysMonSat,
          startTime: '09:00 AM',
          endTime: '05:00 PM',
          active: true,
          joinedAt: '01 Aug 2026 09:15 am',
          avatarColor: Color(0xFFF59E0B),
          address: 'General OPD 3',
        ),
        OpDoctorUi(
          id: 'd6',
          name: 'DR KHAN',
          phone: '9876545678',
          email: 'khan@timely.health',
          specialization: 'Orthopedic',
          qualification: 'MS Ortho',
          experienceYrs: 10,
          fee: 450,
          scheduleDays: daysMonFri,
          startTime: '11:00 AM',
          endTime: '07:00 PM',
          active: true,
          joinedAt: '20 Jul 2026 03:40 pm',
          avatarColor: Color(0xFF06B6D4),
          address: 'Ortho Block B',
        ),
      ],
    );
  }
}
