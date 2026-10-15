import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/check_in_state.dart';

const kMarkAttendanceReasons = <String>[
  'Field Work',
  'Work From Home',
  'Client Meeting',
  'Other',
];

const _green = Color(0xFF16A34A);
const _greenBright = Color(0xFF22C55E);
const _greenTint = Color(0xFFECFDF3);
const _red = Color(0xFFDC2626);
const _redTint = Color(0xFFFFF1F2);
const _amber = Color(0xFFD97706);
const _amberTint = Color(0xFFFFF7ED);
const _muted = Color(0xFF9B96AD);
const _border = Color(0xFFEDEAF5);

class MarkAttendanceFlowBody extends StatefulWidget {
  const MarkAttendanceFlowBody({
    super.key,
    required this.data,
    required this.pinRed,
    required this.building,
    required this.closeAsset,
    required this.capturing,
    required this.submitting,
    required this.onClose,
    required this.onGetLocation,
    required this.onChangeLocation,
    required this.onCheckIn,
  });

  final CheckInReadyData data;
  final String pinRed;
  final String building;
  final String closeAsset;
  final bool capturing;
  final bool submitting;
  final VoidCallback onClose;
  final VoidCallback onGetLocation;
  final VoidCallback onChangeLocation;
  final Future<void> Function(String? reason) onCheckIn;

  @override
  State<MarkAttendanceFlowBody> createState() => _MarkAttendanceFlowBodyState();
}

class _MarkAttendanceFlowBodyState extends State<MarkAttendanceFlowBody> {
  String? _reason;

  CheckInReadyData get data => widget.data;
  bool get captured => data.locationCaptured;
  bool get isCheckout => data.mode == MarkAttendanceMode.checkOut;
  bool get outside => captured && !data.withinRadius;
  bool get busy => widget.capturing || widget.submitting;
  bool get canSubmit =>
      !busy && (isCheckout || !outside || _reason != null);

  @override
  Widget build(BuildContext context) {
    final actionLabel = isCheckout ? 'Check Out' : 'Check In';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroHeader(
          title: actionLabel,
          name: data.displayName,
          isCheckout: isCheckout,
          closeAsset: widget.closeAsset,
          onClose: widget.onClose,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StepIndicator(
                  steps: [
                    'Location',
                    if (data.requirePhoto) 'Selfie',
                    actionLabel,
                  ],
                  current: captured ? 1 : 0,
                ),
                const SizedBox(height: 14),
                _LocationCard(
                  data: data,
                  building: widget.building,
                  captured: captured,
                  capturing: widget.capturing,
                  outside: outside,
                  onChange: busy ? null : widget.onChangeLocation,
                  onRefresh: busy ? null : widget.onGetLocation,
                ),
                const SizedBox(height: 12),
                _AttendanceStatusCard(isActive: isCheckout),
                if (captured && outside && !isCheckout) ...[
                  const SizedBox(height: 12),
                  _ReasonCard(
                    distanceMeters: data.distanceMeters,
                    reason: _reason,
                    onChanged: busy
                        ? null
                        : (v) => setState(() => _reason = v),
                  ),
                ],
              ],
            ),
          ),
        ),
        _ActionArea(
          button: !captured
              ? _GradientButton(
                  label: widget.capturing
                      ? 'Fetching location...'
                      : 'Get Location',
                  icon: Icons.my_location_rounded,
                  enabled: !busy,
                  loading: widget.capturing,
                  onTap: widget.onGetLocation,
                )
              : _GradientButton(
                  label: data.requirePhoto
                      ? '$actionLabel with Photo'
                      : actionLabel,
                  icon: data.requirePhoto
                      ? Icons.photo_camera_rounded
                      : (isCheckout
                            ? Icons.logout_rounded
                            : Icons.login_rounded),
                  badge: data.requirePhoto ? 'Selfie' : null,
                  enabled: canSubmit,
                  loading: widget.submitting,
                  onTap: () => widget.onCheckIn(
                    outside && !isCheckout ? _reason : null,
                  ),
                ),
          hint: !captured
              ? 'Verify your location to continue'
              : (outside && !isCheckout && _reason == null
                    ? 'Select a reason to continue'
                    : (data.requirePhoto
                          ? 'A selfie will be captured for verification'
                          : 'You are all set')),
        ),
        const SizedBox(height: 8),
        Text(
          'Powered by Timely Health HRMS',
          textAlign: TextAlign.center,
          style: _t(fontSize: 10, color: _muted, letterSpacing: 0.2),
        ),
      ],
    );
  }
}

TextStyle _t({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = const Color(0xFF2A2540),
  double? height,
  double? letterSpacing,
  List<FontFeature>? fontFeatures,
}) {
  return GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    fontFeatures: fontFeatures,
  );
}

String _formatDistance(int meters) {
  if (meters < 1000) return '${meters}m';
  final km = meters / 1000;
  return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
}

BoxDecoration _cardDecoration({Color color = Colors.white, Color? border}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: border ?? _border),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF26204A).withValues(alpha: 0.05),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

class _HeroHeader extends StatefulWidget {
  const _HeroHeader({
    required this.title,
    required this.name,
    required this.isCheckout,
    required this.closeAsset,
    required this.onClose,
  });

  final String title;
  final String name;
  final bool isCheckout;
  final String closeAsset;
  final VoidCallback onClose;

  @override
  State<_HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<_HeroHeader> {
  late final Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _greeting {
    final h = _now.hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour12 = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final hm =
        '${hour12.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';
    final seconds = _now.second.toString().padLeft(2, '0');
    final period = _now.hour >= 12 ? 'PM' : 'AM';
    final date =
        '${weekdays[_now.weekday - 1]}, ${_now.day} ${months[_now.month - 1]} ${_now.year}';
    final firstName = widget.name.trim().split(RegExp(r'\s+')).first;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PortalColors.brand, PortalColors.brandLight],
        ),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -50,
            child: _GlowCircle(size: 160, alpha: 0.08),
          ),
          Positioned(
            right: 50,
            bottom: -60,
            child: _GlowCircle(size: 120, alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstName.isEmpty
                                ? _greeting
                                : '$_greeting, $firstName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.title,
                            style: _t(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: widget.onClose,
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: Center(
                            child: SvgPicture.asset(
                              widget.closeAsset,
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      hm,
                      style: _t(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1,
                        letterSpacing: -1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        ':$seconds',
                        style: _t(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6, bottom: 4),
                      child: Text(
                        period,
                        style: _t(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const _LiveBadge(),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: _t(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _BlinkingDot(size: 7, glow: true),
          const SizedBox(width: 6),
          Text(
            'LIVE',
            style: _t(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot({required this.size, this.glow = false});

  final double size;
  final bool glow;

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.2).animate(_controller),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _greenBright,
          shape: BoxShape.circle,
          boxShadow: widget.glow
              ? [
                  BoxShadow(
                    color: _greenBright.withValues(alpha: 0.5),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.steps, required this.current});

  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      final done = i < current;
      final active = i == current;
      children.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? _green
                    : (active ? PortalColors.brand : Colors.white),
                border: Border.all(
                  color: done
                      ? _green
                      : (active ? PortalColors.brand : const Color(0xFFD9D5E6)),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: done
                  ? const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: Colors.white,
                    )
                  : Text(
                      '${i + 1}',
                      style: _t(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : _muted,
                      ),
                    ),
            ),
            const SizedBox(height: 5),
            Text(
              steps[i],
              style: _t(
                fontSize: 11,
                fontWeight: active || done ? FontWeight.w600 : FontWeight.w500,
                color: active || done ? PortalColors.heading : _muted,
              ),
            ),
          ],
        ),
      );
      if (i < steps.length - 1) {
        children.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18, left: 6, right: 6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 2,
                decoration: BoxDecoration(
                  color: done ? _green : const Color(0xFFE2DEEC),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      decoration: _cardDecoration(),
      child: Row(children: children),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.data,
    required this.building,
    required this.captured,
    required this.capturing,
    required this.outside,
    required this.onChange,
    required this.onRefresh,
  });

  final CheckInReadyData data;
  final String building;
  final bool captured;
  final bool capturing;
  final bool outside;
  final VoidCallback? onChange;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final address =
        data.office?.fullAddress.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _IconTile(icon: Icons.location_on_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Verification',
                      style: _t(fontSize: 14.5, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      captured
                          ? 'Auto-detected via GPS'
                          : 'Must be within ${data.officeRadiusMeters}m of office',
                      style: _t(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF9FD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(building, width: 17, height: 17),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.officeName,
                        style: _t(fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                      if (address.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _t(fontSize: 11.5, color: _muted, height: 1.35),
                        ),
                      ],
                      const SizedBox(height: 6),
                      _Chip(
                        icon: Icons.radar_rounded,
                        label: 'Radius ${data.officeRadiusMeters}m',
                        color: PortalColors.brandLight,
                        background: PortalColors.brandTint,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _SmallButton(label: 'CHANGE', onTap: onChange),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: captured
                ? _DistanceResult(
                    key: const ValueKey('captured'),
                    distanceMeters: data.distanceMeters,
                    radiusMeters: data.officeRadiusMeters,
                    outside: outside,
                    capturing: capturing,
                    onRefresh: onRefresh,
                  )
                : _RadarPrompt(
                    key: const ValueKey('pending'),
                    scanning: capturing,
                  ),
          ),
        ],
      ),
    );
  }
}

class _RadarPrompt extends StatelessWidget {
  const _RadarPrompt({super.key, required this.scanning});

  final bool scanning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: PortalColors.brandTint.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _Radar(fast: scanning),
          const SizedBox(height: 12),
          Text(
            scanning ? 'Detecting your location...' : 'Location not captured',
            style: _t(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            scanning
                ? 'Hold on, this may take a few seconds'
                : "Tap 'Get Location' to verify you're at the office",
            textAlign: TextAlign.center,
            style: _t(fontSize: 12, color: _muted),
          ),
        ],
      ),
    );
  }
}

class _Radar extends StatefulWidget {
  const _Radar({required this.fast});

  final bool fast;

  @override
  State<_Radar> createState() => _RadarState();
}

class _RadarState extends State<_Radar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  )..repeat();

  Duration get _duration =>
      Duration(milliseconds: widget.fast ? 1200 : 2400);

  @override
  void didUpdateWidget(covariant _Radar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fast != widget.fast) {
      _controller
        ..duration = _duration
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 96.0;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              for (final offset in const [0.0, 0.5])
                _ring(((_controller.value + offset) % 1.0), size),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: PortalColors.brandGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PortalColors.brand.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _ring(double t, double size) {
    final d = 46 + (size - 46) * t;
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: PortalColors.brandLight.withValues(alpha: 0.18 * (1 - t)),
        border: Border.all(
          color: PortalColors.brandLight.withValues(alpha: 0.45 * (1 - t)),
        ),
      ),
    );
  }
}

class _DistanceResult extends StatelessWidget {
  const _DistanceResult({
    super.key,
    required this.distanceMeters,
    required this.radiusMeters,
    required this.outside,
    required this.capturing,
    required this.onRefresh,
  });

  final int distanceMeters;
  final int radiusMeters;
  final bool outside;
  final bool capturing;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final color = outside ? _red : _green;
    final tint = outside ? _redTint : _greenTint;
    final progress = outside
        ? (radiusMeters / math.max(distanceMeters, 1)).clamp(0.06, 1.0)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 78,
                height: 78,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress.toDouble()),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, _) => CircularProgressIndicator(
                          value: v,
                          strokeWidth: 6,
                          strokeCap: StrokeCap.round,
                          backgroundColor: Colors.white,
                          color: color,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatDistance(distanceMeters),
                          style: _t(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        Text(
                          'away',
                          style: _t(fontSize: 10, color: _muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Chip(
                      icon: outside
                          ? Icons.gpp_maybe_rounded
                          : Icons.verified_rounded,
                      label: outside ? 'Outside Range' : 'Inside Range',
                      color: color,
                      background: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      outside
                          ? 'You are ${_formatDistance(distanceMeters - radiusMeters)} beyond the allowed radius'
                          : "You're at the office. Good to go!",
                      style: _t(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: PortalColors.heading,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const _BlinkingDot(size: 6),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Location captured automatically',
                  style: _t(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: PortalColors.secondaryText,
                  ),
                ),
              ),
              capturing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _SmallButton(
                      label: 'REFRESH',
                      icon: Icons.refresh_rounded,
                      onTap: onRefresh,
                      background: Colors.white,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceStatusCard extends StatelessWidget {
  const _AttendanceStatusCard({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const _IconTile(icon: Icons.event_available_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Attendance",
                  style: _t(fontSize: 14.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  isActive ? 'Currently on duty' : 'Ready to mark attendance',
                  style: _t(fontSize: 12, color: _muted),
                ),
              ],
            ),
          ),
          _Chip(
            icon: isActive ? Icons.check_circle_rounded : Icons.schedule_rounded,
            label: isActive ? 'ACTIVE' : 'PENDING',
            color: isActive ? _green : _amber,
            background: isActive ? _greenTint : _amberTint,
          ),
        ],
      ),
    );
  }
}

class _ReasonCard extends StatelessWidget {
  const _ReasonCard({
    required this.distanceMeters,
    required this.reason,
    required this.onChanged,
  });

  final int distanceMeters;
  final String? reason;
  final ValueChanged<String?>? onChanged;

  static const _icons = <String, IconData>{
    'Field Work': Icons.assignment_rounded,
    'Work From Home': Icons.home_work_rounded,
    'Client Meeting': Icons.handshake_rounded,
    'Other': Icons.edit_note_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(
        color: const Color(0xFFFFFBF0),
        border: const Color(0xFFFDE68A),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reason Required',
                  style: _t(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                'Outside: ${_formatDistance(distanceMeters)}',
                style: _t(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: _red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Select why you are checking in from outside the office',
            style: _t(fontSize: 12, color: _muted),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.1,
            children: [
              for (final r in kMarkAttendanceReasons)
                _ReasonOption(
                  label: r,
                  icon: _icons[r] ?? Icons.label_rounded,
                  selected: reason == r,
                  onTap: onChanged == null ? null : () => onChanged!(r),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReasonOption extends StatelessWidget {
  const _ReasonOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PortalColors.brand : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? PortalColors.brand : _border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? Colors.white : PortalColors.brandLight,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : PortalColors.heading,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionArea extends StatelessWidget {
  const _ActionArea({required this.button, required this.hint});

  final Widget button;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        button,
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 13,
              color: PortalColors.secondaryText,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                hint,
                textAlign: TextAlign.center,
                style: _t(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: PortalColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.loading,
    required this.onTap,
    this.badge,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final active = enabled || loading;
    final colors = active
        ? PortalColors.brandGradient
        : const [Color(0xFFC8C4D4), Color(0xFFB8B3C4)];

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled && !loading ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: colors),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: PortalColors.brand.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 17),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: _t(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge!,
                          style: _t(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PortalColors.brand.withValues(alpha: 0.1),
            PortalColors.brandLight.withValues(alpha: 0.18),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: PortalColors.brand, size: 21),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: _t(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.background = PortalColors.brandTint,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final color = onTap == null ? _muted : PortalColors.brand;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: _t(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
