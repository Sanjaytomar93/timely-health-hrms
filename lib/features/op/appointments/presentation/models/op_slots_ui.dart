import 'package:flutter/material.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';

enum OpSlotStatus { available, booked, blocked }

class OpSlotUi {
  const OpSlotUi({
    required this.id,
    required this.number,
    required this.startTime,
    required this.endTime,
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.durationMins,
    required this.bufferMins,
    required this.fee,
    required this.shift,
    required this.day,
    required this.status,
  });

  final String id;
  final int number;
  final String startTime;
  final String endTime;
  final String doctorId;
  final String doctorName;
  final String specialization;
  final int durationMins;
  final int bufferMins;
  final int fee;
  final String shift; // Morning / Evening
  final String day;
  final OpSlotStatus status;

  String get timeRange => '$startTime - $endTime';
  String get durationLabel => '$durationMins Mins (+${bufferMins}m)';
  String get feeLabel => '₹$fee';
  String get statusLabel => switch (status) {
        OpSlotStatus.available => 'Available',
        OpSlotStatus.booked => 'Booked',
        OpSlotStatus.blocked => 'Blocked',
      };

  Color get statusColor => switch (status) {
        OpSlotStatus.available => OpColors.green,
        OpSlotStatus.booked => OpColors.blue,
        OpSlotStatus.blocked => OpColors.orange,
      };

  Color get statusTint => switch (status) {
        OpSlotStatus.available => OpColors.greenTint,
        OpSlotStatus.booked => OpColors.blueTint,
        OpSlotStatus.blocked => OpColors.orangeTint,
      };

  OpSlotUi copyWith({OpSlotStatus? status}) => OpSlotUi(
        id: id,
        number: number,
        startTime: startTime,
        endTime: endTime,
        doctorId: doctorId,
        doctorName: doctorName,
        specialization: specialization,
        durationMins: durationMins,
        bufferMins: bufferMins,
        fee: fee,
        shift: shift,
        day: day,
        status: status ?? this.status,
      );
}

class OpSlotDoctorChip {
  const OpSlotDoctorChip({
    required this.id,
    required this.name,
    required this.slotCount,
    required this.color,
  });

  final String id;
  final String name;
  final int slotCount;
  final Color color;

  String get initials {
    final clean = name.replaceFirst(RegExp(r'^Dr\.?\s*', caseSensitive: false), '');
    final parts = clean.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'DR';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class OpSlotsUi {
  const OpSlotsUi({
    required this.days,
    required this.doctors,
    required this.slots,
    required this.breakTitle,
    required this.breakSubtitle,
    required this.breakTime,
  });

  final List<String> days;
  final List<OpSlotDoctorChip> doctors;
  final List<OpSlotUi> slots;
  final String breakTitle;
  final String breakSubtitle;
  final String breakTime;

  static OpSlotsUi get demo {
    const days = [
      'All',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const doctors = [
      OpSlotDoctorChip(
        id: 'all',
        name: 'All Doctors',
        slotCount: 85,
        color: Color(0xFF3B82F6),
      ),
      OpSlotDoctorChip(
        id: 'd1',
        name: 'Dr. V. Satyavedam',
        slotCount: 14,
        color: Color(0xFFEC4899),
      ),
      OpSlotDoctorChip(
        id: 'd2',
        name: 'Dr. S. Karunakar',
        slotCount: 12,
        color: Color(0xFF8B5CF6),
      ),
      OpSlotDoctorChip(
        id: 'd3',
        name: 'Dr. Priya',
        slotCount: 16,
        color: Color(0xFF10B981),
      ),
      OpSlotDoctorChip(
        id: 'd4',
        name: 'Dr. Mehta',
        slotCount: 10,
        color: Color(0xFFF59E0B),
      ),
    ];

    final slots = <OpSlotUi>[];
    var n = 1;

    void addMorning(String doctorId, String name, String spec, int fee) {
      const times = [
        ('09:00 AM', '09:20 AM'),
        ('09:20 AM', '09:40 AM'),
        ('09:40 AM', '10:00 AM'),
        ('10:00 AM', '10:20 AM'),
        ('10:20 AM', '10:40 AM'),
        ('10:40 AM', '11:00 AM'),
        ('11:00 AM', '11:20 AM'),
        ('11:20 AM', '11:40 AM'),
      ];
      for (final t in times) {
        slots.add(
          OpSlotUi(
            id: 's$n',
            number: n,
            startTime: t.$1,
            endTime: t.$2,
            doctorId: doctorId,
            doctorName: name,
            specialization: spec,
            durationMins: 20,
            bufferMins: 5,
            fee: fee,
            shift: 'Morning',
            day: 'Monday',
            status: OpSlotStatus.available,
          ),
        );
        n++;
      }
    }

    void addEvening(String doctorId, String name, String spec, int fee) {
      const times = [
        ('03:00 PM', '03:20 PM'),
        ('03:20 PM', '03:40 PM'),
        ('03:40 PM', '04:00 PM'),
        ('04:00 PM', '04:20 PM'),
        ('06:35 PM', '06:55 PM'),
        ('06:55 PM', '07:15 PM'),
        ('07:15 PM', '07:35 PM'),
        ('07:35 PM', '07:55 PM'),
      ];
      for (final t in times) {
        slots.add(
          OpSlotUi(
            id: 's$n',
            number: n,
            startTime: t.$1,
            endTime: t.$2,
            doctorId: doctorId,
            doctorName: name,
            specialization: spec,
            durationMins: 20,
            bufferMins: 5,
            fee: fee,
            shift: 'Evening',
            day: 'Monday',
            status: OpSlotStatus.available,
          ),
        );
        n++;
      }
    }

    addMorning('d1', 'Dr. V. Satyavedam', 'Gynecologist', 500);
    addMorning('d2', 'Dr. S. Karunakar', 'Psychiatrist', 500);
    addEvening('d1', 'Dr. V. Satyavedam', 'Gynecologist', 500);
    addEvening('d3', 'Dr. Priya', 'Gynecologist', 300);
    addEvening('d4', 'Dr. Mehta', 'General Physician', 300);

    return OpSlotsUi(
      days: days,
      doctors: doctors,
      slots: slots,
      breakTitle: 'Afternoon OP Break Period',
      breakSubtitle: 'Scheduled Doctor Break & Clinic Sanitization',
      breakTime: '02:00 PM - 03:00 PM',
    );
  }
}
