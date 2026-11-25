import 'package:timelay_health/features/payslips/data/datasources/payslip_remote_datasource.dart';
import 'package:timelay_health/features/payslips/domain/entities/salary_summary.dart';
import 'package:timelay_health/features/payslips/domain/repositories/payslip_repository.dart';

class PayslipRepositoryImpl implements PayslipRepository {
  PayslipRepositoryImpl({PayslipRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? PayslipRemoteDataSource();

  final PayslipRemoteDataSource _remote;

  @override
  Future<SalarySummary> getSalarySummary({
    required String employeeId,
    required DateTime month,
  }) async {
    final label =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';
    final model = await _remote.getSalarySummary(
      employeeId: employeeId,
      month: label,
    );
    return model.summary;
  }
}
