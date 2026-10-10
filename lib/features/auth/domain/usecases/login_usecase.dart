import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/features/auth/domain/repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({
    required this.email,
    required this.password,
    required this.latitude,
    required this.longitude,
    required this.fcmToken,
  });

  final String email;
  final String password;
  final double latitude;
  final double longitude;
  final String fcmToken;
}

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Employee> call(LoginParams params) {
    return _repository.login(
      email: params.email,
      password: params.password,
      latitude: params.latitude,
      longitude: params.longitude,
      fcmToken: params.fcmToken,
    );
  }
}
