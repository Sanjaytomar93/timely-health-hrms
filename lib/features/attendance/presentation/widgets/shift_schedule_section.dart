import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/presentation/models/shift_ui_model.dart';

class ShiftScheduleSection extends StatelessWidget {
  const ShiftScheduleSection({super.key, required this.shifts});

  final List<ShiftUiModel> shifts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(11, 22, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🗓 Shift Schedule',
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000),
              height: 16 / 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            shifts.isEmpty
                ? 'No shift assigned yet.'
                : 'Current assignment and scheduled changes',
            style: portalText(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: PortalColors.muted,
              height: 15 / 12.5,
            ),
          ),
          const SizedBox(height: 14),
          if (shifts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PortalColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PortalColors.border),
              ),
              child: Text(
                'Your assigned shift will appear here.',
                textAlign: TextAlign.center,
                style: portalText(fontSize: 12, color: PortalColors.muted),
              ),
            )
          else
            for (var i = 0; i < shifts.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _ShiftCard(data: shifts[i]),
            ],
        ],
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({required this.data});

  final ShiftUiModel data;

  @override
  Widget build(BuildContext context) {
    final badgeBg = data.isActive
        ? PortalColors.greenTint
        : PortalColors.redTint;
    final badgeFg = data.isActive ? PortalColors.green : PortalColors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusBadge(
                label: data.leftBadge,
                background: badgeBg,
                foreground: badgeFg,
              ),
              const Spacer(),
              _StatusBadge(
                label: data.rightBadge,
                background: badgeBg,
                foreground: badgeFg,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.title,
            style: portalText(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
              height: 15 / 12.5,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: PortalColors.muted,
                height: 13 / 11,
              ),
              children: [
                const TextSpan(text: 'Type: '),
                TextSpan(
                  text: data.type,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: '   Effective from: '),
                TextSpan(
                  text: data.effectiveFrom,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEFEDF5)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimeBlock(
                  time: data.startTime,
                  label: 'Start',
                  align: CrossAxisAlignment.start,
                ),
              ),
              const _TimeArrow(),
              Expanded(
                child: _TimeBlock(
                  time: data.endTime,
                  label: 'Ends',
                  align: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 17,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: foreground,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: foreground,
              height: 11 / 9.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.time,
    required this.label,
    required this.align,
  });

  final String time;
  final String label;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          time,
          style: portalText(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: PortalColors.heading,
            height: 15 / 12.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: portalText(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: PortalColors.muted,
            height: 13 / 11,
          ),
        ),
      ],
    );
  }
}

class _TimeArrow extends StatelessWidget {
  const _TimeArrow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Row(
        children: [
          Expanded(
            child: Container(height: 1.5, color: const Color(0xFFA9A7BB)),
          ),
          const Icon(Icons.arrow_forward, size: 14, color: Color(0xFFA9A7BB)),
        ],
      ),
    );
  }
}
