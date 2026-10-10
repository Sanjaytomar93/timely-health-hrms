import 'dart:typed_data';

import 'package:timelay_health/features/letters/domain/entities/letter.dart';

abstract class LetterRepository {
  Future<List<Letter>> getEmployeeLetters(String employeeId);

  Future<Uint8List> downloadLetter(String fileUrl);
}
