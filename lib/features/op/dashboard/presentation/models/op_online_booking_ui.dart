import 'package:flutter/material.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';

class OpOnlineBookingServiceUi {
  const OpOnlineBookingServiceUi({
    required this.name,
    required this.amount,
  });

  final String name;
  final int amount;

  String get label => '$name (₹$amount)';
}

class OpOnlineBookingUi {
  const OpOnlineBookingUi({
    required this.id,
    required this.timeRange,
    required this.apptDate,
    required this.bookedOn,
    required this.status,
    required this.payStatus,
    required this.name,
    required this.pid,
    required this.age,
    required this.gender,
    required this.phone,
    required this.doctor,
    required this.specialty,
    required this.services,
    required this.payType,
    required this.txnId,
    required this.total,
    required this.active,
    this.reschedule = false,
    this.reportsCount = 0,
    this.prescriptionsCount = 0,
  });

  final String id;
  final String timeRange;
  final String apptDate;
  final String bookedOn;
  final String status;
  final String payStatus;
  final String name;
  final String pid;
  final int age;
  final String gender;
  final String phone;
  final String doctor;
  final String specialty;
  final List<OpOnlineBookingServiceUi> services;
  final String payType;
  final String txnId;
  final int total;
  final bool active;
  final bool reschedule;
  final int reportsCount;
  final int prescriptionsCount;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '#';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String get doctorLine => '$doctor ($specialty)';

  OpOnlineBookingUi copyWith({bool? active}) => OpOnlineBookingUi(
        id: id,
        timeRange: timeRange,
        apptDate: apptDate,
        bookedOn: bookedOn,
        status: status,
        payStatus: payStatus,
        name: name,
        pid: pid,
        age: age,
        gender: gender,
        phone: phone,
        doctor: doctor,
        specialty: specialty,
        services: services,
        payType: payType,
        txnId: txnId,
        total: total,
        active: active ?? this.active,
        reschedule: reschedule,
        reportsCount: reportsCount,
        prescriptionsCount: prescriptionsCount,
      );
}

class OpOnlineBookingMetricUi {
  const OpOnlineBookingMetricUi({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.tint,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final Color tint;
}

class OpOnlineBookingsUi {
  const OpOnlineBookingsUi({
    required this.doctors,
    required this.statuses,
    required this.paymentStatuses,
    required this.metrics,
    required this.bookings,
  });

  final List<String> doctors;
  final List<String> statuses;
  final List<String> paymentStatuses;
  final List<OpOnlineBookingMetricUi> metrics;
  final List<OpOnlineBookingUi> bookings;

  static OpOnlineBookingsUi get demo => const OpOnlineBookingsUi(
        doctors: [
          'All Doctors',
          'Dr. Ananya Sen',
          'Dr. Kabir Malhotra',
        ],
        statuses: [
          'All Status',
          'Confirmed',
          'Pending',
          'Cancelled',
        ],
        paymentStatuses: [
          'All Payment Status',
          'Paid',
          'Pending',
          'Failed',
        ],
        metrics: [
          OpOnlineBookingMetricUi(
            title: 'Total Online',
            value: '3',
            subtitle: 'online appointments',
            accent: OpColors.blue,
            icon: Icons.groups_rounded,
            tint: OpColors.blueTint,
          ),
          OpOnlineBookingMetricUi(
            title: 'Paid',
            value: '3',
            subtitle: 'completed payments',
            accent: OpColors.green,
            icon: Icons.person_rounded,
            tint: OpColors.greenTint,
          ),
          OpOnlineBookingMetricUi(
            title: 'Pending',
            value: '0',
            subtitle: 'awaiting payment',
            accent: OpColors.orange,
            icon: Icons.schedule_rounded,
            tint: OpColors.orangeTint,
          ),
          OpOnlineBookingMetricUi(
            title: 'Total Revenue',
            value: '₹1,100',
            subtitle: 'collected revenue',
            accent: OpColors.green,
            icon: Icons.currency_rupee_rounded,
            tint: OpColors.greenTint,
          ),
          OpOnlineBookingMetricUi(
            title: 'Filtered',
            value: '3',
            subtitle: 'matching filters',
            accent: OpColors.blue,
            icon: Icons.filter_alt_rounded,
            tint: OpColors.blueTint,
          ),
        ],
        bookings: [
          OpOnlineBookingUi(
            id: 'b1',
            timeRange: '07:10 PM – 07:30 PM',
            apptDate: '22/09/2026',
            bookedOn: '22/09/2026 16:59',
            status: 'Confirmed',
            payStatus: 'Paid',
            name: 'Rahul Sharma',
            pid: 'PID-90422',
            age: 32,
            gender: 'Male',
            phone: '98765 43210',
            doctor: 'Dr. Ananya Sen',
            specialty: 'General Physician',
            services: [
              OpOnlineBookingServiceUi(name: 'Doctor Consultation', amount: 300),
              OpOnlineBookingServiceUi(name: 'INJECTION', amount: 200),
            ],
            payType: 'Online',
            txnId: 'pay_Q2W3E4R5T6',
            total: 500,
            active: true,
            reportsCount: 0,
            prescriptionsCount: 1,
          ),
          OpOnlineBookingUi(
            id: 'b2',
            timeRange: '06:40 PM – 07:00 PM',
            apptDate: '22/09/2026',
            bookedOn: '22/09/2026 15:42',
            status: 'Confirmed',
            payStatus: 'Paid',
            name: 'Priya Mehta',
            pid: 'PID-90418',
            age: 28,
            gender: 'Female',
            phone: '98111 22009',
            doctor: 'Dr. Kabir Malhotra',
            specialty: 'Dermatology',
            services: [
              OpOnlineBookingServiceUi(name: 'Skin Consultation', amount: 400),
            ],
            payType: 'Online',
            txnId: 'pay_A1B2C3D4E5',
            total: 400,
            active: true,
            reportsCount: 1,
            prescriptionsCount: 0,
          ),
          OpOnlineBookingUi(
            id: 'b3',
            timeRange: '06:10 PM – 06:30 PM',
            apptDate: '22/09/2026',
            bookedOn: '22/09/2026 14:18',
            status: 'Confirmed',
            payStatus: 'Paid',
            name: 'Amit Verma',
            pid: 'PID-90411',
            age: 45,
            gender: 'Male',
            phone: '90012 33445',
            doctor: 'Dr. Ananya Sen',
            specialty: 'General Physician',
            services: [
              OpOnlineBookingServiceUi(name: 'Follow-up Visit', amount: 200),
              OpOnlineBookingServiceUi(name: 'Blood Test', amount: 200),
            ],
            payType: 'Online',
            txnId: 'pay_Z9Y8X7W6V5',
            total: 400,
            active: true,
            reportsCount: 0,
            prescriptionsCount: 0,
          ),
        ],
      );
}
