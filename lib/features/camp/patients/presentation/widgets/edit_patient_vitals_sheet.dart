import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/camps/data/repositories_impl/camp_repository_impl.dart';
import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/camps/domain/failures/camp_failure.dart';
import 'package:timelay_health/features/camp/camps/domain/usecases/get_patient_by_id_usecase.dart';
import 'package:timelay_health/features/camp/patients/data/repositories_impl/patient_repository_impl.dart';
import 'package:timelay_health/features/camp/patients/domain/failures/patient_failure.dart';
import 'package:timelay_health/features/camp/patients/domain/usecases/update_patient_vitals_usecase.dart';
import 'package:timelay_health/features/camp/patients/presentation/models/patient_list_ui.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patient_tokens.dart';

Future<bool> showEditPatientVitalsSheet(
  BuildContext context, {
  required PatientUi patient,
}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => EditPatientVitalsSheet(patient: patient),
  );
  return saved == true;
}

class _VitalTest {
  const _VitalTest({
    required this.id,
    required this.type,
    required this.unit,
    this.date,
  });

  final String id;
  final String type;
  final String unit;
  final DateTime? date;
}

class EditPatientVitalsSheet extends StatefulWidget {
  const EditPatientVitalsSheet({super.key, required this.patient});

  final PatientUi patient;

  @override
  State<EditPatientVitalsSheet> createState() => _EditPatientVitalsSheetState();
}

class _EditPatientVitalsSheetState extends State<EditPatientVitalsSheet> {
  final _getPatient = GetPatientByIdUseCase(CampRepositoryImpl());
  final _updateVitals = UpdatePatientVitalsUseCase(PatientRepositoryImpl());

  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _sugar = TextEditingController();
  final _bpSys = TextEditingController();

  List<_VitalTest> _tests = const [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _sugar.dispose();
    _bpSys.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = widget.patient.id.trim();
    if (id.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Patient id missing.';
      });
      return;
    }

    try {
      final patient = await _getPatient(id);
      if (!mounted) return;
      final vitals = patient.vitals;
      _tests = [
        for (final test in patient.tests)
          if (test.id.trim().isNotEmpty)
            _VitalTest(
              id: test.id,
              type: test.type,
              unit: test.unit,
              date: test.date,
            ),
      ];
      _weight.text = _text(vitals?.weight, _valueOf(patient, 'weight'));
      _height.text = _text(vitals?.height, _valueOf(patient, 'height'));
      _sugar.text = _text(vitals?.sugar, _valueOf(patient, 'sugar'));
      _bpSys.text = _text(vitals?.bpSys, _valueOf(patient, 'bp'));
      setState(() {
        _loading = false;
        _error = null;
      });
    } on CampFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load patient tests.';
      });
    }
  }

  double? _valueOf(CampPatient patient, String type) {
    final test = _latest(patient, type);
    return test?.value;
  }

  CampPatientTest? _latest(CampPatient patient, String type) {
    CampPatientTest? best;
    for (final test in patient.tests) {
      if (test.type.trim().toLowerCase() != type) continue;
      if (best == null) {
        best = test;
        continue;
      }
      final bestDate = best.date;
      final nextDate = test.date;
      if (bestDate == null ||
          (nextDate != null && nextDate.isAfter(bestDate))) {
        best = test;
      }
    }
    return best;
  }

  _VitalTest? _latestRef(String type) {
    _VitalTest? best;
    for (final test in _tests) {
      if (test.type.trim().toLowerCase() != type) continue;
      if (best == null) {
        best = test;
        continue;
      }
      final bestDate = best.date;
      final nextDate = test.date;
      if (bestDate == null ||
          (nextDate != null && nextDate.isAfter(bestDate))) {
        best = test;
      }
    }
    return best;
  }

  String _text(double? vital, double? fallback) {
    final value = vital ?? fallback;
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  void _addUpdate(
    List<UpdatePatientTestItem> items,
    String type,
    String fallbackUnit,
    String raw,
  ) {
    final text = raw.trim();
    if (text.isEmpty) return;
    final value = num.tryParse(text);
    final test = _latestRef(type);
    if (value == null || test == null || test.id.trim().isEmpty) return;
    final unit = test.unit.trim();
    items.add(
      UpdatePatientTestItem(
        testId: test.id,
        type: type,
        value: value,
        unit: unit.isEmpty ? fallbackUnit : unit,
      ),
    );
  }

  Future<void> _save() async {
    if (_saving || _loading) return;
    final patientId = widget.patient.id.trim();
    if (patientId.isEmpty) return;

    final tests = <UpdatePatientTestItem>[];
    _addUpdate(tests, 'weight', 'kg', _weight.text);
    _addUpdate(tests, 'height', 'cm', _height.text);
    _addUpdate(tests, 'sugar', 'mg/dL', _sugar.text);
    _addUpdate(tests, 'bp', 'mmHg', _bpSys.text);
    if (tests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No saved tests found to update.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _updateVitals(
        UpdatePatientVitalsParams(patientId: patientId, tests: tests),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on PatientFailure catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update vitals. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 10 + keyboard),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 16 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Update Vitals',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: kPatientHeading,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              Text(
                widget.patient.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kPatientMuted,
                ),
              ),
              const SizedBox(height: 14),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: kPatientMuted,
                    ),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _Field(label: 'Weight (kg)', controller: _weight),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Field(label: 'Height (cm)', controller: _height),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'Sugar (mg/dL)',
                        controller: _sugar,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Field(label: 'BP (mmHg)', controller: _bpSys),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: kPatientPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Update Vitals',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: kPatientMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: kPatientHeading,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF7F6FB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPatientBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPatientBorder),
            ),
          ),
        ),
      ],
    );
  }
}
