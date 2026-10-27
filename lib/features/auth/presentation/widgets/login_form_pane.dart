import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/utils/validators.dart';
import 'package:timelay_health/features/auth/presentation/bloc/login_cubit.dart';
import 'package:timelay_health/features/auth/presentation/bloc/login_state.dart';
import 'package:timelay_health/features/auth/presentation/widgets/auth_field_label.dart';
import 'package:timelay_health/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:timelay_health/features/auth/presentation/widgets/auth_soft_snackbar.dart';
import 'package:timelay_health/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:timelay_health/features/auth/presentation/widgets/login_success_dialog.dart';

class LoginFormPane extends StatefulWidget {
  const LoginFormPane({super.key});

  @override
  State<LoginFormPane> createState() => _LoginFormPaneState();
}

class _LoginFormPaneState extends State<LoginFormPane> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    for (final n in [_emailFocus, _passwordFocus]) {
      n.addListener(() => setState(() {}));
    }
    for (final c in [_emailController, _passwordController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!(_formKey.currentState?.validate() ?? false)) return;
      HapticFeedback.lightImpact();
      context.read<LoginCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    });
  }

  String _friendlyLoginMessage(String raw) {
    final text = raw.trim().toLowerCase();
    if (text.isEmpty) {
      return 'We couldn’t sign you in. Please check your details and try again.';
    }
    final isCredentialIssue = text.contains('invalid') ||
        text.contains('incorrect') ||
        text.contains('wrong password') ||
        text.contains('unauthorized') ||
        text.contains('credentials') ||
        text.contains('not found') ||
        text.contains('does not exist') ||
        text.contains('no employee') ||
        text.contains('login failed');
    if (isCredentialIssue) {
      return 'Email or password doesn’t match. Please try again.';
    }
    return raw.trim();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 80;

    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          current is LoginSuccess || current is LoginFailure,
      listener: (context, state) {
        if (state is LoginFailure) {
          showAuthSoftSnackbar(
            context,
            _friendlyLoginMessage(state.message),
            isError: true,
          );
          return;
        }
        if (state is LoginSuccess) {
          final employee = state.employee;
          final displayName = employee.displayName;
          final role =
              [employee.designation, employee.role, employee.department]
                  .map((e) => e.trim())
                  .firstWhere((e) => e.isNotEmpty, orElse: () => '');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            showLoginSuccessAndGoHome(
              context,
              displayName: displayName,
              role: role,
            );
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is LoginLoading;
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(28, keyboardOpen ? 10 : 16, 28, 24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!keyboardOpen) ...[
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: PortalColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    'Sign in',
                    style: portalText(
                      fontSize: keyboardOpen ? 24 : 28,
                      fontWeight: FontWeight.w800,
                      color: PortalColors.heading,
                      letterSpacing: -0.6,
                    ),
                  ),
                  if (!keyboardOpen) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Enter your work credentials to continue',
                      style: portalText(
                        fontSize: 13.5,
                        color: PortalColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                  SizedBox(height: keyboardOpen ? 16 : 22),
                  if (!keyboardOpen) ...[
                    const AuthFieldLabel('Email address'),
                    const SizedBox(height: 8),
                  ],
                  AuthTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    hintText: 'name@company.com',
                    prefix: Icons.mail_outline_rounded,
                    validator: Validators.email,
                    showEmptyError: _submitted,
                    onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                  SizedBox(height: keyboardOpen ? 14 : 16),
                  if (!keyboardOpen) ...[
                    const AuthFieldLabel('Password'),
                    const SizedBox(height: 8),
                  ],
                  AuthTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    inputFormatters: const [_AsciiDigitFormatter()],
                    textInputAction: TextInputAction.done,
                    hintText: 'Your password',
                    prefix: Icons.lock_outline_rounded,
                    validator: Validators.password,
                    showEmptyError: _submitted,
                    onFieldSubmitted: (_) => _onLoginPressed(),
                    suffix: IconButton(
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: PortalColors.muted,
                        size: 20,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        AppRoutes.push(context, AppRoutes.forgotPassword);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: PortalColors.purple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 10,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot password?',
                        style: portalText(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: PortalColors.purple,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: keyboardOpen ? 8 : 12),
                  AuthPrimaryButton(
                    label: 'Continue',
                    showArrow: true,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _onLoginPressed,
                  ),
                  if (!keyboardOpen) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 15,
                          color: PortalColors.muted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Secure access for admins & employees',
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PortalColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Powered by Timely Health HRMS',
                      textAlign: TextAlign.center,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PortalColors.muted.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v1.0.0  ·  © 2026 Timely Health',
                      textAlign: TextAlign.center,
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: PortalColors.muted.withValues(alpha: 0.4),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AsciiDigitFormatter extends TextInputFormatter {
  const _AsciiDigitFormatter();

  static const _blocks = <int>[
    0x0660, 0x06F0, 0x0966, 0x09E6, 0x0A66, 0x0AE6, 0x0B66, 0x0BE6,
    0x0C66, 0x0CE6, 0x0D66, 0x0E50, 0x0ED0, 0x0F20, 0x1040, 0x17E0,
    0x1810, 0xFF10,
  ];

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buffer = StringBuffer();
    for (final rune in newValue.text.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buffer.writeCharCode(rune);
        continue;
      }
      var digit = -1;
      for (final start in _blocks) {
        if (rune >= start && rune <= start + 9) {
          digit = rune - start;
          break;
        }
      }
      if (digit >= 0) {
        buffer.write(digit);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    final text = buffer.toString();
    if (text == newValue.text) return newValue;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
