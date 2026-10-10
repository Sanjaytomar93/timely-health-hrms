import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/features/letters/presentation/models/employee_letter.dart';
import 'package:timelay_health/features/letters/presentation/utils/letter_download.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';

class LetterViewerScreen extends StatelessWidget {
  const LetterViewerScreen({super.key, required this.letter});

  final EmployeeLetter letter;

  static Future<void> open(BuildContext context, EmployeeLetter letter) {
    if (!letter.hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Letter file is not available yet.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return Future.value();
    }
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LetterViewerScreen(letter: letter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortalColors.background,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: PortalColors.surface,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Row(
                children: [
                  const PortalBackButton(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${letter.type.label} Letter',
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                        letterSpacing: 0.2,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Material(
                    color: PortalColors.purpleTint,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => downloadEmployeeLetter(context, letter),
                      borderRadius: BorderRadius.circular(10),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          Icons.download_rounded,
                          size: 18,
                          color: PortalColors.purple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PdfViewer.uri(
                Uri.parse(letter.fileUrl!),
                params: PdfViewerParams(
                  backgroundColor: PortalColors.background,
                  loadingBannerBuilder: (context, downloaded, total) => Center(
                    child: CircularProgressIndicator(
                      color: PortalColors.purple,
                      value: total == null || total == 0
                          ? null
                          : downloaded / total,
                    ),
                  ),
                  errorBannerBuilder: (context, error, stackTrace, ref) =>
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Could not open the letter. Please try again.',
                            textAlign: TextAlign.center,
                            style: portalText(
                              fontSize: 12,
                              color: PortalColors.muted,
                            ),
                          ),
                        ),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
