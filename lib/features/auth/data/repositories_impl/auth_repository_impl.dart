import 'package:timelay_health/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:timelay_health/features/auth/data/mappers/employee_mapper.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? AuthRemoteDataSource();

  final AuthRemoteDataSource _remote;

  @override
  Future<Employee> login({
    required String email,
    required String password,
    required double latitude,
    required double longitude,
    required String fcmToken,
  }) async {
    final model = await _remote.login(
      email: email,
      password: password,
      latitude: latitude,
      longitude: longitude,
      fcmToken: fcmToken,
    );
    return EmployeeMapper.toEntity(model);
  }

  @override
  Future<Employee> getEmployee({required String employeeId}) async {
    final model = await _remote.getEmployee(employeeId: employeeId);
    return EmployeeMapper.toEntity(model);
  }
}
