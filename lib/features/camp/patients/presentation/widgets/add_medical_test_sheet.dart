import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/features/camp/patients/data/repositories_impl/patient_repository_impl.dart';
import 'package:timelay_health/features/camp/patients/domain/failures/patient_failure.dart';
import 'package:timelay_health/features/camp/patients/domain/usecases/add_patient_test_usecase.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patient_tokens.dart';

class MedicalTestResult {
  const MedicalTestResult({
    required this.packageLabel,
    required this.weight,
    required this.height,
    required this.sugar,
    required this.sugarType,
    required this.bpSys,
    required this.bpDia,
    required this.temp,
    required this.heartRate,
    required this.oxygen,
    this.notes = '',
  });

  final String packageLabel;
  final String weight;
  final String height;
  final String sugar;
  final String sugarType;
  final String bpSys;
  final String bpDia;
  final String temp;
  final String heartRate;
  final String oxygen;
  final String notes;
}

Future<MedicalTestResult?> showAddMedicalTestSheet(
  BuildContext context, {
  String campName = 'Testing camp',
  String location = 'Hyderabad',
  String dateLabel = 'Nov 2, 2026',
  String patientName = '',
}) {
  return showDialog<MedicalTestResult>(
    context: context,
    barrierColor: const Color(0x88000000),
    builder: (_) => AddMedicalTestSheet(
      campName: campName,
      location: location,
      dateLabel: dateLabel,
      patientName: patientName,
    ),
  );
}

enum _TestPackage { general, eye, blood, fullBody }

enum _FormTab { vitals, details }

class AddMedicalTestSheet extends StatefulWidget {
  const AddMedicalTestSheet({
    super.key,
    required this.campName,
    required this.location,
    required this.dateLabel,
    this.patientName = '',
    this.patientId = '',
    this.campId = '',
    this.asFullScreen = false,
    this.onSaved,
    this.onCancel,
  });

  final String campName;
  final String location;
  final String dateLabel;
  final String patientName;
  final String patientId;
  final String campId;
  final bool asFullScreen;
  final ValueChanged<MedicalTestResult>? onSaved;
  final VoidCallback? onCancel;

  @override
  State<AddMedicalTestSheet> createState() => _AddMedicalTestSheetState();
}

class _AddMedicalTestSheetState extends State<AddMedicalTestSheet> {
  final _addPatientTest = AddPatientTestUseCase(PatientRepositoryImpl());

  _TestPackage _package = _TestPackage.general;
  _FormTab _tab = _FormTab.vitals;
  String _sugarType = 'R';
  bool _submitting = false;

  final _weight = TextEditingController(text: '70');
  final _height = TextEditingController(text: '175');
  final _sugar = TextEditingController(text: '90');
  final _bpSys = TextEditingController(text: '120');
  final _bpDia = TextEditingController(text: '80');
  final _temp = TextEditingController(text: '98.6');
  final _heart = TextEditingController(text: '72');
  final _oxygen = TextEditingController(text: '98');
  final _notes = TextEditingController();

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _sugar.dispose();
    _bpSys.dispose();
    _bpDia.dispose();
    _temp.dispose();
    _heart.dispose();
    _oxygen.dispose();
    _notes.dispose();
    super.dispose();
  }

  String get _packageLabel => switch (_package) {
        _TestPackage.general => 'General Checkup',
        _TestPackage.eye => 'Eye',
        _TestPackage.blood => 'Blood',
        _TestPackage.fullBody => 'Full Body',
      };

  String get _saveLabel => 'Save $_packageLabel';

  ({String type, String campType, num value, String unit}) get _packagePayload {
    return switch (_package) {
      _TestPackage.general => (
          type: 'general_checkup',
          campType: 'general',
          value: 1,
          unit: 'checkup',
        ),
      _TestPackage.eye => (
          type: 'eye',
          campType: 'eye',
          value: 1,
          unit: 'checkup',
        ),
      _TestPackage.blood => (
          type: 'blood',
          campType: 'blood',
          value: 1,
          unit: 'checkup',
        ),
      _TestPackage.fullBody => (
          type: 'full_body',
          campType: 'full_body',
          value: 1,
          unit: 'checkup',
        ),
    };
  }

  double _bmi() {
    final weight = double.tryParse(_weight.text.trim()) ?? 0;
    final heightCm = double.tryParse(_height.text.trim()) ?? 0;
    if (weight <= 0 || heightCm <= 0) return 0;
    final heightM = heightCm / 100;
    return double.parse((weight / (heightM * heightM)).toStringAsFixed(1));
  }

  MedicalTestResult _buildResult() {
    return MedicalTestResult(
      packageLabel: _packageLabel,
      weight: _weight.text.trim(),
      height: _height.text.trim(),
      sugar: _sugar.text.trim(),
      sugarType: _sugarType,
      bpSys: _bpSys.text.trim(),
      bpDia: _bpDia.text.trim(),
      temp: _temp.text.trim(),
      heartRate: _heart.text.trim(),
      oxygen: _oxygen.text.trim(),
      notes: _notes.text.trim(),
    );
  }

  Future<void> _save() async {
    if (_submitting) return;
    final result = _buildResult();
    final patientId = widget.patientId.trim();

    if (patientId.isEmpty) {
      if (widget.asFullScreen) {
        widget.onSaved?.call(result);
        return;
      }
      Navigator.of(context).pop(result);
      return;
    }

    setState(() => _submitting = true);
    final now = DateTime.now();
    final campDay = DateTime.utc(now.year, now.month, now.day);
    final payload = _packagePayload;

    try {
      await _addPatientTest(
        AddPatientTestParams(
          patientId: patientId,
          type: payload.type,
          value: payload.value,
          unit: payload.unit,
          bmi: _bmi(),
          campType: payload.campType,
          campDate: campDay,
          campId: widget.campId.trim(),
          campLocation: widget.location.trim(),
          campName: widget.campName.trim(),
          date: now.toUtc(),
        ),
      );
      if (!mounted) return;
      if (widget.asFullScreen) {
        widget.onSaved?.call(result);
        return;
      }
      Navigator.of(context).pop(result);
    } on PatientFailure catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save medical test. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _cancel() {
    if (widget.asFullScreen) {
      widget.onCancel?.call();
      return;
    }
    Navigator.of(context).pop();
  }

  Widget _content({bool extendHeroUnderStatusBar = false}) {
    return Column(
      children: [
        _HeroHeader(
          patientName: widget.patientName,
          onClose: _cancel,
          extendUnderStatusBar: extendHeroUnderStatusBar,
        ),
        Expanded(
          child: ColoredBox(
            color: const Color(0xFFF6F5FB),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActiveCampCard(
                    campName: widget.campName,
                    location: widget.location,
                    dateLabel: widget.dateLabel,
                  ),
                  const SizedBox(height: 16),
                  const _SectionLabel(
                    'Select Test Package',
                    subtitle: 'Choose the checkup type for this patient',
                  ),
                  const SizedBox(height: 8),
                  _PackageGrid(
                    selected: _package,
                    onSelected: (v) => setState(() => _package = v),
                  ),
                  const SizedBox(height: 14),
                  const _SectionLabel(
                    'Enter Readings',
                    subtitle: 'Fill vitals or add extra notes',
                  ),
                  const SizedBox(height: 8),
                  _TabSwitcher(
                    selected: _tab,
                    onSelected: (v) => setState(() => _tab = v),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _tab == _FormTab.vitals
                        ? _VitalsCard(
                            key: const ValueKey('vitals'),
                            weight: _weight,
                            height: _height,
                            sugar: _sugar,
                            sugarType: _sugarType,
                            onSugarTypeChanged: (v) =>
                                setState(() => _sugarType = v),
                            bpSys: _bpSys,
                            bpDia: _bpDia,
                            temp: _temp,
                            heart: _heart,
                            oxygen: _oxygen,
                          )
                        : _DetailsCard(
                            key: const ValueKey('details'),
                            notes: _notes,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: _Footer(
            saveLabel: _saveLabel,
            submitting: _submitting,
            onSave: _submitting ? null : _save,
            onCancel: _submitting ? null : _cancel,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asFullScreen) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFF1A1635),
          body: ColoredBox(
            color: const Color(0xFFF4F3F8),
            child: _content(extendHeroUnderStatusBar: true),
          ),
        ),
      );
    }

    final size = MediaQuery.sizeOf(context);
    final width = (size.width - 20).clamp(300.0, 480.0);
    final maxH = size.height * 0.94;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      backgroundColor: Colors.transparent,
      child: Container(
        width: width,
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F3F8),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: kPatientPrimary.withValues(alpha: 0.28),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: _content(),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.patientName,
    required this.onClose,
    this.extendUnderStatusBar = false,
  });

  final String patientName;
  final VoidCallback onClose;
  final bool extendUnderStatusBar;

  @override
  Widget build(BuildContext context) {
    final topInset = extendUnderStatusBar
        ? MediaQuery.paddingOf(context).top
        : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 12 + topInset, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1635), kPatientPrimary, Color(0xFF4B4285)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            right: 56,
            bottom: -36,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 10,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PortalBackButton(onTap: onClose),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Medical Test',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          patientName.isNotEmpty
                              ? 'Recording vitals for $patientName'
                              : 'Record patient health metrics',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.monitor_heart_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
              if (patientName.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.28),
                              Colors.white.withValues(alpha: 0.12),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patientName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Patient',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7EFFD4).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 11,
                              color: Color(0xFF7EFFD4),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Created',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7EFFD4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveCampCard extends StatelessWidget {
  const _ActiveCampCard({
    required this.campName,
    required this.location,
    required this.dateLabel,
  });

  final String campName;
  final String location;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            kPatientPrimary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kPatientPrimary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: kPatientPrimary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPatientPrimary, kPatientPrimaryLight],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: kPatientPrimary.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: kPatientPrimary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ACTIVE CAMP',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: kPatientPrimary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      campName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kPatientHeading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (location.trim().isNotEmpty)
                _MetaPill(icon: Icons.location_on_rounded, label: location),
              if (dateLabel.trim().isNotEmpty)
                _MetaPill(icon: Icons.calendar_month_rounded, label: dateLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kPatientBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: kPatientPrimary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: kPatientHeading,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.subtitle});

  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3,
          height: subtitle == null ? 14 : 28,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: kPatientPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kPatientHeading,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: kPatientMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PackageGrid extends StatelessWidget {
  const _PackageGrid({required this.selected, required this.onSelected});

  final _TestPackage selected;
  final ValueChanged<_TestPackage> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        _TestPackage.general,
        Icons.monitor_heart_rounded,
        'General',
        'Basic checkup',
        Color(0xFFE8F7F2),
        Color(0xFF0F6E56),
      ),
      (
        _TestPackage.eye,
        Icons.visibility_rounded,
        'Eye',
        'Vision screening',
        Color(0xFFE8F1FB),
        Color(0xFF185FA5),
      ),
      (
        _TestPackage.blood,
        Icons.bloodtype_rounded,
        'Blood',
        'Lab markers',
        Color(0xFFFDECEC),
        Color(0xFFC0392B),
      ),
      (
        _TestPackage.fullBody,
        Icons.accessibility_new_rounded,
        'Full Body',
        'Complete profile',
        Color(0xFFF3F0FF),
        Color(0xFF534AB7),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 70,
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        final active = selected == item.$1;
        return GestureDetector(
          onTap: () => onSelected(item.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
            decoration: BoxDecoration(
              color: active ? item.$5 : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? item.$6.withValues(alpha: 0.4) : kPatientBorder,
                width: active ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: active
                      ? item.$6.withValues(alpha: 0.16)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: active ? 10 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: active ? item.$6 : const Color(0xFFF3F2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.$2,
                    size: 16,
                    color: active ? Colors.white : kPatientMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.$3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: active ? item.$6 : kPatientHeading,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.$4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: active
                              ? item.$6.withValues(alpha: 0.85)
                              : kPatientMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (active)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: item.$6,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.selected, required this.onSelected});

  final _FormTab selected;
  final ValueChanged<_FormTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPatientBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabChip(
              label: 'Vitals',
              icon: Icons.favorite_rounded,
              active: selected == _FormTab.vitals,
              onTap: () => onSelected(_FormTab.vitals),
            ),
          ),
          Expanded(
            child: _TabChip(
              label: 'Details',
              icon: Icons.edit_note_rounded,
              active: selected == _FormTab.details,
              onTap: () => onSelected(_FormTab.details),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: active ? kPatientPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: kPatientPrimary.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: active ? Colors.white : kPatientMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : kPatientMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalsCard extends StatelessWidget {
  const _VitalsCard({
    super.key,
    required this.weight,
    required this.height,
    required this.sugar,
    required this.sugarType,
    required this.onSugarTypeChanged,
    required this.bpSys,
    required this.bpDia,
    required this.temp,
    required this.heart,
    required this.oxygen,
  });

  final TextEditingController weight;
  final TextEditingController height;
  final TextEditingController sugar;
  final String sugarType;
  final ValueChanged<String> onSugarTypeChanged;
  final TextEditingController bpSys;
  final TextEditingController bpDia;
  final TextEditingController temp;
  final TextEditingController heart;
  final TextEditingController oxygen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kPatientBorder),
        boxShadow: [
          BoxShadow(
            color: kPatientPrimary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0483E), Color(0xFFFF8A80)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Vitals',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: kPatientHeading,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Weight, BP, sugar and more',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: kPatientMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _VitalField(
                  label: 'Weight',
                  controller: weight,
                  unit: 'kg',
                  icon: Icons.monitor_weight_outlined,
                  tint: const Color(0xFFE8F7F2),
                  iconColor: const Color(0xFF0F6E56),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VitalField(
                  label: 'Height',
                  controller: height,
                  unit: 'cm',
                  icon: Icons.height_rounded,
                  tint: const Color(0xFFE8F1FB),
                  iconColor: const Color(0xFF185FA5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SugarField(
            controller: sugar,
            sugarType: sugarType,
            onTypeChanged: onSugarTypeChanged,
          ),
          const SizedBox(height: 10),
          _BpField(sys: bpSys, dia: bpDia),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _VitalField(
                  label: 'Temp',
                  controller: temp,
                  unit: '°F',
                  icon: Icons.thermostat_rounded,
                  tint: const Color(0xFFFFF3E6),
                  iconColor: const Color(0xFFD97706),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VitalField(
                  label: 'Heart Rate',
                  controller: heart,
                  unit: 'bpm',
                  icon: Icons.favorite_rounded,
                  tint: const Color(0xFFFFE8EC),
                  iconColor: const Color(0xFFE0483E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _VitalField(
            label: 'Oxygen',
            controller: oxygen,
            unit: '%',
            icon: Icons.air_rounded,
            tint: const Color(0xFFEAF6FF),
            iconColor: const Color(0xFF0284C7),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({super.key, required this.notes});

  final TextEditingController notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kPatientBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPatientPrimary, kPatientPrimaryLight],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  size: 17,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Details',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: kPatientHeading,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Notes, symptoms or observations',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: kPatientMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: notes,
            minLines: 5,
            maxLines: 7,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              color: kPatientHeading,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'Enter notes, symptoms, or observations…',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                color: kPatientMuted.withValues(alpha: 0.8),
              ),
              filled: true,
              fillColor: const Color(0xFFF7F6FB),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kPatientPrimary, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.saveLabel,
    required this.submitting,
    required this.onSave,
    required this.onCancel,
  });

  final String saveLabel;
  final bool submitting;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPatientPrimaryDark, kPatientPrimary, kPatientPrimaryLight],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: kPatientPrimary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSave,
                  borderRadius: BorderRadius.circular(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (submitting)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else ...[
                        const Icon(
                          Icons.save_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          saveLabel,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                foregroundColor: kPatientHeading,
                backgroundColor: const Color(0xFFF1F0F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalField extends StatelessWidget {
  const _VitalField({
    required this.label,
    required this.controller,
    required this.unit,
    required this.icon,
    required this.tint,
    required this.iconColor,
    this.keyboardType = TextInputType.number,
  });

  final String label;
  final TextEditingController controller;
  final String unit;
  final IconData icon;
  final Color tint;
  final Color iconColor;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: kPatientHeading,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6FB),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: kPatientBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 15, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: kPatientHeading,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: kPatientMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SugarField extends StatelessWidget {
  const _SugarField({
    required this.controller,
    required this.sugarType,
    required this.onTypeChanged,
  });

  final TextEditingController controller;
  final String sugarType;
  final ValueChanged<String> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sugar',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: kPatientHeading,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6FB),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: kPatientBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E6),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  size: 15,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: kPatientHeading,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'mg/dL',
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: kPatientPrimary,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: sugarType,
                    isDense: true,
                    dropdownColor: Colors.white,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    selectedItemBuilder: (context) => const [
                      Center(child: Text('F', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                      Center(child: Text('R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                      Center(child: Text('P', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                    ],
                    items: const [
                      DropdownMenuItem(
                        value: 'F',
                        child: Text('F · Fasting', style: TextStyle(color: kPatientHeading)),
                      ),
                      DropdownMenuItem(
                        value: 'R',
                        child: Text('R · Random', style: TextStyle(color: kPatientHeading)),
                      ),
                      DropdownMenuItem(
                        value: 'P',
                        child: Text('P · PP', style: TextStyle(color: kPatientHeading)),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) onTypeChanged(v);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BpField extends StatelessWidget {
  const _BpField({required this.sys, required this.dia});

  final TextEditingController sys;
  final TextEditingController dia;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Blood Pressure',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: kPatientHeading,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6FB),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: kPatientBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8EC),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.speed_rounded,
                  size: 15,
                  color: Color(0xFFE0483E),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: sys,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: kPatientHeading,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Sys',
                  ),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kPatientPrimary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '/',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: kPatientPrimary,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: dia,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: kPatientHeading,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Dia',
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'mmHg',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: kPatientMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
