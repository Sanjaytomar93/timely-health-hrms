import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/camp/camps/data/repositories_impl/camp_repository_impl.dart';
import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/camps/domain/usecases/get_assigned_camps_usecase.dart';
import 'package:timelay_health/features/camp/camps/presentation/models/camp_list_ui.dart';
import 'package:timelay_health/features/camp/shared/camp_memory_cache.dart';

class CampDistributionExport {
  const CampDistributionExport._();

  static String todayDateString([DateTime? date]) {
    final now = date ?? DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  static String _fileName(String prefix) =>
      '${prefix}_${todayDateString()}.pdf';

  static String _dash(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? '—' : text;
  }

  static Future<String> _employeeName() async {
    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    final name = employee?.displayName.trim() ?? '';
    if (name.isEmpty) {
      throw Exception('Employee name missing. Please login again.');
    }
    return name;
  }

  static Future<({pw.Font regular, pw.Font bold})> _fonts() async {
    try {
      final r = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
      );
      final b = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
      );
      return (regular: r, bold: b);
    } catch (_) {
      return (regular: pw.Font.helvetica(), bold: pw.Font.helveticaBold());
    }
  }

  static pw.Widget _cell(
    String text, {
    bool header = false,
    bool bold = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Container(
      alignment: align == pw.TextAlign.right
          ? pw.Alignment.centerRight
          : pw.Alignment.centerLeft,
      padding: pw.EdgeInsets.symmetric(
        horizontal: 6,
        vertical: header ? 6 : 5,
      ),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: header ? 8.5 : 8,
          fontWeight: (header || bold)
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
          color: PdfColors.black,
        ),
      ),
    );
  }

  static Future<void> _sharePdf(pw.Document doc, String fileName) async {
    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf', name: fileName)],
        subject: fileName.replaceAll('.pdf', ''),
      ),
    );
  }

  static Future<void> _buildAndShare({
    required String fileName,
    required Map<int, pw.TableColumnWidth> columnWidths,
    required List<pw.Widget> headers,
    required List<List<pw.Widget>> rows,
    List<pw.Widget> Function(pw.Context context)? extraBuild,
  }) async {
    final fonts = await _fonts();
    final title = fileName.replaceAll('.pdf', '');
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
        header: (_) => pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ),
        build: (context) {
          if (extraBuild != null) return extraBuild(context);
          return [
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
              columnWidths: columnWidths,
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey400),
                  repeat: true,
                  children: headers,
                ),
                for (final row in rows) pw.TableRow(children: row),
              ],
            ),
          ];
        },
      ),
    );

    await _sharePdf(doc, fileName);
  }

  static Future<List<Camp>> _fetchRawCamps() async {
    final name = await _employeeName();
    return GetAssignedCampsUseCase(CampRepositoryImpl())(name);
  }

  static Future<List<CampItemUi>> fetchCamps({
    DateTime? from,
    DateTime? to,
  }) async {
    final employeeName = await _employeeName();

    List<CampItemUi> list;
    final cached = CampMemoryCache.camps(employeeName);
    if (cached != null && cached.camps.isNotEmpty) {
      list = cached.camps;
    } else {
      final camps =
          await GetAssignedCampsUseCase(CampRepositoryImpl())(employeeName);
      list = CampListUiMapper.toUiList(camps);
      CampMemoryCache.setCamps(
        employeeName,
        camps: list,
        stats: CampListUiMapper.toStats(list),
      );
    }

    if (from == null && to == null) return list;

    return list.where((camp) {
      final d = DateTime.tryParse(camp.date);
      if (d == null) return true;
      if (from != null &&
          d.isBefore(DateTime(from.year, from.month, from.day))) {
        return false;
      }
      if (to != null &&
          d.isAfter(DateTime(to.year, to.month, to.day, 23, 59, 59))) {
        return false;
      }
      return true;
    }).toList();
  }

  static String _bpCategory(double? sys, double? dia) {
    if (sys == null) return 'N/A';
    if (sys >= 130 || (dia != null && dia >= 80)) return 'High';
    if (sys >= 120) return 'Elevated';
    return 'Normal';
  }

  static String _sugarCategory(double? value, String? type) {
    if (value == null) return 'N/A';
    final t = (type ?? '').toLowerCase();
    if (t == 'fasting') {
      if (value >= 126) return 'High';
      if (value >= 100) return 'Borderline';
      return 'Normal';
    }
    if (value >= 200) return 'High';
    if (value >= 140) return 'Borderline';
    return 'Normal';
  }

  /// Camp Distribution PDF.
  static Future<void> exportPdf({
    DateTime? from,
    DateTime? to,
    List<CampItemUi>? preloadedCamps,
  }) async {
    final camps = preloadedCamps ?? await fetchCamps(from: from, to: to);
    if (camps.isEmpty) return;

    await _buildAndShare(
      fileName: _fileName('detailed_camp_distribution'),
      columnWidths: const {
        0: pw.FlexColumnWidth(2.2),
        1: pw.FlexColumnWidth(1.2),
        2: pw.FlexColumnWidth(2.8),
        3: pw.FlexColumnWidth(1.3),
        4: pw.FlexColumnWidth(1.8),
        5: pw.FlexColumnWidth(3.0),
        6: pw.FlexColumnWidth(1.5),
      },
      headers: [
        _cell('Camp Name', header: true),
        _cell('Status', header: true),
        _cell('Location', header: true),
        _cell('Date', header: true),
        _cell('Time', header: true),
        _cell('Volunteers', header: true),
        _cell('Patients Registered', header: true, align: pw.TextAlign.right),
      ],
      rows: [
        for (final c in camps)
          [
            _cell(c.name, bold: true),
            _cell(c.statusLabel),
            _cell(c.location),
            _cell(c.date),
            _cell(c.time),
            _cell(
              c.volunteers.isEmpty
                  ? '—'
                  : c.volunteers.map((v) => v.name).join('; '),
            ),
            _cell('${c.patients}', align: pw.TextAlign.right),
          ],
      ],
    );
  }

  /// Patient-level participation PDF.
  static Future<void> exportParticipationPdf() async {
    final camps = await fetchCamps();
    if (camps.isEmpty) return;

    final rows = <List<pw.Widget>>[];
    for (final camp in camps) {
      for (final patient in camp.patientItems) {
        rows.add([
          _cell(_dash(patient.name), bold: true),
          _cell(patient.age > 0 ? '${patient.age}' : '—',
              align: pw.TextAlign.right),
          _cell(_dash(patient.contact)),
          _cell(_dash(camp.name)),
          _cell(_dash(camp.location)),
        ]);
      }
    }
    if (rows.isEmpty) return;

    await _buildAndShare(
      fileName: _fileName('detailed_camp_participation'),
      columnWidths: const {
        0: pw.FlexColumnWidth(2.5),
        1: pw.FlexColumnWidth(0.8),
        2: pw.FlexColumnWidth(1.8),
        3: pw.FlexColumnWidth(2.5),
        4: pw.FlexColumnWidth(2.5),
      },
      headers: [
        _cell('Patient Name', header: true),
        _cell('Age', header: true, align: pw.TextAlign.right),
        _cell('Contact', header: true),
        _cell('Camp Name', header: true),
        _cell('Location', header: true),
      ],
      rows: rows,
    );
  }

  /// Patient-level BMI PDF.
  static Future<void> exportBmiPdf() async {
    final camps = await _fetchRawCamps();
    if (camps.isEmpty) return;

    final rows = <List<pw.Widget>>[];
    for (final camp in camps) {
      final campDate =
          camp.date.length >= 10 ? camp.date.substring(0, 10) : camp.date;
      for (final patient in camp.patients) {
        final vitals = patient.vitals;
        final bmiResult = vitals?.bmi != null
            ? '${vitals!.bmi!.toStringAsFixed(1)} (${vitals.bmiCategory ?? 'N/A'})'
            : 'N/A (N/A)';
        rows.add([
          _cell(campDate),
          _cell(_dash(camp.name), bold: true),
          _cell(_dash(patient.displayName)),
          _cell(_dash(patient.contact)),
          _cell(bmiResult),
        ]);
      }
    }
    if (rows.isEmpty) return;

    await _buildAndShare(
      fileName: _fileName('detailed_bmi_distribution'),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.3),
        1: pw.FlexColumnWidth(2.2),
        2: pw.FlexColumnWidth(2.5),
        3: pw.FlexColumnWidth(1.8),
        4: pw.FlexColumnWidth(2.2),
      },
      headers: [
        _cell('Date', header: true),
        _cell('Camp Name', header: true),
        _cell('Patient Name', header: true),
        _cell('Mobile', header: true),
        _cell('BMI Result', header: true),
      ],
      rows: rows,
    );
  }

  /// Patient-level BP / Sugar PDF.
  static Future<void> exportBpSugarPdf() async {
    final camps = await _fetchRawCamps();

    final bpRows = <List<pw.Widget>>[];
    final sugarRows = <List<pw.Widget>>[];

    for (final camp in camps) {
      for (final patient in camp.patients) {
        final vitals = patient.vitals;
        final dateStr = vitals?.updatedAt != null
            ? todayDateString(vitals!.updatedAt)
            : (camp.date.length >= 10
                ? camp.date.substring(0, 10)
                : camp.date);
        final campName = _dash(camp.name);
        final patientName = _dash(patient.displayName);
        final mobile = _dash(patient.contact);

        if (vitals?.bpSys != null) {
          final sys = vitals!.bpSys!;
          final dia = vitals.bpDia;
          final diaStr = dia != null ? '${dia.toInt()}' : '?';
          final result =
              '${sys.toInt()}/$diaStr mmHg (${_bpCategory(sys, dia)})';
          bpRows.add([
            _cell(dateStr),
            _cell(campName, bold: true),
            _cell(patientName),
            _cell(mobile),
            _cell('BP'),
            _cell(result),
          ]);
        }

        if (vitals?.sugar != null) {
          final sugar = vitals!.sugar!;
          final sugarType = vitals.sugarType ?? 'Random';
          final result =
              '${sugar.toInt()} mg/dL ($sugarType) - ${_sugarCategory(sugar, sugarType)}';
          sugarRows.add([
            _cell(dateStr),
            _cell(campName, bold: true),
            _cell(patientName),
            _cell(mobile),
            _cell('SUGAR'),
            _cell(result),
          ]);
        }
      }
    }

    if (bpRows.isEmpty && sugarRows.isEmpty) return;

    const widths = {
      0: pw.FlexColumnWidth(1.3),
      1: pw.FlexColumnWidth(2.2),
      2: pw.FlexColumnWidth(2.5),
      3: pw.FlexColumnWidth(1.8),
      4: pw.FlexColumnWidth(0.9),
      5: pw.FlexColumnWidth(2.8),
    };
    final headers = [
      _cell('Date', header: true),
      _cell('Camp Name', header: true),
      _cell('Patient Name', header: true),
      _cell('Mobile', header: true),
      _cell('Metric', header: true),
      _cell('Result', header: true),
    ];

    pw.Widget section(String title, List<List<pw.Widget>> rows) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            color: PdfColors.grey300,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
            columnWidths: widths,
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey400),
                repeat: true,
                children: headers,
              ),
              for (final row in rows) pw.TableRow(children: row),
            ],
          ),
        ],
      );
    }

    await _buildAndShare(
      fileName: _fileName('bp_sugar_analysis'),
      columnWidths: widths,
      headers: headers,
      rows: const [],
      extraBuild: (_) => [
        if (bpRows.isNotEmpty) ...[
          section('Blood Pressure Analysis', bpRows),
          pw.SizedBox(height: 20),
        ],
        if (sugarRows.isNotEmpty) section('Sugar Analysis', sugarRows),
      ],
    );
  }

  /// Single-camp patient table report (Download Report on camp detail).
  static Future<void> exportCampReport(CampItemUi camp) async {
    final safeName = camp.name
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final date = camp.date.length >= 10 ? camp.date.substring(0, 10) : camp.date;
    final fileName =
        'Camp_Report_${safeName.isEmpty ? 'Camp' : safeName}_$date.pdf';

    final campDate = date;
    final campName = _dash(camp.name);
    final location = _dash(camp.location);

    await _buildAndShare(
      fileName: fileName,
      columnWidths: const {
        0: pw.FlexColumnWidth(2.0),
        1: pw.FlexColumnWidth(0.7),
        2: pw.FlexColumnWidth(1.0),
        3: pw.FlexColumnWidth(1.6),
        4: pw.FlexColumnWidth(2.0),
        5: pw.FlexColumnWidth(1.3),
        6: pw.FlexColumnWidth(1.6),
        7: pw.FlexColumnWidth(0.9),
        8: pw.FlexColumnWidth(1.2),
        9: pw.FlexColumnWidth(1.4),
      },
      headers: [
        _cell('Patient Name', header: true),
        _cell('Age', header: true, align: pw.TextAlign.right),
        _cell('Gender', header: true),
        _cell('Contact', header: true),
        _cell('Camp Name', header: true),
        _cell('Date', header: true),
        _cell('Location', header: true),
        _cell('BMI', header: true, align: pw.TextAlign.right),
        _cell('BP (Sys/Dia)', header: true),
        _cell('Sugar', header: true),
      ],
      rows: [
        for (final p in camp.patientItems)
          [
            _cell(_dash(p.name), bold: true),
            _cell(p.age > 0 ? '${p.age}' : '-', align: pw.TextAlign.right),
            _cell(p.genderLabel.toLowerCase()),
            _cell(_dash(p.contact == '—' ? '' : p.contact)),
            _cell(campName),
            _cell(campDate),
            _cell(location),
            _cell(p.bmiLabel, align: pw.TextAlign.right),
            _cell(p.bpLabel),
            _cell(p.sugarLabel),
          ],
      ],
    );
  }
}
