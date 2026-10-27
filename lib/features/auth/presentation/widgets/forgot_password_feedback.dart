import 'package:flutter/material.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/presentation/widgets/auth_soft_snackbar.dart';

void showForgotPasswordSoftMessage(
  BuildContext context,
  String message, {
  required bool isError,
}) {
  showAuthSoftSnackbar(context, message, isError: isError);
}

Future<void> showForgotPasswordSuccessDialog(
  BuildContext context, {
  required String message,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: PortalColors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_open_rounded,
                  color: PortalColors.green,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Password updated',
                style: portalText(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: PortalColors.heading,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: portalText(
                  fontSize: 13.5,
                  color: PortalColors.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    AppRoutes.pushAndRemoveUntil(context, AppRoutes.login);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: PortalColors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Back to Sign in',
                    style: portalText(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
