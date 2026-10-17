import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/presentation/bloc/forgot_password_cubit.dart';
import 'package:timelay_health/features/auth/presentation/bloc/forgot_password_state.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key, required this.step});

  final ForgotPasswordStep step;

  String get _title {
    switch (step) {
      case ForgotPasswordStep.email:
        return 'Forgot password';
      case ForgotPasswordStep.otp:
        return 'Verify OTP';
      case ForgotPasswordStep.reset:
        return 'New password';
    }
  }

  String get _subtitle {
    switch (step) {
      case ForgotPasswordStep.email:
        return 'Enter your work email to receive a code';
      case ForgotPasswordStep.otp:
        return 'Enter the 4-digit code sent to your email';
      case ForgotPasswordStep.reset:
        return 'Choose a new password for your account';
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20, top + 12, 20, 28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1C1838),
              Color(0xFF2B2452),
              Color(0xFF3C3270),
              Color(0xFF4B4285),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    final cubit = context.read<ForgotPasswordCubit>();
                    final state = cubit.state;
                    if (state is ForgotPasswordFormState &&
                        state.step != ForgotPasswordStep.email) {
                      cubit.goBack();
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                ),
                const Spacer(),
                _StepDots(step: step),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _title,
              style: portalText(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _subtitle,
              style: portalText(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.step});

  final ForgotPasswordStep step;

  @override
  Widget build(BuildContext context) {
    final active = ForgotPasswordStep.values.indexOf(step);
    return Row(
      children: List.generate(3, (i) {
        final on = i <= active;
        return Container(
          width: on ? 18 : 8,
          height: 8,
          margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
          decoration: BoxDecoration(
            color: on
                ? const Color(0xFF5EEAD4)
                : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
