import 'package:timelay_health/features/payslips/data/datasources/payslip_remote_datasource.dart';
import 'package:timelay_health/features/payslips/data/mappers/payslip_mapper.dart';
import 'package:timelay_health/features/payslips/domain/entities/payslip.dart';
import 'package:timelay_health/features/payslips/domain/entities/salary_summary.dart';
import 'package:timelay_health/features/payslips/domain/repositories/payslip_repository.dart';

class PayslipRepositoryImpl implements PayslipRepository {
  PayslipRepositoryImpl({PayslipRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? PayslipRemoteDataSource();

  final PayslipRemoteDataSource _remote;

  @override
  Future<Payslip> getSalaryForDate({
    required String employeeId,
    required DateTime date,
  }) async {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final model = await _remote.getSalaryForDate(
      employeeId: employeeId,
      date: '$y-$m-$d',
    );
    return PayslipMapper.toEntity(model);
  }

  @override
  Future<SalarySummary> getSalarySummary({
    required String employeeId,
    required DateTime month,
  }) async {
    final label = '${month.month.toString().padLeft(2, '0')}-${month.year}';
    final model = await _remote.getSalarySummary(
      employeeId: employeeId,
      month: label,
    );
    return model.summary;
  }
}
