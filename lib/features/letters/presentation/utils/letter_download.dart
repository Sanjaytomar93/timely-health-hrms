import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timelay_health/features/letters/data/repositories_impl/letter_repository_impl.dart';
import 'package:timelay_health/features/letters/domain/failures/letter_failure.dart';
import 'package:timelay_health/features/letters/domain/usecases/download_letter_usecase.dart';
import 'package:timelay_health/features/letters/presentation/models/employee_letter.dart';

Future<void> downloadEmployeeLetter(
  BuildContext context,
  EmployeeLetter letter,
) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (!letter.hasFile) {
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Letter file is not available yet.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  messenger?.showSnackBar(
    SnackBar(
      content: Text('Downloading ${letter.type.label.toLowerCase()} letter...'),
      behavior: SnackBarBehavior.floating,
    ),
  );
  try {
    final bytes = await DownloadLetterUseCase(LetterRepositoryImpl())(
      letter.fileUrl!,
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${letter.fileName}');
    await file.writeAsBytes(bytes, flush: true);
    messenger?.hideCurrentSnackBar();
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(file.path, mimeType: 'application/pdf', name: letter.fileName),
        ],
        subject: '${letter.type.label} Letter',
      ),
    );
  } on LetterFailure catch (e) {
    messenger?.showSnackBar(
      SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating),
    );
  } catch (_) {
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Could not save the letter. Try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
