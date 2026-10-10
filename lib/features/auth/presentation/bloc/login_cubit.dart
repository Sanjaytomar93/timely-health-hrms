import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/location/location_helper.dart';
import 'package:timelay_health/core/notifications/push_notification_service.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:timelay_health/features/auth/domain/failures/auth_failure.dart';
import 'package:timelay_health/features/auth/domain/usecases/login_usecase.dart';
import 'package:timelay_health/features/auth/presentation/bloc/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({LoginUseCase? loginUseCase})
    : _loginUseCase = loginUseCase ?? LoginUseCase(AuthRepositoryImpl()),
      super(const LoginInitial());

  final LoginUseCase _loginUseCase;

  Future<void> login({required String email, required String password}) async {
    emit(const LoginLoading());
    try {
      final tokenFuture = PushNotificationService.currentToken();
      final position = await LocationHelper.getFastPosition();
      final fcmToken = await tokenFuture;
      if (isClosed) return;
      final employee = await _loginUseCase(
        LoginParams(
          email: email,
          password: password,
          latitude: position.latitude,
          longitude: position.longitude,
          fcmToken: fcmToken,
        ),
      );
      if (isClosed) return;
      await Future.wait([
        AuthSession.save(employee),
        AuthSession.saveFcmToken(fcmToken),
      ]);
      if (isClosed) return;
      emit(LoginSuccess(employee));
    } on LocationFailure catch (e) {
      if (isClosed) return;
      emit(LoginFailure(e.message));
    } on AuthFailure catch (e) {
      if (isClosed) return;
      emit(LoginFailure(e.message));
    } catch (e) {
      if (isClosed) return;
      emit(
        LoginFailure(
          e.toString().contains('SocketException') ||
                  e.toString().contains('Failed host lookup')
              ? 'Unable to reach server. Check your internet connection.'
              : 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
