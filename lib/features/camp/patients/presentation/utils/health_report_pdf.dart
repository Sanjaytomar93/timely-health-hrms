import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/utils/camp_pdf_delivery.dart';

/// Exact website Timely Health Report PDF (single page).
class HealthReportPdf {
  const HealthReportPdf._();

  static const _logo = 'assets/images/timely_health_logo.png';
  static const _seal = 'assets/images/payslip_seal.png';
  static const _bmiChart = 'assets/images/health_report_bmi_chart.jpg';
  static const _regularFont = 'assets/fonts/NotoSans-Regular.ttf';
  static const _boldFont = 'assets/fonts/NotoSans-Bold.ttf';

  static const _blue = PdfColor.fromInt(0xFF447EB5);
  static const _teal = PdfColor.fromInt(0xFF0F8A7C);
  static const _orange = PdfColor.fromInt(0xFFEF7D31);
  static const _green = PdfColor.fromInt(0xFF1FA971);
  static const _red = PdfColor.fromInt(0xFFE0483E);
  static const _label = PdfColor.fromInt(0xFF6B7280);
  static const _value = PdfColor.fromInt(0xFF111827);
  static const _border = PdfColor.fromInt(0xFFD8DEE6);
  static const _arrow = PdfColor.fromInt(0xFF374151);

  static Future<String?> download(
    CampPatient patient, {
    CampPdfAction action = CampPdfAction.share,
  }) async {
    final data = HealthReportData.fromPatient(patient);
    final logo = pw.MemoryImage(
      (await rootBundle.load(_logo)).buffer.asUint8List(),
    );
    final seal = pw.MemoryImage(
      (await rootBundle.load(_seal)).buffer.asUint8List(),
    );
    final chart = pw.MemoryImage(
      (await rootBundle.load(_bmiChart)).buffer.asUint8List(),
    );
    final regular = pw.Font.ttf(await rootBundle.load(_regularFont));
    final bold = pw.Font.ttf(await rootBundle.load(_boldFont));

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(26, 20, 26, 16),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (_) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(logo, height: 40),
                  pw.Spacer(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'HEALTH REPORT',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: _blue,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Date: ${data.reportDate}',
                        style: const pw.TextStyle(fontSize: 10, color: _label),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Container(height: 1.5, color: _blue),
              pw.SizedBox(height: 12),

              // Patient info
              _infoGrid(data),
              pw.SizedBox(height: 14),

              // CLINICAL VITALS — title + double blue underline
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'CLINICAL VITALS',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: _blue,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(height: 1.5, color: _blue),
              pw.SizedBox(height: 6),
              pw.Container(height: 1.5, color: _blue),

              pw.Table(
                border: pw.TableBorder.all(color: _border, width: 0.7),
                columnWidths: const {
                  0: pw.FlexColumnWidth(2.55),
                  1: pw.FlexColumnWidth(1.35),
                  2: pw.FlexColumnWidth(1.0),
                  3: pw.FlexColumnWidth(1.45),
                  4: pw.FlexColumnWidth(1.15),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: _blue),
                    children: [
                      for (final h in const [
                        'TEST DESCRIPTION',
                        'OBSERVED VALUE',
                        'UNIT',
                        'REFERENCE RANGE',
                        'STATUS',
                      ])
                        _th(h),
                    ],
                  ),
                  for (final row in data.rows)
                    pw.TableRow(
                      children: [
                        _td(row.description, bold: true, left: true),
                        _td(row.value),
                        _td(row.unit),
                        _td(row.range),
                        _td(
                          row.status,
                          bold: row.statusTone != null,
                          color: row.statusTone == 'green'
                              ? _green
                              : row.statusTone == 'red'
                                  ? _red
                                  : null,
                        ),
                      ],
                    ),
                ],
              ),

              if (data.bmi != null) ...[
                pw.SizedBox(height: 16),
                // BMI orange + arrow + scale in ONE box
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColor.fromInt(0xFFB8C0CC),
                      width: 1.2,
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Container(
                        width: double.infinity,
                        color: _orange,
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'BMI ANALYSIS',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                'VALUE : ${data.bmi!.toStringAsFixed(1)}',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                'STATUS : ${data.bmiCategory.toUpperCase()}',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _bmiScale(data.bmi!),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Center(
                  child: pw.Text(
                    'BMI REFERENCE CHART',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: _value,
                    ),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.SizedBox(
                    width: 380,
                    height: 220,
                    child: pw.Image(chart, fit: pw.BoxFit.contain),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Center(
                  child: pw.Text(
                    'Standard BMI classification',
                    style: const pw.TextStyle(fontSize: 8, color: _label),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(height: 0.9, color: _border),
              ],

              pw.Spacer(),

              // Signature + stamp
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Doctor's Signature",
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: _value,
                          ),
                        ),
                        pw.SizedBox(height: 28),
                        pw.Container(width: 130, height: 0.9, color: _label),
                      ],
                    ),
                  ),
                  pw.Image(seal, width: 78, height: 78),
                ],
              ),
              pw.SizedBox(height: 10),

              // Teal footer
              pw.Container(
                color: _teal,
                padding: const pw.EdgeInsets.fromLTRB(10, 7, 10, 7),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Timely Healthtech Private Limited',
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Flat No:301, H.No:1-68/22, Plot No. 54 & 55, Sri Sai Balaji Avenue, Arunodaya Colony, Madhapur, Hyderabad, Telangana-500081',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(
                        fontSize: 7.2,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Mail: timelyglobal.in@gmail.com       Mobile: 90 1048 1048       www.timelyhealth.in',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    final safeName = data.name.replaceAll(RegExp(r'[^\w\- ]'), '').trim();
    final fileName =
        '${safeName.isEmpty ? 'Health' : safeName}_Health_Report.pdf'
            .replaceAll(' ', '_');
    return CampPdfDelivery.deliver(
      bytes: await doc.save(),
      fileName: fileName,
      action: action,
      subject: 'Health Report - ${data.name}',
    );
  }

  static pw.Widget _infoGrid(HealthReportData data) {
    pw.Widget cell(String label, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: '$label :  ',
                style: const pw.TextStyle(fontSize: 10, color: _label),
              ),
              pw.TextSpan(
                text: value,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _value,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return pw.Column(
      children: [
        pw.Row(children: [
          pw.Expanded(child: cell('Name', data.name)),
          pw.Expanded(child: cell('Age', data.age)),
        ]),
        pw.Row(children: [
          pw.Expanded(child: cell('Sample ID', data.sampleId)),
          pw.Expanded(child: cell('Date', data.reportDate)),
        ]),
        pw.Row(children: [
          pw.Expanded(child: cell('Gender', data.gender)),
          pw.Expanded(child: cell('Location', data.location)),
        ]),
      ],
    );
  }

  static pw.Widget _th(String text) => pw.Container(
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 8),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
            letterSpacing: 0.2,
          ),
        ),
      );

  static pw.Widget _td(
    String text, {
    bool bold = false,
    bool left = false,
    PdfColor? color,
  }) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        child: pw.Text(
          text,
          textAlign: left ? pw.TextAlign.left : pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color ?? _value,
          ),
        ),
      );

  static pw.Widget _triangle() {
    return pw.CustomPaint(
      size: const PdfPoint(12, 9),
      painter: (PdfGraphics canvas, PdfPoint size) {
        // PDF y-up: tip at y=0 → ▼ pointing down.
        canvas
          ..setFillColor(_arrow)
          ..moveTo(size.x / 2, 0)
          ..lineTo(0, size.y)
          ..lineTo(size.x, size.y)
          ..closePath()
          ..fillPath();
      },
    );
  }

  /// BMI → 0..1 across 4 equal bands (same as screen).
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

  static pw.Widget _bmiScale(double bmi) {
    final frac = _bmiFraction(bmi);
    final cats = [
      (PdfColor.fromInt(0xFF4FC3F7), 'Underweight', '<18.5'),
      (PdfColor.fromInt(0xFF66BB6A), 'Healthy', '18.5 – 24.9'),
      (PdfColor.fromInt(0xFFFFA726), 'Overweight', '25 – 29.9'),
      (PdfColor.fromInt(0xFFEF5350), 'Obese', '>30'),
    ];

    return pw.Column(
      children: [
        pw.SizedBox(
          height: 14,
          child: pw.Align(
            alignment: pw.Alignment(frac * 2 - 1, 0),
            child: _triangle(),
          ),
        ),
        pw.Row(
          children: [
            for (final c in cats)
              pw.Expanded(
                child: pw.Container(
                  color: c.$1,
                  padding: const pw.EdgeInsets.symmetric(vertical: 6),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        c.$2,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        c.$3,
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 7,
                          color: PdfColors.white,
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

class HealthReportRow {
  const HealthReportRow({
    required this.description,
    required this.value,
    required this.unit,
    required this.range,
    required this.status,
    this.statusTone,
  });

  final String description;
  final String value;
  final String unit;
  final String range;
  final String status;
  final String? statusTone;
}

class HealthReportData {
  const HealthReportData({
    required this.name,
    required this.age,
    required this.sampleId,
    required this.reportDate,
    required this.gender,
    required this.location,
    required this.rows,
    required this.bmi,
    required this.bmiCategory,
  });

  final String name;
  final String age;
  final String sampleId;
  final String reportDate;
  final String gender;
  final String location;
  final List<HealthReportRow> rows;
  final double? bmi;
  final String bmiCategory;

  factory HealthReportData.fromPatient(CampPatient patient) {
    final v = patient.vitals;
    final sugar = v?.sugar ?? _testValue(patient, 'sugar');
    final sugarType = _sugarLabel(v?.sugarType ?? _testSugarType(patient));
    final bpSys = v?.bpSys ?? _testValue(patient, 'bp');
    final bpDia = v?.bpDia ?? _testValue2(patient, 'bp');
    final height = v?.height ?? _testValue(patient, 'height');
    final weight = v?.weight ?? _testValue(patient, 'weight');
    final bmi = v?.bmi ?? _calcBmi(weight, height);
    final category = (v?.bmiCategory?.trim().isNotEmpty ?? false)
        ? v!.bmiCategory!.trim()
        : _bmiCategory(bmi);
    final sugarStatus = _sugarStatus(sugar);
    final bpStatus = _bpStatus(bpSys, bpDia);

    return HealthReportData(
      name: patient.displayName.trim().isEmpty
          ? 'Unknown'
          : patient.displayName.trim(),
      age: '${patient.age}',
      sampleId: _sampleId(patient.id),
      reportDate: _fmtDate(DateTime.now()),
      gender: switch (patient.gender) {
        CampPatientGender.female => 'female',
        CampPatientGender.male => 'male',
        CampPatientGender.other => 'other',
      },
      location: patient.campLocation.trim().isNotEmpty
          ? patient.campLocation.trim()
          : (patient.campName.trim().isEmpty ? '—' : patient.campName.trim()),
      rows: [
        HealthReportRow(
          description: 'BLOOD SUGAR ($sugarType)',
          value: _num(sugar),
          unit: 'mg/dL',
          range: sugarType == 'Fasting' ? '70-100' : '70-140',
          status: sugarStatus.$1,
          statusTone: sugarStatus.$2,
        ),
        HealthReportRow(
          description: 'BLOOD PRESSURE',
          value: (bpSys == null && bpDia == null)
              ? '—'
              : '${_num(bpSys)} / ${_num(bpDia)}',
          unit: 'mmHg',
          range: '120/80',
          status: bpStatus.$1,
          statusTone: bpStatus.$2,
        ),
        HealthReportRow(
          description: 'HEIGHT',
          value: _num(height),
          unit: 'cm',
          range: '-',
          status: '-',
        ),
        HealthReportRow(
          description: 'WEIGHT',
          value: _num(weight),
          unit: 'kg',
          range: '-',
          status: '-',
        ),
      ],
      bmi: bmi,
      bmiCategory: category,
    );
  }

  static String _sampleId(String id) {
    final clean = id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (clean.isEmpty) return '—';
    if (clean.length <= 6) return clean.toUpperCase();
    return clean.substring(clean.length - 6).toUpperCase();
  }

  static String _fmtDate(DateTime d) {
    final local = d.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  static String _num(double? v) {
    if (v == null) return '—';
    return v == v.roundToDouble() ? '${v.toInt()}' : v.toStringAsFixed(1);
  }

  static double? _testValue(CampPatient p, String type) {
    for (final t in p.tests.reversed) {
      if (t.type.trim().toLowerCase() == type) return t.value;
    }
    return null;
  }

  static double? _testValue2(CampPatient p, String type) {
    for (final t in p.tests.reversed) {
      if (t.type.trim().toLowerCase() == type) return t.value2;
    }
    return null;
  }

  static String? _testSugarType(CampPatient p) {
    for (final t in p.tests.reversed) {
      if (t.type.trim().toLowerCase() == 'sugar') return t.sugarType;
    }
    return null;
  }

  static String _sugarLabel(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'fasting':
      case 'f':
      case 'fbs':
        return 'Fasting';
      case 'pp':
      case 'ppbs':
      case 'p':
        return 'PP';
      default:
        return 'RANDOM';
    }
  }

  static (String, String?) _sugarStatus(double? sugar) {
    if (sugar == null) return ('-', null);
    if (sugar < 70) return ('Low', 'red');
    if (sugar > 140) return ('High', 'red');
    return ('Normal', 'green');
  }

  static (String, String?) _bpStatus(double? sys, double? dia) {
    if (sys == null || dia == null) return ('-', null);
    if (sys >= 130 || dia >= 80) return ('High', 'red');
    if (sys < 90 || dia < 60) return ('Low', 'red');
    return ('Normal', 'green');
  }

  static double? _calcBmi(double? weight, double? heightCm) {
    if (weight == null || heightCm == null || heightCm <= 0) return null;
    final m = heightCm / 100;
    return weight / (m * m);
  }

  static String _bmiCategory(double? bmi) {
    if (bmi == null) return '—';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
