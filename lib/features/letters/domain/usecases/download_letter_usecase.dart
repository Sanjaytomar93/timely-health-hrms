import 'dart:typed_data';

import 'package:timelay_health/features/letters/domain/repositories/letter_repository.dart';

class DownloadLetterUseCase {
  const DownloadLetterUseCase(this._repository);
  final LetterRepository _repository;

  Future<Uint8List> call(String fileUrl) => _repository.downloadLetter(fileUrl);
}
