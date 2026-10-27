import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});

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
