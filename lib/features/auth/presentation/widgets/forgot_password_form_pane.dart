import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/utils/validators.dart';
import 'package:timelay_health/features/auth/presentation/bloc/forgot_password_cubit.dart';
import 'package:timelay_health/features/auth/presentation/bloc/forgot_password_state.dart';
import 'package:timelay_health/features/auth/presentation/widgets/auth_field_label.dart';
import 'package:timelay_health/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:timelay_health/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordFormPane extends StatefulWidget {
  const ForgotPasswordFormPane({super.key, required this.form});

  final ForgotPasswordFormState form;

  @override
  State<ForgotPasswordFormPane> createState() => _ForgotPasswordFormPaneState();
}

class _ForgotPasswordFormPaneState extends State<ForgotPasswordFormPane> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _emailFocus = FocusNode();
  final _otpFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.form.email;
    for (final n in [_emailFocus, _otpFocus, _passwordFocus, _confirmFocus]) {
      n.addListener(() => setState(() {}));
    }
    for (final c in [
      _emailController,
      _otpController,
      _passwordController,
      _confirmController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void didUpdateWidget(covariant ForgotPasswordFormPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.form.email.isNotEmpty &&
        _emailController.text != widget.form.email) {
      _emailController.text = widget.form.email;
    }
    if (oldWidget.form.step != widget.form.step) {
      _submitted = false;
      if (widget.form.step == ForgotPasswordStep.otp) {
        _otpController.clear();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _otpFocus.requestFocus();
        });
      } else if (widget.form.step == ForgotPasswordStep.reset) {
        _passwordController.clear();
        _confirmController.clear();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _passwordFocus.requestFocus();
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocus.dispose();
    _otpFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Widget _eye(bool obscure, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: PortalColors.muted,
        size: 20,
      ),
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    final cubit = context.read<ForgotPasswordCubit>();
    final step = widget.form.step;

    if (step == ForgotPasswordStep.email) {
      if (Validators.email(_emailController.text) != null) return;
      cubit.sendOtp(email: _emailController.text);
      return;
    }
    if (step == ForgotPasswordStep.otp) {
      if (_otpController.text.trim().length != 4) return;
      cubit.verifyOtp(otp: _otpController.text.trim());
      return;
    }
    if (Validators.password(_passwordController.text) != null) return;
    if (_confirmController.text != _passwordController.text) return;
    cubit.resetPassword(
      newPassword: _passwordController.text,
      confirmPassword: _confirmController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = widget.form.isLoading;
    final step = widget.form.step;
    final label = step == ForgotPasswordStep.email
        ? 'Send OTP'
        : step == ForgotPasswordStep.otp
            ? 'Verify OTP'
            : 'Update password';

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (step == ForgotPasswordStep.email) ...[
              const AuthFieldLabel('Email address'),
              const SizedBox(height: 8),
              AuthTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                hintText: 'name@company.com',
                prefix: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                showError:
                    _submitted && Validators.email(_emailController.text) != null,
                errorText: Validators.email(_emailController.text),
                onFieldSubmitted: (_) => _submit(),
              ),
            ] else if (step == ForgotPasswordStep.otp) ...[
              Text(
                'Code sent to',
                style: portalText(fontSize: 12.5, color: PortalColors.muted),
              ),
              const SizedBox(height: 4),
              Text(
                widget.form.email,
                style: portalText(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                ),
              ),
              const SizedBox(height: 20),
              const AuthFieldLabel('Verification code'),
              const SizedBox(height: 8),
              AuthTextField(
                controller: _otpController,
                focusNode: _otpFocus,
                hintText: '4-digit OTP',
                prefix: Icons.pin_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                showError: _submitted && _otpController.text.trim().length != 4,
                errorText: 'Enter the 4-digit OTP',
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: loading
                      ? null
                      : () => context.read<ForgotPasswordCubit>().resendOtp(),
                  child: Text(
                    'Resend code',
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.purple,
                    ),
                  ),
                ),
              ),
            ] else ...[
              const AuthFieldLabel('New password'),
              const SizedBox(height: 8),
              AuthTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                hintText: 'At least 6 characters',
                prefix: Icons.lock_outline_rounded,
                obscureText: _obscureNew,
                textInputAction: TextInputAction.next,
                showError: _submitted &&
                    Validators.password(_passwordController.text) != null,
                errorText: Validators.password(_passwordController.text),
                onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                suffix: _eye(_obscureNew, () {
                  setState(() => _obscureNew = !_obscureNew);
                }),
              ),
              const SizedBox(height: 16),
              const AuthFieldLabel('Confirm password'),
              const SizedBox(height: 8),
              AuthTextField(
                controller: _confirmController,
                focusNode: _confirmFocus,
                hintText: 'Re-enter new password',
                prefix: Icons.lock_outline_rounded,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                showError: _submitted &&
                    (_confirmController.text.isEmpty ||
                        _confirmController.text != _passwordController.text),
                errorText: _confirmController.text.isEmpty
                    ? 'Confirm your password'
                    : 'Passwords do not match',
                onFieldSubmitted: (_) => _submit(),
                suffix: _eye(_obscureConfirm, () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                }),
              ),
            ],
            const SizedBox(height: 24),
            AuthPrimaryButton(
              label: label,
              isLoading: loading,
              onPressed: loading ? null : _submit,
            ),
            if (step == ForgotPasswordStep.email) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(
                  'Back to Sign in',
                  style: portalText(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.purple,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
