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
            padding: EdgeInsets.fromLTRB(28, keyboardOpen ? 10 : 12, 28, 24),
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
                    const SizedBox(height: 18),
                  ],
                  Text(
                    'Sign in',
                    style: portalText(
                      fontSize: keyboardOpen ? 22 : 24,
                      fontWeight: FontWeight.w800,
                      color: PortalColors.heading,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (!keyboardOpen) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Enter your work credentials to continue',
                      style: portalText(
                        fontSize: 13,
                        color: PortalColors.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                  SizedBox(height: keyboardOpen ? 12 : 18),
                  if (!keyboardOpen) ...[
                    const _FieldLabel('Email address'),
                    const SizedBox(height: 6),
                  ],
                  _UnderlineField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    hintText: 'name@company.com',
                    prefix: Icons.mail_outline_rounded,
                    validator: Validators.email,
                    showEmptyError: _submitted,
                    onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                  SizedBox(height: keyboardOpen ? 10 : 12),
                  if (!keyboardOpen)
                    Row(
                      children: [
                        const Expanded(child: _FieldLabel('Password')),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Forgot?',
                            style: portalText(
                              fontSize: 12,
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
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.purple,
                          ),
                        ),
                      ),
                    ),
                  if (!keyboardOpen) const SizedBox(height: 6),
                  if (keyboardOpen) const SizedBox(height: 6),
                  _UnderlineField(
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
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: PortalColors.muted,
                        size: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: keyboardOpen ? 14 : 20),
                  _SignInButton(
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _onLoginPressed,
                  ),
                  if (!keyboardOpen) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 13,
                          color: PortalColors.muted.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Secure access for admins & employees',
                          style: portalText(
                            fontSize: 11.5,
                            color: PortalColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Powered by Timely Health HRMS',
                      textAlign: TextAlign.center,
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: PortalColors.muted.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v1.0.0  ·  © 2026 Timely Health',
                      textAlign: TextAlign.center,
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: PortalColors.muted.withValues(alpha: 0.45),
                        letterSpacing: 0.5,
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
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: PortalColors.secondaryText,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _UnderlineField extends StatelessWidget {
  const _UnderlineField({
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
            : Colors.transparent;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 44,
              decoration: BoxDecoration(
                color: focused
                    ? PortalColors.purpleTint.withValues(alpha: 0.55)
                    : const Color(0xFFF3F1F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1.2),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    prefix,
                    size: 17,
                    color: showRed
                        ? const Color(0xFFE11D48)
                        : focused
                        ? PortalColors.purple
                        : PortalColors.muted,
                  ),
                  const SizedBox(width: 8),
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
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: PortalColors.heading,
                        height: 1.1,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        isCollapsed: true,
                        hintText: hintText,
                        hintStyle: portalText(
                          fontSize: 13.5,
                          color: PortalColors.muted,
                          height: 1.1,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (suffix != null)
                    SizedBox(width: 32, height: 32, child: suffix),
                  const SizedBox(width: 6),
                ],
              ),
            ),
            if (showRed)
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: Text(
                  validator?.call(controller.text) ?? 'Required',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE11D48),
                    height: 1.2,
                  ),
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

class _SignInButton extends StatefulWidget {
  const _SignInButton({required this.onPressed, required this.isLoading});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<_SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<_SignInButton> {
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
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.55,
          duration: const Duration(milliseconds: 150),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF5B2FE0),
                  Color(0xFF26204A),
                  Color(0xFF4B4285),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF26204A).withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: portalText(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
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
