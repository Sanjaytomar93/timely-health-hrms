import 'package:timelay_health/features/attendance/domain/entities/ot_claim_params.dart';
import 'package:timelay_health/features/attendance/domain/repositories/attendance_repository.dart';

class ClaimOtUseCase {
  const ClaimOtUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<String> call(OtClaimParams params) {
    return _repository.claimOt(params);
  }
}
