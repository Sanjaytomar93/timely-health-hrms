import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_ui_scope.dart';
import 'package:timelay_health/features/camp/patients/presentation/screens/patient_detail_screen.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/add_medical_test_sheet.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/add_patient_sheet.dart';

Future<void> openPostCreatePatientScreen(
  BuildContext context, {
  required AddPatientResult patient,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CampUiScope(
        child: PostCreatePatientScreen(patient: patient),
      ),
    ),
  );
}

class PostCreatePatientScreen extends StatefulWidget {
  const PostCreatePatientScreen({super.key, required this.patient});

  final AddPatientResult patient;

  @override
  State<PostCreatePatientScreen> createState() =>
      _PostCreatePatientScreenState();
}

class _PostCreatePatientScreenState extends State<PostCreatePatientScreen> {
  MedicalTestResult? _test;

  AddPatientResult get _patient => widget.patient;

  @override
  Widget build(BuildContext context) {
    final test = _test;
    if (test == null) {
      return AddMedicalTestSheet(
        asFullScreen: true,
        patientId: _patient.patientId,
        campId: _patient.campId,
        campName: _patient.campName,
        location: _patient.campLocation,
        dateLabel: _todayLabel(),
        patientName: _patient.patientName,
        onSaved: (result) => setState(() => _test = result),
        onCancel: () => Navigator.of(context).pop(),
      );
    }

    return PatientDetailScreen(
      args: PatientDetailArgs(
        patientId: _patient.patientId,
        name: _patient.patientName,
        age: _patient.age,
        gender: _patient.gender,
        phone: _patient.phone,
        address: _patient.address,
        campName: _patient.campName,
        test: test,
      ),
    );
  }

  String _todayLabel() {
    const months = [
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
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
