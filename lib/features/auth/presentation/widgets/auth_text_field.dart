import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.prefix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.showEmptyError = false,
    this.showError = false,
    this.errorText,
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
  final bool showError;
  final String? errorText;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    if (validator == null) {
      return _buildField(onChanged: null);
    }
    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      autovalidateMode: AutovalidateMode.disabled,
      builder: (field) => _buildField(onChanged: field.didChange),
    );
  }

  Widget _buildField({required ValueChanged<String>? onChanged}) {
    final focused = focusNode.hasFocus;
    final isEmpty = controller.text.trim().isEmpty;
    final showRed = showError || (showEmptyError && isEmpty);
    final message = showRed
        ? (errorText ?? validator?.call(controller.text) ?? 'Required')
        : null;
    final borderColor = showRed
        ? const Color(0xFFE11D48)
        : focused
            ? PortalColors.purple
            : PortalColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: focused
                ? Colors.white.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.72),
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
                : const [],
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
                  onChanged: onChanged,
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
              if (suffix != null) SizedBox(width: 36, height: 36, child: suffix),
              const SizedBox(width: 8),
            ],
          ),
        ),
        if (message != null)
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
                Flexible(
                  child: Text(
                    message,
                    style: portalText(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE11D48),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
