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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TopBar(
          title: isCheckout ? 'Check Out' : 'Check In',
          closeAsset: widget.closeAsset,
          onClose: widget.onClose,
        ),
        const SizedBox(height: 14),
        _LivePill(now: data.now),
        const SizedBox(height: 18),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEDEAF5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B4A9A).withValues(alpha: 0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LocationHeader(
                    captured: captured,
                    onChange: busy ? null : widget.onGetLocation,
                  ),
                  const SizedBox(height: 14),
                  _OfficeCard(
                    building: widget.building,
                    officeName: data.officeName,
                    radiusMeters: data.officeRadiusMeters,
                    distanceMeters: data.distanceMeters,
                    showDistance: captured,
                    outside: outside,
                  ),
                  const SizedBox(height: 12),
                  if (!captured)
                    _InfoBanner(
                      pinRed: widget.pinRed,
                      text: "Click 'Get Location' to capture",
                    )
                  else ...[
                    _DistanceBlock(
                      distanceMeters: data.distanceMeters,
                      outside: outside,
                    ),
                    const SizedBox(height: 12),
                    _InfoBanner(
                      pinRed: widget.pinRed,
                      text: 'Location captured automatically',
                    ),
                  ],
                  const SizedBox(height: 20),
                  _AttendanceStatusRow(isActive: isCheckout),
                  if (captured && outside && !isCheckout) ...[
                    const SizedBox(height: 16),
                    _ReasonCard(
                      distanceMeters: data.distanceMeters,
                      reason: _reason,
                      onChanged: (v) => setState(() => _reason = v),
                    ),
                  ],
                  const SizedBox(height: 22),
                  if (!captured) ...[
                    _PrimaryButton(
                      label: 'Get Location',
                      icon: Icons.location_on_rounded,
                      enabled: !busy,
                      loading: widget.capturing,
                      gradient: PortalColors.brandGradient,
                      onTap: widget.onGetLocation,
                    ),
                    const SizedBox(height: 10),
                    _PrimaryButton(
                      label: 'Get Location First',
                      icon: Icons.location_on_outlined,
                      enabled: false,
                      loading: false,
                      gradient: const [Color(0xFFC8C4D4), Color(0xFFB8B3C4)],
                      onTap: () {},
                    ),
                  ] else ...[
                    if (data.requirePhoto)
                      _PhotoCheckInButton(
                        isCheckout: isCheckout,
                        enabled:
                            !busy &&
                            (isCheckout || !outside || _reason != null),
                        loading: widget.submitting,
                        onTap: () => widget.onCheckIn(
                          outside && !isCheckout ? _reason : null,
                        ),
                      )
                    else
                      _PrimaryButton(
                        label: isCheckout ? 'Check Out' : 'Check In',
                        icon: isCheckout
                            ? Icons.logout_rounded
                            : Icons.login_rounded,
                        enabled:
                            !busy &&
                            (isCheckout || !outside || _reason != null),
                        loading: widget.submitting,
                        gradient: PortalColors.brandGradient,
                        onTap: () => widget.onCheckIn(
                          outside && !isCheckout ? _reason : null,
                        ),
                      ),
                  ],
                  const SizedBox(height: 14),
                  _FooterHint(
                    text: !captured
                        ? 'Click above to check in'
                        : (data.requirePhoto
                              ? 'Click above to capture photo & check in'
                              : 'Click above to check in'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Powered by Timely Health HRMS',
          textAlign: TextAlign.center,
          style: _t(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF9B96AD),
            letterSpacing: 0.2,
          ),
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
}) {
  return GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.closeAsset,
    required this.onClose,
  });

  final String title;
  final String closeAsset;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: _t(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        Material(
          color: const Color(0xFFF0EEF6),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onClose,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: SvgPicture.asset(closeAsset, width: 18, height: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill({required this.now});
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final local = now.toLocal();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    final date =
        '${weekdays[local.weekday - 1]}, ${months[local.month - 1]} ${local.day}, ${local.year}';
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDF0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE8E4F2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'LIVE',
            style: _t(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF16A34A),
              letterSpacing: 0.4,
            ),
          ),
          _sep(),
          Flexible(
            child: Text(
              date,
              overflow: TextOverflow.ellipsis,
              style: _t(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B6680),
              ),
            ),
          ),
          _sep(),
          Text(
            time,
            style: _t(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF26204A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sep() => Container(
    width: 1,
    height: 11,
    margin: const EdgeInsets.symmetric(horizontal: 11),
    color: const Color(0xFFDDD8EC),
  );
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({required this.captured, required this.onChange});

  final bool captured;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEDF0),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: Color(0xFF26204A),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location',
                style: _t(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                captured
                    ? 'Auto-detected on capture'
                    : 'Get location to check in',
                style: _t(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9B96AD),
                ),
              ),
            ],
          ),
        ),
        Material(
          color: const Color(0xFFEEEDF0),
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            onTap: onChange,
            borderRadius: BorderRadius.circular(9),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              child: Text(
                'CHANGE',
                style: _t(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF26204A),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfficeCard extends StatelessWidget {
  const _OfficeCard({
    required this.building,
    required this.officeName,
    required this.radiusMeters,
    required this.distanceMeters,
    required this.showDistance,
    required this.outside,
  });

  final String building;
  final String officeName;
  final int radiusMeters;
  final int distanceMeters;
  final bool showDistance;
  final bool outside;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEAF5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(building, width: 16, height: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  officeName,
                  style: _t(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Radius: ${radiusMeters}m',
                  style: _t(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9B96AD),
                  ),
                ),
              ],
            ),
          ),
          if (showDistance)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: outside
                    ? const Color(0xFFFFF1F3)
                    : const Color(0xFFECFDF3),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${distanceMeters}m',
                style: _t(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: outside
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF16A34A),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.pinRed, required this.text});

  final String pinRed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDF0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          SvgPicture.asset(pinRed, width: 12, height: 12),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              text,
              style: _t(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF26204A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistanceBlock extends StatelessWidget {
  const _DistanceBlock({required this.distanceMeters, required this.outside});

  final int distanceMeters;
  final bool outside;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.signal_cellular_alt_rounded,
              size: 15,
              color: const Color(0xFF9B96AD).withValues(alpha: 0.85),
            ),
            const SizedBox(width: 8),
            Text(
              'Distance from office',
              style: _t(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B6680),
              ),
            ),
            const Spacer(),
            Text(
              '${distanceMeters}m',
              style: _t(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: outside
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: 1,
            minHeight: 6,
            backgroundColor: const Color(0xFFEDEAF5),
            color: outside ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
          ),
        ),
        if (outside) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Outside office radius - Reason required',
                  style: _t(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFEA580C),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AttendanceStatusRow extends StatelessWidget {
  const _AttendanceStatusRow({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEDF0),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.event_available_rounded,
            color: Color(0xFF26204A),
            size: 20,
          ),
        ),
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
                style: _t(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9B96AD),
                ),
              ),
            ],
          ),
        ),
        if (isActive)
          Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF3),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ACTIVE',
                  style: _t(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF16A34A),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Text(
              'PENDING',
              style: _t(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD97706),
                letterSpacing: 0.3,
              ),
            ),
          ),
      ],
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
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 17,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              Text(
                'Reason Required',
                style: _t(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                'Outside: ${distanceMeters}m',
                style: _t(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFFEDEAF5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: reason,
                hint: Text(
                  '-- Select Reason --',
                  style: _t(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9B96AD),
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF9B96AD),
                ),
                items: [
                  for (final r in kMarkAttendanceReasons)
                    DropdownMenuItem(
                      value: r,
                      child: Text(
                        _emojiReason(r),
                        style: _t(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _emojiReason(String r) {
    return switch (r) {
      'Field Work' => '📋 Field Work',
      'Work From Home' => '🏠 Work From Home',
      'Client Meeting' => '🤝 Client Meeting',
      'Other' => '📝 Other',
      _ => r,
    };
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.loading,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final bool loading;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled && !loading ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: gradient,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: _t(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PhotoCheckInButton extends StatelessWidget {
  const _PhotoCheckInButton({
    required this.isCheckout,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  final bool isCheckout;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const gradient = PortalColors.brandGradient;

    return Material(
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled && !loading ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: gradient,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : Row(
                  children: [
                    const Icon(
                      Icons.photo_camera_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isCheckout
                            ? 'Check Out with Photo'
                            : 'Check In with Photo',
                        style: _t(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
                        'Auto-Capture',
                        style: _t(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
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

class _FooterHint extends StatelessWidget {
  const _FooterHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.arrow_forward_rounded,
          size: 13,
          color: const Color(0xFF26204A).withValues(alpha: 0.85),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: _t(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF26204A),
          ),
        ),
      ],
    );
  }
}
