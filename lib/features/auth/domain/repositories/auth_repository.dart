import 'package:timelay_health/features/auth/domain/entities/employee.dart';

abstract class AuthRepository {
  Future<Employee> login({
    required String email,
    required String password,
    required double latitude,
    required double longitude,
    required String fcmToken,
  });

  Future<Employee> getEmployee({required String employeeId});
}
