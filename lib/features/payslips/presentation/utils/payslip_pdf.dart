import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:timelay_health/features/payslips/presentation/models/payslip_ui_model.dart';

Future<void> downloadOfficialPayslip(
  BuildContext context,
  PayslipUiModel payslip,
) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.showSnackBar(
    const SnackBar(content: Text('Preparing payslip PDF...')),
  );
  try {
    await PayslipPdf.download(payslip);
  } catch (_) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('Could not save the payslip. Try again.')),
    );
  }
}

class PayslipPdf {
  const PayslipPdf._();

  static const _logo = 'assets/images/timely_health_logo.png';
  static const _seal = 'assets/images/payslip_seal.png';
  static const _regularFont = 'assets/fonts/NotoSans-Regular.ttf';
  static const _boldFont = 'assets/fonts/NotoSans-Bold.ttf';

  static Future<void> download(PayslipUiModel payslip) async {
    final logo = pw.MemoryImage(
      (await rootBundle.load(_logo)).buffer.asUint8List(),
    );
    final seal = pw.MemoryImage(
      (await rootBundle.load(_seal)).buffer.asUint8List(),
    );
    final regular = pw.Font.ttf(await rootBundle.load(_regularFont));
    final bold = pw.Font.ttf(await rootBundle.load(_boldFont));
    final doc = pw.Document();
    final month = payslip.monthLabel.toUpperCase();
    final effective = payslip.daysMeta.split(' ').first;
    final effectiveLabel = effective.startsWith(':')
        ? effective
        : ':$effective';
    pw.Widget cell(
      String text, {
      bool bold = false,
      pw.TextAlign align = pw.TextAlign.left,
      PdfColor? background,
    }) {
      return pw.Container(
        alignment: align == pw.TextAlign.right
            ? pw.Alignment.centerRight
            : pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        color: background,
        child: pw.Text(
          text,
          textAlign: align,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );
    }

    const slipPage = PdfPageFormat(595, 640, marginAll: 16);
    doc.addPage(
      pw.Page(
        pageFormat: slipPage,
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (context) {
          return pw.Align(
            alignment: pw.Alignment.topCenter,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
              ),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(8, 8, 8, 6),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Image(logo, width: 92, height: 26),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          child: pw.Column(
                            children: [
                              pw.Text(
                                'Timely Healthtech Private Limited',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                'Reg. Address: Plot No.301, H.No.1-98/2/2, Plot No. 84 & 85, Sri Sai Balaji Avenue, Arunodaya Colony, Madhapur, Hyderabad, Telangana 500081',
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(fontSize: 6.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Container(
                    color: PdfColors.grey200,
                    padding: const pw.EdgeInsets.symmetric(vertical: 5),
                    child: pw.Text(
                      'PAYSLIP FOR $month',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Table(
                    border: pw.TableBorder.all(
                      color: PdfColors.black,
                      width: 0.5,
                    ),
                    columnWidths: const {
                      0: pw.FlexColumnWidth(1.3),
                      1: pw.FlexColumnWidth(1.5),
                      2: pw.FlexColumnWidth(1.3),
                      3: pw.FlexColumnWidth(1.2),
                    },
                    children: [
                      _info(
                        'Name:',
                        payslip.name,
                        'Employee No:',
                        payslip.employeeCode,
                      ),
                      _info(
                        'Joining Date:',
                        payslip.joiningDate,
                        'Bank Name:',
                        payslip.bankName,
                      ),
                      _info(
                        'Designation:',
                        payslip.designation,
                        'Bank Account No:',
                        payslip.bankAccount,
                      ),
                      _info(
                        'Department:',
                        payslip.department,
                        'PAN Number:',
                        payslip.panNo,
                      ),
                      _info(
                        'Location:',
                        payslip.location,
                        'EMP EFFECTIVE',
                        effectiveLabel,
                      ),
                      _info('LOP:', payslip.lopLabel, '', ''),
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey200,
                        ),
                        children: [
                          cell('Earnings', bold: true),
                          cell('Amount', bold: true, align: pw.TextAlign.right),
                          cell('Deductions', bold: true),
                          cell('Amount', bold: true, align: pw.TextAlign.right),
                        ],
                      ),
                      _info(
                        'Base Salary (Calculated)',
                        payslip.baseSalaryLabel,
                        'LOP / Absent (${payslip.lopLabel} days)',
                        payslip.lopAmountLabel,
                        amounts: true,
                      ),
                      _info(
                        'Holiday Pay (${payslip.holidayCountLabel} days)',
                        payslip.holidayPayLabel,
                        'Half Day Deductions (${payslip.halfDaysLabel} HD)',
                        '₹0.00',
                        amounts: true,
                      ),
                      _info(
                        'Working Days (Full: ${payslip.fullDaysLabel})',
                        '-',
                        'Other Deductions',
                        payslip.otherDeductionsLabel,
                        amounts: true,
                      ),
                      _info(
                        'Half Days (${payslip.halfDaysLabel})',
                        '-',
                        '',
                        '',
                        amounts: true,
                      ),
                      _info(
                        'Week Off Days (${payslip.weekOffLabel})',
                        '-',
                        '',
                        '',
                        amounts: true,
                      ),
                      _info(
                        'Public Holidays (${payslip.holidayCountLabel})',
                        '-',
                        '',
                        '',
                        amounts: true,
                      ),
                      _info(
                        'Total Earnings',
                        payslip.totalEarningsLabel,
                        'Total Deductions',
                        payslip.totalDeductionsLabel,
                        amounts: true,
                        bold: true,
                        shaded: true,
                      ),
                      _info(
                        '',
                        '',
                        'Net Pay for the month',
                        payslip.netPayLabel,
                        amounts: true,
                        bold: true,
                      ),
                    ],
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 6),
                    child: pw.Text(
                      payslip.netPayWords,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Container(
                    height: 120,
                    padding: const pw.EdgeInsets.fromLTRB(8, 8, 22, 10),
                    alignment: pw.Alignment.bottomRight,
                    child: pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.ClipOval(
                          child: pw.Image(
                            seal,
                            width: 72,
                            height: 72,
                            fit: pw.BoxFit.cover,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Authorized Signatory',
                          style: pw.TextStyle(
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Timely Healthtech Private Limited',
                          style: const pw.TextStyle(fontSize: 6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final safeMonth = payslip.monthLabel.replaceAll(' ', '_');
    final file = File('${dir.path}/Payslip_$safeMonth.pdf');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(
            file.path,
            mimeType: 'application/pdf',
            name: 'Payslip_$safeMonth.pdf',
          ),
        ],
        subject: 'Payslip ${payslip.monthLabel}',
      ),
    );
  }

  static pw.TableRow _info(
    String a,
    String b,
    String c,
    String d, {
    bool amounts = false,
    bool bold = false,
    bool shaded = false,
  }) {
    pw.Widget box(String text, {bool right = false}) {
      return pw.Container(
        color: shaded ? PdfColors.grey200 : null,
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: pw.Text(
          text,
          textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );
    }

    return pw.TableRow(
      children: [
        box(a),
        box(b, right: amounts),
        box(c),
        box(d, right: amounts),
      ],
    );
  }
}
