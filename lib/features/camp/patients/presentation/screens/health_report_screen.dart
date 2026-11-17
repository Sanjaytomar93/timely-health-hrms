import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_ui_scope.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/utils/camp_pdf_delivery.dart';
import 'package:timelay_health/features/camp/patients/presentation/bloc/patient_detail_cubit.dart';
import 'package:timelay_health/features/camp/patients/presentation/bloc/patient_detail_state.dart';
import 'package:timelay_health/features/camp/patients/presentation/utils/health_report_pdf.dart';
import 'package:timelay_health/features/camp/shared/camp_shimmer.dart';

const _kBlue = Color(0xFF447EB5);
const _kTeal = Color(0xFF0D8A7A);
const _kOrange = Color(0xFFEF7D31);
const _kGreen = Color(0xFF1FA971);
const _kRed = Color(0xFFE0483E);
const _kLabel = Color(0xFF6B7280);
const _kValue = Color(0xFF111827);
const _kBorder = Color(0xFFD1D5DB);

Future<void> openHealthReportById(
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
          child: const HealthReportScreen(),
        ),
      ),
    ),
  );
}

class HealthReportScreen extends StatelessWidget {
  const HealthReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDetailCubit, PatientDetailState>(
      builder: (context, state) {
        if (state is PatientDetailLoading || state is PatientDetailInitial) {
          return const Scaffold(
            backgroundColor: Color(0xFFF3F5F8),
            body: SafeArea(child: CampPatientsShimmer()),
          );
        }
        if (state is PatientDetailFailure) {
          return Scaffold(
            backgroundColor: CampColors.background,
            appBar: AppBar(
              title: const Text('Health Report'),
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
                      style: const TextStyle(fontSize: 13, color: CampColors.muted),
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
        return _HealthReportBody(
          patient: (state as PatientDetailLoaded).patient,
        );
      },
    );
  }
}

class _HealthReportBody extends StatefulWidget {
  const _HealthReportBody({required this.patient});

  final CampPatient patient;

  @override
  State<_HealthReportBody> createState() => _HealthReportBodyState();
}

class _HealthReportBodyState extends State<_HealthReportBody> {
  bool _downloading = false;

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    final data = HealthReportData.fromPatient(patient);
    final top = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F8),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(20, top + 8, 20, 10),
              child: Row(
                children: [
                  PortalBackButton(
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Health Report',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: CampColors.heading,
                      ),
                    ),
                  ),
                  _IconBtn(
                    icon: Icons.download_rounded,
                    loading: _downloading,
                    onTap: _downloading ? null : () => _download(patient),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/timely_health_logo.png',
                              height: 42,
                              fit: BoxFit.contain,
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'HEALTH REPORT',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: _kBlue,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Date: ${data.reportDate}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: _kLabel,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(height: 1.5, color: _kBlue),
                        const SizedBox(height: 12),
                        _InfoRow('Name', data.name, 'Age', data.age),
                        _InfoRow(
                          'Sample ID',
                          data.sampleId,
                          'Date',
                          data.reportDate,
                        ),
                        _InfoRow(
                          'Gender',
                          data.gender,
                          'Location',
                          data.location,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'CLINICAL VITALS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _kBlue,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(height: 1.5, color: _kBlue),
                        const SizedBox(height: 6),
                        Container(height: 1.5, color: _kBlue),
                        _VitalsTable(rows: data.rows),
                        if (data.bmi != null) ...[
                          const SizedBox(height: 16),
                          // BMI orange + arrow + scale in one box (website)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFB8C0CC),
                                width: 1.2,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  color: _kOrange,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'BMI ANALYSIS',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'VALUE : ${data.bmi!.toStringAsFixed(1)}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'STATUS : ${data.bmiCategory.toUpperCase()}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _BmiScale(bmi: data.bmi!),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Center(
                            child: Text(
                              'BMI REFERENCE CHART',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _kValue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: FractionallySizedBox(
                              widthFactor: 0.72,
                              child: Image.asset(
                                'assets/images/health_report_bmi_chart.jpg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Center(
                            child: Text(
                              'Standard BMI classification',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10.5,
                                color: _kLabel,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, thickness: 1, color: _kBorder),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Doctor's Signature",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _kValue,
                                    ),
                                  ),
                                  SizedBox(height: 28),
                                  SizedBox(
                                    width: 120,
                                    child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: _kLabel,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              'assets/images/payslip_seal.png',
                              width: 86,
                              height: 86,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: _kTeal,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: const Column(
                      children: [
                        Text(
                          'Timely Healthtech Private Limited',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Flat No:301, H.No:1-68/22, Plot No. 54 & 55, Sri Sai Balaji Avenue, Arunodaya Colony, Madhapur, Hyderabad, Telangana-500081',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9.5,
                            color: Colors.white,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Mail: timelyglobal.in@gmail.com       Mobile: 90 1048 1048       www.timelyhealth.in',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _download(CampPatient patient) async {
    if (_downloading) return;
    final chosen = await showCampPdfActionSheet(context);
    if (chosen == null || !mounted) return;

    setState(() => _downloading = true);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Preparing health report PDF...'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    try {
      final path = await HealthReportPdf.download(patient, action: chosen);
      if (!mounted) return;
      if (chosen == CampPdfAction.download) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              path == null
                  ? 'Nothing to download.'
                  : 'Downloaded: ${path.split('/').last}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not download report. Try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F5F8),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 36,
          height: 36,
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(9),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, size: 18, color: CampColors.heading),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.l1, this.v1, this.l2, this.v2);

  final String l1;
  final String v1;
  final String l2;
  final String v2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: _cell(l1, v1)),
          const SizedBox(width: 10),
          Expanded(child: _cell(l2, v2)),
        ],
      ),
    );
  }

  Widget _cell(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label :  ',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _kLabel,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _kValue,
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalsTable extends StatelessWidget {
  const _VitalsTable({required this.rows});

  final List<HealthReportRow> rows;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: _kBorder, width: 1),
      columnWidths: const {
        0: FlexColumnWidth(2.5),
        1: FlexColumnWidth(1.3),
        2: FlexColumnWidth(1.0),
        3: FlexColumnWidth(1.4),
        4: FlexColumnWidth(1.1),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: _kBlue),
          children: [
            for (final h in const [
              'TEST DESCRIPTION',
              'OBSERVED VALUE',
              'UNIT',
              'REFERENCE RANGE',
              'STATUS',
            ])
              Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 3, vertical: 9),
                child: Text(
                  h,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
              ),
          ],
        ),
        for (final row in rows)
          TableRow(
            children: [
              _td(row.description, align: TextAlign.left, bold: true),
              _td(row.value),
              _td(row.unit),
              _td(row.range),
              _td(
                row.status,
                bold: row.statusTone != null,
                color: row.statusTone == 'green'
                    ? _kGreen
                    : row.statusTone == 'red'
                        ? _kRed
                        : null,
              ),
            ],
          ),
      ],
    );
  }

  static Widget _td(
    String text, {
    TextAlign align = TextAlign.center,
    Color? color,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10.5,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          color: color ?? _kValue,
          height: 1.2,
        ),
      ),
    );
  }
}

class _BmiScale extends StatelessWidget {
  const _BmiScale({required this.bmi});

  final double bmi;

  /// BMI → 0..1 across 4 equal bands (same as PDF).
  static double _bmiFraction(double bmi) {
    if (bmi < 18.5) {
      return ((bmi.clamp(12.0, 18.5) - 12) / (18.5 - 12)) * 0.25;
    }
    if (bmi < 25) {
      return 0.25 + ((bmi - 18.5) / (25 - 18.5)) * 0.25;
    }
    if (bmi < 30) {
      return 0.5 + ((bmi - 25) / (30 - 25)) * 0.25;
    }
    return 0.75 + (((bmi - 30).clamp(0.0, 10.0)) / 10) * 0.25;
  }

  @override
  Widget build(BuildContext context) {
    final alignX = _bmiFraction(bmi) * 2 - 1;
    const cats = [
      (Color(0xFF4FC3F7), 'Underweight', '<18.5'),
      (Color(0xFF66BB6A), 'Healthy', '18.5 – 24.9'),
      (Color(0xFFFFA726), 'Overweight', '25 – 29.9'),
      (Color(0xFFEF5350), 'Obese', '>30'),
    ];

    return Column(
      children: [
        SizedBox(
          height: 16,
          width: double.infinity,
          child: Align(
            alignment: Alignment(alignX, 0),
            child: const _DownTriangle(),
          ),
        ),
        Row(
          children: [
            for (final cat in cats)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  color: cat.$1,
                  child: Column(
                    children: [
                      Text(
                        cat.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        cat.$3,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DownTriangle extends StatelessWidget {
  const _DownTriangle();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 9),
      painter: _TrianglePainter(),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF374151));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
