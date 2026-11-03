import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/patients/presentation/screens/patient_detail_screen.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/add_medical_test_sheet.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patient_tokens.dart';

class PatientHistoryUi {
  const PatientHistoryUi({
    required this.title,
    required this.value,
    required this.date,
    required this.icon,
    required this.tint,
    required this.iconColor,
    this.status,
    this.statusColor,
    this.statusBg,
    this.isLatest = false,
  });

  final String title;
  final String value;
  final String date;
  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String? status;
  final Color? statusColor;
  final Color? statusBg;
  final bool isLatest;
}

class PatientDetailUiMapper {
  const PatientDetailUiMapper._();

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static PatientDetailArgs toArgs(CampPatient patient) {
    final vitals = patient.vitals;
    return PatientDetailArgs(
      patientId: patient.id,
      name: patient.name.trim().isEmpty
          ? 'Unknown Patient'
          : patient.name.trim(),
      age: '${patient.age}',
      gender: switch (patient.gender) {
        CampPatientGender.female => 'female',
        CampPatientGender.male => 'male',
        CampPatientGender.other => 'other',
      },
      phone: patient.contact.trim().isEmpty ? '—' : patient.contact.trim(),
      address: patient.address.trim().isEmpty ? '—' : patient.address.trim(),
      campName: patient.campName.trim().isEmpty ? 'N/A' : patient.campName.trim(),
      registeredDate: _registered(patient.createdAt),
      reportPdfUrl: patient.reportPdfUrl,
      test: MedicalTestResult(
        packageLabel: 'General Checkup',
        weight: _num(vitals?.weight),
        height: _num(vitals?.height),
        sugar: _num(vitals?.sugar),
        sugarType: _sugarCode(vitals?.sugarType),
        bpSys: _num(vitals?.bpSys),
        bpDia: _num(vitals?.bpDia),
        temp: '',
        heartRate: '',
        oxygen: '',
      ),
    );
  }

  static List<PatientHistoryUi> toHistory(CampPatient patient) {
    final tests = [...patient.tests]
      ..sort((a, b) {
        final ad = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });

    return [
      for (var i = 0; i < tests.length; i++)
        _historyItem(tests[i], isLatest: i == 0),
    ];
  }

  static PatientHistoryUi _historyItem(
    CampPatientTest test, {
    required bool isLatest,
  }) {
    final type = test.type.trim().toLowerCase();
    final meta = switch (type) {
      'height' => (
          'Height',
          Icons.height_rounded,
          const Color(0xFFE8F1FB),
          const Color(0xFF185FA5),
        ),
      'weight' => (
          'Weight',
          Icons.monitor_weight_outlined,
          const Color(0xFFE8F7F2),
          const Color(0xFF0F6E56),
        ),
      'bp' => (
          'Bp',
          Icons.favorite_rounded,
          const Color(0xFFFFE8EC),
          const Color(0xFFE0483E),
        ),
      'sugar' => (
          'Sugar',
          Icons.water_drop_rounded,
          const Color(0xFFFFF3E6),
          const Color(0xFFD97706),
        ),
      'general_checkup' => (
          'General Checkup',
          Icons.monitor_heart_rounded,
          const Color(0xFFF3F0FF),
          kPatientPrimary,
        ),
      _ => (
          _titleCase(test.type),
          Icons.biotech_rounded,
          const Color(0xFFF0EFFE),
          kPatientPrimary,
        ),
    };

    final value = switch (type) {
      'bp' =>
        '${_fmt(test.value)}/${_fmt(test.value2 ?? 0)} ${test.unit}'.trim(),
      'sugar' =>
        '${_fmt(test.value)} ${test.sugarType ?? ''} ${test.unit}'.trim(),
      _ => '${_fmt(test.value)} ${test.unit}'.trim(),
    };

    final status = switch (type) {
      'bp' || 'sugar' => 'Normal',
      _ => null,
    };

    return PatientHistoryUi(
      title: meta.$1,
      value: value,
      date: _dateTime(test.date),
      icon: meta.$2,
      tint: meta.$3,
      iconColor: meta.$4,
      status: isLatest ? 'Latest' : status,
      statusColor:
          isLatest || status != null ? const Color(0xFF0F6E56) : null,
      statusBg:
          isLatest || status != null ? const Color(0xFFE8F7F2) : null,
      isLatest: isLatest,
    );
  }

  static String _registered(DateTime? date) {
    if (date == null) return '—';
    final d = date.toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  static String _dateTime(DateTime? date) {
    if (date == null) return '—';
    final d = date.toLocal();
    final hour24 = d.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final ampm = hour24 >= 12 ? 'PM' : 'AM';
    final min = d.minute.toString().padLeft(2, '0');
    return '${_months[d.month - 1]} ${d.day}, ${d.year} $hour12:$min $ampm';
  }

  static String _num(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  static String _fmt(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  static String _sugarCode(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'fasting':
      case 'f':
      case 'fbs':
        return 'F';
      case 'pp':
      case 'ppbs':
      case 'p':
        return 'P';
      default:
        return 'R';
    }
  }

  static String _titleCase(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return 'Test';
    return t[0].toUpperCase() + t.substring(1);
  }
}
