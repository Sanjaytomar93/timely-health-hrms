import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_ui_scope.dart';
import 'package:timelay_health/features/camp/patients/data/repositories_impl/patient_repository_impl.dart';
import 'package:timelay_health/features/camp/patients/domain/failures/patient_failure.dart';
import 'package:timelay_health/features/camp/patients/domain/usecases/update_patient_vitals_usecase.dart';
import 'package:timelay_health/features/camp/patients/presentation/bloc/patient_detail_cubit.dart';
import 'package:timelay_health/features/camp/patients/presentation/bloc/patient_detail_state.dart';
import 'package:timelay_health/features/camp/patients/presentation/mappers/patient_detail_ui_mapper.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/add_medical_test_sheet.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patient_tokens.dart';
import 'package:timelay_health/features/camp/shared/camp_shimmer.dart';

class PatientDetailArgs {
  const PatientDetailArgs({
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.address,
    required this.campName,
    required this.test,
    this.patientId = '',
    this.registeredDate = '02/11/2026',
    this.reportPdfUrl,
    this.history = const [],
  });

  final String patientId;
  final String name;
  final String age;
  final String gender;
  final String phone;
  final String address;
  final String campName;
  final String registeredDate;
  final MedicalTestResult test;
  final String? reportPdfUrl;
  final List<PatientHistoryUi> history;
}

Future<void> openPatientDetailScreen(
  BuildContext context, {
  required PatientDetailArgs args,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CampUiScope(
        child: PatientDetailScreen(args: args),
      ),
    ),
  );
}

Future<void> openPatientDetailById(
  BuildContext context, {
  required String patientId,
}) {
  final id = patientId.trim();
  if (id.isEmpty) return Future.value();

  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CampUiScope(
        child: BlocProvider(
          create: (_) => PatientDetailCubit()..load(id),
          child: const _PatientDetailByIdHost(),
        ),
      ),
    ),
  );
}

class _PatientDetailByIdHost extends StatelessWidget {
  const _PatientDetailByIdHost();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDetailCubit, PatientDetailState>(
      builder: (context, state) {
        if (state is PatientDetailLoading || state is PatientDetailInitial) {
          return const Scaffold(
            backgroundColor: CampColors.background,
            body: SafeArea(child: CampPatientsShimmer()),
          );
        }
        if (state is PatientDetailFailure) {
          return Scaffold(
            backgroundColor: CampColors.background,
            appBar: AppBar(
              title: const Text('Patient Details'),
              backgroundColor: Colors.white,
              foregroundColor: CampColors.heading,
              elevation: 0,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: CampColors.muted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go back'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final patient = (state as PatientDetailLoaded).patient;
        return PatientDetailScreen(
          args: PatientDetailUiMapper.toArgs(patient).copyWithHistory(
            PatientDetailUiMapper.toHistory(patient),
          ),
        );
      },
    );
  }
}

extension on PatientDetailArgs {
  PatientDetailArgs copyWithHistory(List<PatientHistoryUi> history) {
    return PatientDetailArgs(
      patientId: patientId,
      name: name,
      age: age,
      gender: gender,
      phone: phone,
      address: address,
      campName: campName,
      registeredDate: registeredDate,
      test: test,
      reportPdfUrl: reportPdfUrl,
      history: history,
    );
  }
}

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key, required this.args});

  final PatientDetailArgs args;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final _updateVitalsUseCase =
      UpdatePatientVitalsUseCase(PatientRepositoryImpl());

  late TextEditingController _weight;
  late TextEditingController _height;
  late TextEditingController _sugar;
  late TextEditingController _bpSys;
  late TextEditingController _bpDia;
  late List<_HistoryItem> _history;
  late String _sugarType;
  bool _updatingVitals = false;

  @override
  void initState() {
    super.initState();
    final t = widget.args.test;
    _weight = TextEditingController(text: t.weight);
    _height = TextEditingController(text: t.height);
    _sugar = TextEditingController(text: t.sugar);
    _bpSys = TextEditingController(text: t.bpSys);
    _bpDia = TextEditingController(text: t.bpDia);
    _sugarType = t.sugarType;
    _history = widget.args.history.isNotEmpty
        ? [
            for (final h in widget.args.history)
              _HistoryItem(
                title: h.title,
                value: h.value,
                date: h.date,
                icon: h.icon,
                tint: h.tint,
                iconColor: h.iconColor,
                status: h.status,
                statusColor: h.statusColor,
                statusBg: h.statusBg,
              ),
          ]
        : _buildHistory(t);
  }

  List<_HistoryItem> _buildHistory(MedicalTestResult t) {
    final sugarLabel = switch (t.sugarType) {
      'F' => 'FBS',
      'P' => 'PPBS',
      _ => 'RBS',
    };
    return [
      _HistoryItem(
        title: 'Oxygen',
        value: '${t.oxygen}%',
        date: 'Nov 2, 2026',
        icon: Icons.air_rounded,
        tint: const Color(0xFFEAF6FF),
        iconColor: const Color(0xFF0284C7),
        status: 'Latest',
        statusColor: const Color(0xFF0F6E56),
        statusBg: const Color(0xFFE8F7F2),
      ),
      _HistoryItem(
        title: 'Sugar',
        value: '${t.sugar} $sugarLabel mg/dL',
        date: 'Nov 2, 2026',
        icon: Icons.water_drop_rounded,
        tint: const Color(0xFFFFF3E6),
        iconColor: const Color(0xFFD97706),
        status: 'Normal',
        statusColor: const Color(0xFF0F6E56),
        statusBg: const Color(0xFFE8F7F2),
      ),
      _HistoryItem(
        title: t.packageLabel,
        value: 'Checkup Complete',
        date: 'Nov 2, 2026',
        icon: Icons.monitor_heart_rounded,
        tint: const Color(0xFFF3F0FF),
        iconColor: kPatientPrimary,
      ),
      _HistoryItem(
        title: 'BP',
        value: '${t.bpSys}/${t.bpDia} mmHg',
        date: 'Nov 2, 2026',
        icon: Icons.speed_rounded,
        tint: const Color(0xFFFFE8EC),
        iconColor: const Color(0xFFE0483E),
        status: 'Elevated',
        statusColor: const Color(0xFFB45309),
        statusBg: const Color(0xFFFFF3E6),
      ),
      _HistoryItem(
        title: 'Heart Rate',
        value: '${t.heartRate} bpm',
        date: 'Nov 2, 2026',
        icon: Icons.favorite_rounded,
        tint: const Color(0xFFFFE8EC),
        iconColor: const Color(0xFFE0483E),
      ),
      _HistoryItem(
        title: 'Height',
        value: '${t.height} cm',
        date: 'Nov 2, 2026',
        icon: Icons.height_rounded,
        tint: const Color(0xFFE8F1FB),
        iconColor: const Color(0xFF185FA5),
      ),
      _HistoryItem(
        title: 'Weight',
        value: '${t.weight} kg',
        date: 'Nov 2, 2026',
        icon: Icons.monitor_weight_outlined,
        tint: const Color(0xFFE8F7F2),
        iconColor: const Color(0xFF0F6E56),
      ),
    ];
  }

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _sugar.dispose();
    _bpSys.dispose();
    _bpDia.dispose();
    super.dispose();
  }

  Future<void> _addMoreTest() async {
    final result = await showAddMedicalTestSheet(
      context,
      campName: widget.args.campName,
      patientName: widget.args.name,
    );
    if (result == null || !mounted) return;
    setState(() {
      _weight.text = result.weight;
      _height.text = result.height;
      _sugar.text = result.sugar;
      _bpSys.text = result.bpSys;
      _bpDia.text = result.bpDia;
      _history = _buildHistory(result);
    });
  }

  String _sugarTypeLabel(String code) {
    return switch (code.trim().toUpperCase()) {
      'F' => 'Fasting',
      'P' => 'PP',
      _ => 'Random',
    };
  }

  num _parseNum(String raw) => num.tryParse(raw.trim()) ?? 0;

  Future<void> _updateVitals() async {
    if (_updatingVitals) return;
    final patientId = widget.args.patientId.trim();
    if (patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient id missing. Cannot update vitals.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _updatingVitals = true);
    try {
      await _updateVitalsUseCase(
        UpdatePatientVitalsParams(
          patientId: patientId,
          weight: _parseNum(_weight.text),
          height: _parseNum(_height.text),
          sugar: _parseNum(_sugar.text),
          systolic: _parseNum(_bpSys.text),
          diastolic: _parseNum(_bpDia.text),
          sugarType: _sugarTypeLabel(_sugarType),
        ),
      );
      if (!mounted) return;
      setState(() => _updatingVitals = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vitals updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on PatientFailure catch (e) {
      if (!mounted) return;
      setState(() => _updatingVitals = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _updatingVitals = false);
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
    final args = widget.args;
    final top = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: CampColors.background,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, top + 10, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1635), kPatientPrimary, Color(0xFF4B4285)],
                ),
              ),
              child: Row(
                children: [
                  PortalBackButton(
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Patient Details',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _PatientHeaderCard(
                    name: args.name,
                    age: args.age,
                    gender: args.gender,
                    phone: args.phone,
                    address: args.address.isEmpty ? '—' : args.address,
                    onAddTest: _addMoreTest,
                    onDownload: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report download started'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _MetaBar(
                    campName: args.campName,
                    registeredDate: args.registeredDate,
                  ),
                  const SizedBox(height: 12),
                  _VitalsCard(
                    weight: _weight,
                    height: _height,
                    sugar: _sugar,
                    bpSys: _bpSys,
                    bpDia: _bpDia,
                    updating: _updatingVitals,
                    onUpdate: _updatingVitals ? null : _updateVitals,
                  ),
                  const SizedBox(height: 12),
                  _HistoryCard(items: _history),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientHeaderCard extends StatelessWidget {
  const _PatientHeaderCard({
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.address,
    required this.onAddTest,
    required this.onDownload,
  });

  final String name;
  final String age;
  final String gender;
  final String phone;
  final String address;
  final VoidCallback onAddTest;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '?'
        : name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((e) => e[0].toUpperCase())
            .join();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPatientBorder),
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
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPatientPrimary, kPatientPrimaryLight],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kPatientHeading,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.cake_outlined, label: '$age yrs'),
              _InfoChip(icon: Icons.wc_rounded, label: gender),
              _InfoChip(icon: Icons.phone_rounded, label: phone),
              _InfoChip(icon: Icons.home_outlined, label: address),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: DecoratedBox(
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onAddTest,
                        borderRadius: BorderRadius.circular(12),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded, size: 18, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Add More Test',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: onDownload,
                    icon: const Icon(Icons.description_outlined, size: 16),
                    label: const Text(
                      'Download',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPatientHeading,
                      side: const BorderSide(color: kPatientBorder),
                      backgroundColor: const Color(0xFFF7F6FB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPatientBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: kPatientPrimary),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: kPatientHeading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBar extends StatelessWidget {
  const _MetaBar({required this.campName, required this.registeredDate});

  final String campName;
  final String registeredDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPatientBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.apartment_rounded, size: 16, color: kPatientPrimary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Camp: $campName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kPatientHeading,
              ),
            ),
          ),
          const Icon(Icons.schedule_rounded, size: 15, color: kPatientMuted),
          const SizedBox(width: 5),
          Text(
            'Registered: $registeredDate',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: kPatientMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalsCard extends StatelessWidget {
  const _VitalsCard({
    required this.weight,
    required this.height,
    required this.sugar,
    required this.bpSys,
    required this.bpDia,
    required this.updating,
    required this.onUpdate,
  });

  final TextEditingController weight;
  final TextEditingController height;
  final TextEditingController sugar;
  final TextEditingController bpSys;
  final TextEditingController bpDia;
  final bool updating;
  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPatientBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.monitor_heart_outlined, size: 18, color: kPatientPrimary),
              SizedBox(width: 8),
              Text(
                'Clinical Vitals',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kPatientHeading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _VitalInput(
                  label: 'Weight (kg)',
                  controller: weight,
                  icon: Icons.monitor_weight_outlined,
                  tint: const Color(0xFFE8F7F2),
                  iconColor: const Color(0xFF0F6E56),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VitalInput(
                  label: 'Height (cm)',
                  controller: height,
                  icon: Icons.height_rounded,
                  tint: const Color(0xFFE8F1FB),
                  iconColor: const Color(0xFF185FA5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _VitalInput(
                  label: 'Sugar (mg/dL)',
                  controller: sugar,
                  icon: Icons.water_drop_rounded,
                  tint: const Color(0xFFFFF3E6),
                  iconColor: const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BpInput(sys: bpSys, dia: bpDia),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPatientPrimary, kPatientPrimaryLight],
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: kPatientPrimary.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onUpdate,
                  borderRadius: BorderRadius.circular(13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (updating)
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
                          Icons.graphic_eq_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Update Vitals',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13.5,
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
        ],
      ),
    );
  }
}

class _VitalInput extends StatelessWidget {
  const _VitalInput({
    required this.label,
    required this.controller,
    required this.icon,
    required this.tint,
    required this.iconColor,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color tint;
  final Color iconColor;

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
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6FB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kPatientBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
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
            ],
          ),
        ),
      ],
    );
  }
}

class _BpInput extends StatelessWidget {
  const _BpInput({required this.sys, required this.dia});

  final TextEditingController sys;
  final TextEditingController dia;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BP (Sys/Dia)',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: kPatientMuted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6FB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kPatientBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8EC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.speed_rounded,
                  size: 14,
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
                    fontSize: 14,
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
              const Text(
                '/',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  color: kPatientMuted,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: dia,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
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
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryItem {
  const _HistoryItem({
    required this.title,
    required this.value,
    required this.date,
    required this.icon,
    required this.tint,
    required this.iconColor,
    this.status,
    this.statusColor,
    this.statusBg,
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
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.items});

  final List<_HistoryItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPatientBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 18, color: kPatientPrimary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Medical History',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kPatientHeading,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: kPatientPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${items.length} Records',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: kPatientPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((e) => _HistoryTile(item: e)),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final _HistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPatientBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.tint,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.icon, size: 18, color: item.iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: kPatientHeading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kPatientMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.date,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: kPatientMuted.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          if (item.status != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.statusBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.status!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: item.statusColor,
                ),
              ),
            )
          else
            const Text(
              '—',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: kPatientMuted,
              ),
            ),
        ],
      ),
    );
  }
}
