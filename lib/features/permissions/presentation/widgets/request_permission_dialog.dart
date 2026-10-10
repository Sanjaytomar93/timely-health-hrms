import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/permissions/data/datasources/permission_remote_datasource.dart';

Future<bool?> showRequestPermissionDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierColor: const Color(0x70000000),
    builder: (_) => const RequestPermissionDialog(),
  );
}

class RequestPermissionDialog extends StatefulWidget {
  const RequestPermissionDialog({super.key});

  @override
  State<RequestPermissionDialog> createState() =>
      _RequestPermissionDialogState();
}

class _RequestPermissionDialogState extends State<RequestPermissionDialog> {
  final _reason = TextEditingController();
  final _dataSource = PermissionRemoteDataSource();
  int _duration = 30;
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reason.text.trim();
    if (reason.isEmpty) {
      _showMessage('Please enter a reason.');
      return;
    }

    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    final employeeId = employee?.employeeId.trim() ?? '';
    if (employeeId.isEmpty) {
      _showMessage('Employee ID missing. Please login again.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await _dataSource.requestPermission(
        employeeId: employeeId,
        employeeName: employee?.displayName ?? employeeId,
        reason: reason,
        duration: _duration,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission request sent successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on PermissionRequestException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('Failed to send permission request. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: (width - 36).clamp(300.0, 430.0),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        decoration: BoxDecoration(
          color: PortalColors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: PortalColors.purpleTint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: PortalColors.purple,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Request Permission',
                      style: portalText(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: PortalColors.heading,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded),
                    color: PortalColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _label('Reason'),
              const SizedBox(height: 7),
              TextField(
                controller: _reason,
                enabled: !_submitting,
                minLines: 3,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration('Why do you need permission?'),
                style: portalText(fontSize: 14, color: PortalColors.heading),
              ),
              const SizedBox(height: 18),
              _label('Duration (minutes)'),
              const SizedBox(height: 7),
              _DurationStepper(
                value: _duration,
                enabled: !_submitting,
                onDecrease: () => setState(() => _duration -= 5),
                onIncrease: () => setState(() => _duration += 5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PortalColors.secondaryText,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: PortalColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PortalColors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 19,
                              width: 19,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Request'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String value) => Text(
    value,
    style: portalText(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: PortalColors.secondaryText,
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: portalText(fontSize: 14, color: const Color(0xFF9B9AAD)),
    filled: true,
    fillColor: PortalColors.background,
    contentPadding: const EdgeInsets.all(14),
    border: _border(),
    enabledBorder: _border(),
    focusedBorder: _border(PortalColors.purple),
  );

  OutlineInputBorder _border([Color? color]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(13),
    borderSide: BorderSide(color: color ?? PortalColors.border),
  );
}

class _DurationStepper extends StatelessWidget {
  const _DurationStepper({
    required this.value,
    required this.enabled,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int value;
  final bool enabled;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            enabled: enabled && value > 5,
            onPressed: onDecrease,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value',
                  style: portalText(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                  ),
                ),
                Text(
                  'minutes',
                  style: portalText(fontSize: 10.5, color: PortalColors.muted),
                ),
              ],
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            enabled: enabled && value < 480,
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      style: IconButton.styleFrom(
        backgroundColor: enabled ? PortalColors.purpleTint : Colors.transparent,
        foregroundColor: PortalColors.purple,
        disabledForegroundColor: PortalColors.border,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon),
    );
  }
}
