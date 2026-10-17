import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:timelay_health/features/auth/domain/failures/auth_failure.dart';
import 'package:timelay_health/features/auth/presentation/bloc/forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({AuthRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? AuthRemoteDataSource(),
      super(const ForgotPasswordFormState());

  final AuthRemoteDataSource _remote;

  ForgotPasswordFormState get _form =>
      state is ForgotPasswordFormState
          ? state as ForgotPasswordFormState
          : const ForgotPasswordFormState();

  Future<void> sendOtp({required String email}) async {
    final trimmed = email.trim();
    emit(
      _form.copyWith(
        isLoading: true,
        email: trimmed,
        clearError: true,
        clearInfo: true,
      ),
    );
    try {
      await _remote.sendForgotPasswordOtp(email: trimmed);
      if (isClosed) return;
      emit(
        ForgotPasswordFormState(
          step: ForgotPasswordStep.otp,
          email: trimmed,
          infoMessage: 'We sent a verification code to your email.',
        ),
      );
    } on AuthFailure catch (e) {
      if (isClosed) return;
      emit(
        _form.copyWith(
          isLoading: false,
          email: trimmed,
          errorMessage: e.message,
          clearInfo: true,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        _form.copyWith(
          isLoading: false,
          email: trimmed,
          errorMessage: 'Something went wrong. Please try again.',
          clearInfo: true,
        ),
      );
    }
  }

  Future<void> verifyOtp({required String otp}) async {
    final current = _form;
    emit(current.copyWith(isLoading: true, clearError: true, clearInfo: true));
    try {
      await _remote.verifyForgotPasswordOtp(email: current.email, otp: otp);
      if (isClosed) return;
      emit(
        ForgotPasswordFormState(
          step: ForgotPasswordStep.reset,
          email: current.email,
          infoMessage: 'OTP verified. Create your new password.',
        ),
      );
    } on AuthFailure catch (e) {
      if (isClosed) return;
      emit(
        current.copyWith(
          isLoading: false,
          errorMessage: e.message,
          clearInfo: true,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        current.copyWith(
          isLoading: false,
          errorMessage: 'Something went wrong. Please try again.',
          clearInfo: true,
        ),
      );
    }
  }

  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final current = _form;
    emit(current.copyWith(isLoading: true, clearError: true, clearInfo: true));
    try {
      await _remote.resetForgotPassword(
        email: current.email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      if (isClosed) return;
      emit(
        const ForgotPasswordResetSuccess(
          'Your password has been updated. Please sign in with your new password.',
        ),
      );
    } on AuthFailure catch (e) {
      if (isClosed) return;
      emit(
        current.copyWith(
          isLoading: false,
          errorMessage: e.message,
          clearInfo: true,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        current.copyWith(
          isLoading: false,
          errorMessage: 'Something went wrong. Please try again.',
          clearInfo: true,
        ),
      );
    }
  }

  Future<void> resendOtp() async {
    final email = _form.email;
    if (email.isEmpty) return;
    await sendOtp(email: email);
  }

  void goBack() {
    final current = _form;
    if (current.step == ForgotPasswordStep.otp) {
      emit(
        ForgotPasswordFormState(
          step: ForgotPasswordStep.email,
          email: current.email,
        ),
      );
      return;
    }
    if (current.step == ForgotPasswordStep.reset) {
      emit(
        ForgotPasswordFormState(
          step: ForgotPasswordStep.otp,
          email: current.email,
        ),
      );
    }
  }

  void clearMessages() {
    final current = state;
    if (current is ForgotPasswordFormState) {
      emit(current.copyWith(clearError: true, clearInfo: true));
    }
  }
}
