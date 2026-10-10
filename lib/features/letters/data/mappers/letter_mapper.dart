import 'package:timelay_health/features/letters/data/endpoints/letter_endpoints.dart';
import 'package:timelay_health/features/letters/data/models/letter_model.dart';
import 'package:timelay_health/features/letters/domain/entities/letter.dart';

class LetterMapper {
  const LetterMapper._();

  static Letter toEntity(LetterModel model) {
    return Letter(
      id: model.id,
      employeeId: model.employeeId,
      employeeName: model.employeeName,
      letterType: model.letterType,
      designation: model.designation,
      department: model.department,
      joiningDate: model.joiningDate,
      relievingDate: model.relievingDate,
      status: model.status,
      fileUrl: LetterEndpoints.fileUrl(model.letterPdfUrl),
      sentAt: model.sentAt ?? model.createdAt,
    );
  }
}
