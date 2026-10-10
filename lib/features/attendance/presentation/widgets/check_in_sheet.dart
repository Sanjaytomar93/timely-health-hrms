import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timelay_health/core/location/location_helper.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/check_in_cubit.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/check_in_state.dart';
import 'package:timelay_health/features/attendance/presentation/utils/attendance_feedback.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/attendance_success_dialog.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/check_in_photo_preview.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/mark_attendance_flow_body.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/mark_attendance_welcome_dialog.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/outside_range_dialog.dart';
import 'package:timelay_health/features/dashboard/presentation/bloc/dashboard_cubit.dart';

class CheckInColors {
  const CheckInColors._();

  static const Color sheetBg = Color(0xFFF4F3FB);
  static const Color mirage = Color(0xFF1C1730);
}

TextStyle _ci({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = CheckInColors.mirage,
}) {
  return GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}

Future<void> showCheckInSheet(BuildContext context) async {
  DashboardCubit? dashboardCubit;
  AttendanceCubit? attendanceCubit;
  try {
    dashboardCubit = context.read<DashboardCubit>();
  } catch (_) {
    dashboardCubit = null;
  }
  try {
    attendanceCubit = context.read<AttendanceCubit>();
  } catch (_) {
    attendanceCubit = null;
  }

  final cubit = CheckInCubit()..prepare();

  final started = await showMarkAttendanceWelcomeDialog(context);
  if (!started || !context.mounted) {
    await cubit.close();
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.44),
    builder: (sheetContext) {
      return BlocProvider.value(
        value: cubit,
        child: CheckInSheet(
          onCompleted: () async {
            await Future.wait([
              if (dashboardCubit != null)
                dashboardCubit!.load(keepExisting: true),
              if (attendanceCubit != null)
                attendanceCubit!.load(keepExisting: true),
            ]);
          },
        ),
      );
    },
  );
}

class CheckInSheet extends StatelessWidget {
  const CheckInSheet({super.key, this.onCompleted});

  final Future<void> Function()? onCompleted;

  static const _pinRed = 'assets/icons/check_in/ic_pin_red.svg';
  static const _building = 'assets/icons/check_in/ic_building.svg';
  static const _close = 'assets/icons/check_in/ic_close.svg';

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.94;

    return BlocConsumer<CheckInCubit, CheckInState>(
      listenWhen: (p, c) => c is CheckInSuccess || c is CheckInFailureState,
      listener: (context, state) async {
        if (state is CheckInFailureState) {
          final needsSettings = state.message.toLowerCase().contains(
            'settings',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFD32F4A),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 6),
              action: needsSettings
                  ? SnackBarAction(
                      label: 'Settings',
                      textColor: Colors.white,
                      onPressed: () => LocationHelper.openAppSettings(),
                    )
                  : null,
            ),
          );
          return;
        }
        if (state is CheckInSuccess) {
          await showAttendanceSuccessDialog(
            context,
            data: state.data,
            success: state,
          );
          if (!context.mounted) return;
          await onCompleted?.call();
          if (!context.mounted) return;
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final data = state.readyData;
        final loading = state is CheckInPreparing || state is CheckInInitial;
        final submitting = state is CheckInSubmitting;
        final capturing = state is CheckInCapturingLocation;

        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: height,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: CheckInColors.sheetBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : (data == null
                        ? _ErrorBody(
                            message: state is CheckInFailureState
                                ? state.message
                                : 'Unable to load attendance.',
                          )
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                            child: MarkAttendanceFlowBody(
                              data: data,
                              pinRed: _pinRed,
                              building: _building,
                              closeAsset: _close,
                              capturing: capturing,
                              submitting: submitting,
                              onClose: () => Navigator.of(context).pop(),
                              onGetLocation: () => context
                                  .read<CheckInCubit>()
                                  .captureLocation(),
                              onCheckIn: (reason) => _submit(
                                context,
                                requirePhoto: data.requirePhoto,
                                selectedReason: reason,
                              ),
                            ),
                          )),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit(
    BuildContext context, {
    required bool requirePhoto,
    String? selectedReason,
  }) async {
    final cubit = context.read<CheckInCubit>();
    final ready = cubit.state.readyData;
    if (ready == null || !ready.locationCaptured) return;

    if (requirePhoto) {
      while (context.mounted) {
        final XFile? file;
        try {
          file = await ImagePicker().pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
            preferredCameraDevice: CameraDevice.front,
            maxWidth: 1280,
          );
        } on PlatformException catch (e) {
          if (!context.mounted) return;
          final denied =
              e.code.toLowerCase().contains('permission') ||
              (e.message?.toLowerCase().contains('permission') ?? false) ||
              e.code == 'camera_access_denied' ||
              e.code == 'photo_access_denied';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                denied
                    ? 'Camera permission denied. Allow camera access to continue.'
                    : (e.message?.isNotEmpty == true
                          ? e.message!
                          : 'Unable to open camera. Please try again.'),
              ),
              backgroundColor: const Color(0xFFD32F4A),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 6),
              action: denied
                  ? SnackBarAction(
                      label: 'Settings',
                      textColor: Colors.white,
                      onPressed: () => LocationHelper.openAppSettings(),
                    )
                  : null,
            ),
          );
          return;
        } catch (_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open camera. Please try again.'),
              backgroundColor: Color(0xFFD32F4A),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        if (file == null || !context.mounted) return;

        await AttendanceFeedback.playShutterSound();
        if (!context.mounted) return;

        final confirmed = await showCheckInPhotoPreview(
          context,
          imagePath: file.path,
          isCheckout: ready.mode == MarkAttendanceMode.checkOut,
        );
        if (!context.mounted) return;
        if (confirmed != true) {
          if (confirmed == null) return;
          continue;
        }

        var reason = selectedReason;
        if (cubit.needsReason() && (reason == null || reason.trim().isEmpty)) {
          reason = await showOutsideRangeDialog(
            context,
            distanceMeters: ready.distanceMeters,
          );
          if (reason == null || !context.mounted) return;
        }

        await cubit.submit(reason: reason, imagePath: file.path);
        return;
      }
      return;
    }

    var reason = selectedReason;
    if (cubit.needsReason() && (reason == null || reason.trim().isEmpty)) {
      reason = await showOutsideRangeDialog(
        context,
        distanceMeters: ready.distanceMeters,
      );
      if (reason == null || !context.mounted) return;
    }

    await cubit.submit(reason: reason);
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: _ci(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<CheckInCubit>().prepare(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
