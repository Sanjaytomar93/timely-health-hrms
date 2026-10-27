import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

/// Makes sure GPS is on and location permission is granted before reading
/// the device position. Shows the system permission popup when possible and
/// otherwise guides the user to Settings. Returns `true` when location can
/// be read.
Future<bool> ensureLocationAccess(BuildContext context) async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    if (!context.mounted) return false;
    final openSettings = await _showLocationDialog(
      context,
      icon: Icons.location_off_rounded,
      title: 'Turn On Location',
      message:
          'Your device location is turned off. Please turn on location '
          '(GPS) to mark your attendance.',
      actionLabel: 'Turn On',
    );
    if (!openSettings) return false;
    if (await Geolocator.openLocationSettings()) await _waitForAppResume();
    if (!await Geolocator.isLocationServiceEnabled()) return false;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  while (permission == LocationPermission.denied) {
    if (!context.mounted) return false;
    final retry = await _showLocationDialog(
      context,
      icon: Icons.location_disabled_rounded,
      title: 'Location Permission Required',
      message:
          'We need access to your location to verify that you are at your '
          'assigned office while marking attendance.',
      actionLabel: 'Allow',
    );
    if (!retry) return false;
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    if (!context.mounted) return false;
    final openSettings = await _showLocationDialog(
      context,
      icon: Icons.settings_rounded,
      title: 'Enable Location Access',
      message:
          'Location permission is turned off for this app. Open Settings '
          '> Permissions > Location and select "Allow while using the app".',
      actionLabel: 'Open Settings',
    );
    if (!openSettings) return false;
    if (await Geolocator.openAppSettings()) await _waitForAppResume();
    permission = await Geolocator.checkPermission();
  }

  return permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always;
}

Future<void> _waitForAppResume() {
  final completer = Completer<void>();
  late final AppLifecycleListener listener;
  listener = AppLifecycleListener(
    onResume: () {
      if (!completer.isCompleted) completer.complete();
    },
  );
  return completer.future
      .timeout(const Duration(minutes: 3), onTimeout: () {})
      .whenComplete(listener.dispose);
}

Future<bool> _showLocationDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required String actionLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (context) => _LocationAccessDialog(
      icon: icon,
      title: title,
      message: message,
      actionLabel: actionLabel,
    ),
  );
  return result ?? false;
}

class _LocationAccessDialog extends StatelessWidget {
  const _LocationAccessDialog({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: PortalColors.redTint,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: PortalColors.red, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: portalText(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: PortalColors.heading,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: portalText(
                fontSize: 13,
                color: PortalColors.secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: 'Cancel',
                    background: const Color(0xFFF0F0F3),
                    foreground: PortalColors.heading,
                    onTap: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: actionLabel,
                    background: PortalColors.brand,
                    foreground: Colors.white,
                    onTap: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              style: portalText(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
