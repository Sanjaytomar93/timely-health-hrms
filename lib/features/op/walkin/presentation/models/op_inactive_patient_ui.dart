import 'package:flutter/material.dart';

class OpInactivePatientUi {
  const OpInactivePatientUi({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.doctor,
    required this.lastVisitDate,
    this.lastVisitTime,
    required this.deactivatedSince,
    required this.paymentStatus,
    this.city = 'N/A',
  });

  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String doctor;
  final String lastVisitDate;
  final String? lastVisitTime;
  final String deactivatedSince;
  final String paymentStatus; // 'DUE', 'PAID', 'PARTIAL'
  final String city;

  String get initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '#';
    final parts = trimmed.split(RegExp(r'\s+'));
    for (final p in parts.reversed) {
      if (p.isEmpty) continue;
      final c = p[0].toUpperCase();
      if (RegExp(r'[A-Z]').hasMatch(c)) return c;
    }
    return trimmed[0].toUpperCase();
  }

  bool get isDue => paymentStatus.toUpperCase() == 'DUE';
  bool get isPaid => paymentStatus.toUpperCase() == 'PAID';
  bool get isPartial => paymentStatus.toUpperCase() == 'PARTIAL';

  static const List<OpInactivePatientUi> demoPatients = [
    OpInactivePatientUi(
      id: '1',
      name: 'Mr. SHAMEEK',
      age: 25,
      gender: 'Male',
      phone: '7781999831',
      doctor: 'DR VAMSHI KRISHNA',
      lastVisitDate: '15/11/2026',
      lastVisitTime: '01:35 PM - 01:55 PM',
      deactivatedSince: '15/11/2026 13:12',
      paymentStatus: 'DUE',
      city: 'N/A',
    ),
    OpInactivePatientUi(
      id: '2',
      name: 'Ms. LAKSHMI',
      age: 26,
      gender: 'Female',
      phone: '8074693193',
      doctor: 'N/A',
      lastVisitDate: '06/11/2026',
      deactivatedSince: '06/11/2026 18:46',
      paymentStatus: 'PAID',
      city: 'N/A',
    ),
    OpInactivePatientUi(
      id: '3',
      name: 'Mr. NARESH',
      age: 24,
      gender: 'Male',
      phone: '9381372575',
      doctor: 'N/A',
      lastVisitDate: '01/11/2026',
      deactivatedSince: '01/11/2026 19:11',
      paymentStatus: 'DUE',
      city: 'N/A',
    ),
    OpInactivePatientUi(
      id: '4',
      name: 'Miss SWETHA',
      age: 21,
      gender: 'Female',
      phone: '9392600089',
      doctor: 'DR VAMSHI KRISHNA',
      lastVisitDate: '09/10/2026',
      lastVisitTime: '07:50 PM - 08:10 PM',
      deactivatedSince: '09/10/2026 19:42',
      paymentStatus: 'DUE',
      city: 'N/A',
    ),
    OpInactivePatientUi(
      id: '5',
      name: 'Mr. Saidulu Konch...',
      age: 30,
      gender: 'Male',
      phone: '9014424455',
      doctor: 'Dr Abhigna jupaka',
      lastVisitDate: '25/09/2026',
      lastVisitTime: '10:25 AM - 10:45 AM',
      deactivatedSince: '22/09/2026 16:25',
      paymentStatus: 'PAID',
      city: 'N/A',
    ),
  ];
}
