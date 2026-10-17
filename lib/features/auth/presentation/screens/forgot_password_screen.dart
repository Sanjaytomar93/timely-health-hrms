import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/presentation/bloc/forgot_password_cubit.dart';
import 'package:timelay_health/features/auth/presentation/bloc/forgot_password_state.dart';
import 'package:timelay_health/features/auth/presentation/widgets/forgot_password_feedback.dart';
import 'package:timelay_health/features/auth/presentation/widgets/forgot_password_form_pane.dart';
import 'package:timelay_health/features/auth/presentation/widgets/forgot_password_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final ForgotPasswordCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ForgotPasswordCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F3F9),
          body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
            listenWhen: (previous, current) {
              if (current is ForgotPasswordResetSuccess) return true;
              if (current is ForgotPasswordFormState) {
                return current.infoMessage != null ||
                    current.errorMessage != null;
              }
              return false;
            },
            listener: (context, state) {
              if (state is ForgotPasswordResetSuccess) {
                showForgotPasswordSuccessDialog(
                  context,
                  message: state.message,
                );
                return;
              }
              if (state is ForgotPasswordFormState) {
                if (state.errorMessage != null) {
                  showForgotPasswordSoftMessage(
                    context,
                    state.errorMessage!,
                    isError: true,
                  );
                  context.read<ForgotPasswordCubit>().clearMessages();
                } else if (state.infoMessage != null) {
                  showForgotPasswordSoftMessage(
                    context,
                    state.infoMessage!,
                    isError: false,
                  );
                  context.read<ForgotPasswordCubit>().clearMessages();
                }
              }
            },
            builder: (context, state) {
              final form = state is ForgotPasswordFormState
                  ? state
                  : const ForgotPasswordFormState(
                      step: ForgotPasswordStep.reset,
                    );
              return Column(
                children: [
                  ForgotPasswordHeader(step: form.step),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFF3F0FA), Color(0xFFEDEAF7)],
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        child: ForgotPasswordFormPane(form: form),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
