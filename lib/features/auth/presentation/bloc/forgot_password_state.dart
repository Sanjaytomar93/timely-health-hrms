import 'package:equatable/equatable.dart';

enum ForgotPasswordStep { email, otp, reset }

sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordFormState extends ForgotPasswordState {
  const ForgotPasswordFormState({
    this.step = ForgotPasswordStep.email,
    this.email = '',
    this.isLoading = false,
    this.infoMessage,
    this.errorMessage,
  });

  final ForgotPasswordStep step;
  final String email;
  final bool isLoading;
  final String? infoMessage;
  final String? errorMessage;

  ForgotPasswordFormState copyWith({
    ForgotPasswordStep? step,
    String? email,
    bool? isLoading,
    String? infoMessage,
    String? errorMessage,
    bool clearInfo = false,
    bool clearError = false,
  }) {
    return ForgotPasswordFormState(
      step: step ?? this.step,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [step, email, isLoading, infoMessage, errorMessage];
}

class ForgotPasswordResetSuccess extends ForgotPasswordState {
  const ForgotPasswordResetSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
