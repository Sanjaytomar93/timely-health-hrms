import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/utils/validators.dart';
import 'package:timelay_health/features/auth/presentation/bloc/login_cubit.dart';
import 'package:timelay_health/features/auth/presentation/bloc/login_state.dart';
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
  bool _obscurePassword = true;
  bool _submitted = false;
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 80;

    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          current is LoginSuccess || current is LoginFailure,
      listener: (context, state) {
        if (state is LoginFailure) {
          _showError(state.message);
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
            padding: EdgeInsets.fromLTRB(32, keyboardOpen ? 8 : 16, 32, 28),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!keyboardOpen) ...[
                    Center(
                      child: Container(
                        width: 36,
                        height: 3.5,
                        decoration: BoxDecoration(
                          color: PortalColors.border.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
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
                      'Enter your credentials to access your account',
                      style: portalText(
                        fontSize: 13.5,
                        color: PortalColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                  SizedBox(height: keyboardOpen ? 16 : 24),
                  if (!keyboardOpen) ...[
                    const _FieldLabel('Email address'),
                    const SizedBox(height: 8),
                  ],
                  _ModernField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    hintText: 'Enter your email',
                    prefix: Icons.mail_outline_rounded,
                    validator: Validators.email,
                    showEmptyError: _submitted,
                    onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                  SizedBox(height: keyboardOpen ? 14 : 16),
                  if (!keyboardOpen)
                    Row(
                      children: [
                        const Expanded(child: _FieldLabel('Password')),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Forgot password?',
                            style: portalText(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.purple,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Forgot?',
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.purple,
                          ),
                        ),
                      ),
                    ),
                  if (!keyboardOpen) const SizedBox(height: 8),
                  if (keyboardOpen) const SizedBox(height: 8),
                  _ModernField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    inputFormatters: const [_AsciiDigitFormatter()],
                    textInputAction: TextInputAction.done,
                    hintText: 'Enter your password',
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
                  SizedBox(height: keyboardOpen ? 18 : 24),
                  _ModernSignInButton(
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _onLoginPressed,
                  ),
                  if (!keyboardOpen) ...[
                    const SizedBox(height: 24),
                    _SecurityBadge(),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: portalText(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: PortalColors.secondaryText,
        letterSpacing: 0.25,
      ),
    );
  }
}

class _ModernField extends StatelessWidget {
  const _ModernField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.prefix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.showEmptyError = false,
    this.onFieldSubmitted,
    this.suffix,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final IconData prefix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool showEmptyError;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;

    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      autovalidateMode: AutovalidateMode.disabled,
      builder: (field) {
        final isEmpty = controller.text.trim().isEmpty;
        final showRed = showEmptyError && isEmpty;
        final borderColor = showRed
            ? const Color(0xFFE11D48)
            : focused
            ? PortalColors.purple
            : PortalColors.border;
        final fillColor = focused
            ? PortalColors.purpleTint.withValues(alpha: 0.7)
            : const Color(0xFFF6F5FB);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: focused ? 1.5 : 1),
                boxShadow: focused
                    ? [
                        BoxShadow(
                          color: PortalColors.purple.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: showRed
                          ? const Color(0xFFE11D48).withValues(alpha: 0.1)
                          : focused
                              ? PortalColors.purple.withValues(alpha: 0.12)
                              : PortalColors.muted.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      prefix,
                      size: 18,
                      color: showRed
                          ? const Color(0xFFE11D48)
                          : focused
                              ? PortalColors.purple
                              : PortalColors.muted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      obscureText: obscureText,
                      keyboardType: keyboardType ?? TextInputType.text,
                      textInputAction: textInputAction,
                      autocorrect: false,
                      enableSuggestions: false,
                      inputFormatters: inputFormatters,
                      autofillHints: obscureText
                          ? const [AutofillHints.password]
                          : const <String>[],
                      onChanged: field.didChange,
                      onSubmitted: onFieldSubmitted,
                      scrollPadding: const EdgeInsets.only(bottom: 80),
                      style: portalText(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: PortalColors.heading,
                        height: 1.2,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        isCollapsed: true,
                        hintText: hintText,
                        hintStyle: portalText(
                          fontSize: 14,
                          color: PortalColors.muted,
                          height: 1.2,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (suffix != null)
                    SizedBox(width: 36, height: 36, child: suffix),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            if (showRed)
              Padding(
                padding: const EdgeInsets.only(left: 6, top: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 12,
                      color: Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      validator?.call(controller.text) ?? 'Required',
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFE11D48),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AsciiDigitFormatter extends TextInputFormatter {
  const _AsciiDigitFormatter();

  static const _blocks = <int>[
    0x0660,
    0x06F0,
    0x0966,
    0x09E6,
    0x0A66,
    0x0AE6,
    0x0B66,
    0x0BE6,
    0x0C66,
    0x0CE6,
    0x0D66,
    0x0E50,
    0x0ED0,
    0x0F20,
    0x1040,
    0x17E0,
    0x1810,
    0xFF10,
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

class _ModernSignInButton extends StatefulWidget {
  const _ModernSignInButton({required this.onPressed, required this.isLoading});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<_ModernSignInButton> createState() => _ModernSignInButtonState();
}

class _ModernSignInButtonState extends State<_ModernSignInButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.5,
          duration: const Duration(milliseconds: 160),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment(-0.8, -0.6),
                end: Alignment(0.8, 0.6),
                colors: [
                  Color(0xFF5B2FE0),
                  Color(0xFF7C6FD4),
                  Color(0xFF26204A),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B2FE0).withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFF26204A).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign In',
                          style: portalText(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF18AC96).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF18AC96).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield_rounded,
            size: 16,
            color: const Color(0xFF18AC96),
          ),
          const SizedBox(width: 8),
          Text(
            'Secure access for admins & employees',
            style: portalText(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF18AC96),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
