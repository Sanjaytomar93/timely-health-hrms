import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timelay_health/features/camp/dashboard/presentation/utils/camp_pdf_delivery.dart';
import 'package:timelay_health/features/payslips/presentation/models/payslip_ui_model.dart';

Future<void> downloadOfficialPayslip(
  BuildContext context,
  PayslipUiModel payslip,
) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final url = payslip.invoiceUrl.trim();
  if (!payslip.canDownload || url.isEmpty) {
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Payslip is not available for download yet.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  final action = await showCampPdfActionSheet(context);
  if (action == null || !context.mounted) return;

  messenger?.showSnackBar(
    SnackBar(
      content: Text(
        action == CampPdfAction.download
            ? 'Downloading payslip PDF...'
            : 'Preparing payslip to share...',
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  try {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 60));
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        response.bodyBytes.isEmpty) {
      throw Exception('empty');
    }

    final safeMonth = payslip.monthLabel.replaceAll(' ', '_');
    final fileName = 'Payslip_$safeMonth.pdf';
    final savedPath = await CampPdfDelivery.deliver(
      bytes: response.bodyBytes,
      fileName: fileName,
      action: action,
      subject: 'Payslip ${payslip.monthLabel}',
    );

    if (!context.mounted) return;
    messenger?.hideCurrentSnackBar();
    if (action == CampPdfAction.download) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            savedPath == null
                ? 'Could not save the payslip.'
                : 'Downloaded: ${savedPath.split('/').last}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (_) {
    if (!context.mounted) return;
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Could not download the payslip. Try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
