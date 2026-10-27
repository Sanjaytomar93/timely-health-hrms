import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/shift_cubit.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/shift_state.dart';
import 'package:timelay_health/features/attendance/presentation/models/shift_ui_model.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:timelay_health/features/profile/presentation/bloc/profile_state.dart';
import 'package:timelay_health/features/roster/presentation/bloc/week_off_cubit.dart';
import 'package:timelay_health/features/roster/presentation/bloc/week_off_state.dart';
import 'package:timelay_health/features/roster/presentation/models/week_off_ui_model.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _offGreen = Color(0xFF0F9D6B);
const _offTint = Color(0xFFE8F8F1);
const _offBorder = Color(0xFFBDEBD6);
const _violet = Color(0xFF7C3AED);
const _violetTint = Color(0xFFF5F0FF);

class WorkRosterScreen extends StatelessWidget {
  const WorkRosterScreen({super.key});

  static Future<void> open(BuildContext context) {
    return AppRoutes.push(context, AppRoutes.workRoster);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProfileCubit()..load(showFullScreenLoader: false),
        ),
        BlocProvider(create: (_) => ShiftCubit()..load()),
        BlocProvider(create: (_) => WeekOffCubit()..load()),
      ],
      child: const _WorkRosterView(),
    );
  }
}

class _WorkRosterView extends StatelessWidget {
  const _WorkRosterView();

  Future<void> _refresh(BuildContext context) async {
    await Future.wait([
      context.read<ProfileCubit>().load(showFullScreenLoader: false),
      context.read<ShiftCubit>().load(keepExisting: true),
      context.read<WeekOffCubit>().load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortalColors.background,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            _RosterAppBar(onRefresh: () => _refresh(context)),
            Expanded(
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, profileState) {
                  final employee = context.read<ProfileCubit>().currentEmployee;
                  if (employee == null) {
                    if (profileState is ProfileFailure) {
                      return _ErrorView(
                        message: profileState.message,
                        onRetry: () => _refresh(context),
                      );
                    }
                    return const ShimmerCardList(scrollable: true);
                  }

                  final weekOffState = context.watch<WeekOffCubit>().state;
                  final month = weekOffState.month;
                  final weekOff =
                      weekOffState.weekOff ?? WeekOffUiModel.loading;
                  final loading =
                      weekOffState is WeekOffLoading ||
                      weekOffState is WeekOffInitial;
                  final weekOffCubit = context.read<WeekOffCubit>();

                  return RefreshIndicator(
                    color: PortalColors.brand,
                    onRefresh: () => _refresh(context),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                      children: [
                        _ProfileHero(employee: employee),
                        const SizedBox(height: 12),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: BlocBuilder<ShiftCubit, ShiftState>(
                                  builder: (context, s) => _ShiftCard(
                                    shift: s.shift,
                                    loading:
                                        s is ShiftLoading || s is ShiftInitial,
                                    shiftHours: employee.info.shiftHours,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _WeekOffCard(
                                  weekOff: weekOff,
                                  loading: loading,
                                  month: month,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _CalendarCard(
                          month: month,
                          weekOff: weekOff,
                          loading: loading,
                          onPrev: () => weekOffCubit.shiftMonth(-1),
                          onNext: () => weekOffCubit.shiftMonth(1),
                        ),
                        const SizedBox(height: 12),
                        _OffDaysSummary(
                          month: month,
                          weekOff: weekOff,
                          loading: loading,
                          fromProfile: weekOffState is WeekOffFailureState,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RosterAppBar extends StatelessWidget {
  const _RosterAppBar({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        color: PortalColors.surface,
        border: Border(bottom: BorderSide(color: PortalColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: [
          const PortalBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Work Roster & Schedule',
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your shift timings & week-off calendar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10.5,
                    color: PortalColors.muted,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRefresh,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: PortalColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PortalColors.border),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: PortalColors.brand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final e = employee;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF26204A), Color(0xFF4B4285)],
        ),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      e.initials,
                      style: portalText(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: e.isActive
                            ? const Color(0xFF34D399)
                            : PortalColors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF332B63),
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.role.isEmpty ? '—' : e.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _HeroChip(label: e.performanceCode),
                        const SizedBox(width: 6),
                        _HeroChip(
                          label: e.isActive ? 'Active' : e.statusLabel,
                          dot: e.isActive
                              ? const Color(0xFF34D399)
                              : PortalColors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _HeroInfo(
                        icon: Icons.apartment_rounded,
                        label: 'Department',
                        value: e.department,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    Expanded(
                      child: _HeroInfo(
                        icon: Icons.call_rounded,
                        label: 'Contact',
                        value: e.phone ?? '',
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                _HeroInfo(
                  icon: Icons.mail_rounded,
                  label: 'Email',
                  value: e.email,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label, this.dot});

  final String label;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroInfo extends StatelessWidget {
  const _HeroInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: portalText(
                  fontSize: 9.5,
                  color: Colors.white.withValues(alpha: 0.6),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.trim().isEmpty ? '—' : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.tint,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final Color tint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: portalText(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.muted,
                    letterSpacing: 0.6,
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 14, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({
    required this.shift,
    required this.loading,
    required this.shiftHours,
  });

  final ShiftUiModel? shift;
  final bool loading;
  final num? shiftHours;

  String get _timing {
    final s = shift!;
    final range = s.timeRange.trim();
    if (range.isNotEmpty) return range.replaceAll(' - ', ' – ');
    if (s.startTime != '—' && s.endTime != '—') {
      return '${s.startTime} – ${s.endTime}';
    }
    return '—';
  }

  String get _category {
    final cat = shift!.category.trim();
    final base = cat.isEmpty ? 'Regular' : cat;
    if (shiftHours == null) return base;
    final h = shiftHours! % 1 == 0
        ? shiftHours!.toInt().toString()
        : shiftHours!.toString();
    return '$base (${h}h)';
  }

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'WORK SHIFT',
      icon: Icons.schedule_rounded,
      accent: _offGreen,
      tint: _offTint,
      child: shift == null
          ? Center(
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _offGreen,
                      ),
                    )
                  : Text(
                      'No shift assigned',
                      textAlign: TextAlign.center,
                      style: portalText(
                        fontSize: 11,
                        color: PortalColors.muted,
                      ),
                    ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _offGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        shift!.type == '—'
                            ? 'S'
                            : shift!.type.substring(0, 1).toUpperCase(),
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        shift!.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: PortalColors.heading,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _offTint,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _offBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Working Timing',
                        style: portalText(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _offGreen,
                        ),
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _timing,
                          style: portalText(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.heading,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 8),
                _CardFooter(label: 'Category', value: _category),
              ],
            ),
    );
  }
}

class _WeekOffCard extends StatelessWidget {
  const _WeekOffCard({
    required this.weekOff,
    required this.loading,
    required this.month,
  });

  final WeekOffUiModel weekOff;
  final bool loading;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'WEEK-OFF POLICY',
      icon: Icons.event_available_rounded,
      accent: _violet,
      tint: _violetTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FD),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              weekOff.pattern,
              style: portalText(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3B6FE0),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _violetTint,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4D8FD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configured Days',
                  style: portalText(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _violet,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  weekOff.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4C1D95),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const SizedBox(height: 8),
          _CardFooter(
            label: 'Off in ${_monthNames[month.month - 1].substring(0, 3)}',
            value: loading && weekOff.offDays.isEmpty
                ? '…'
                : weekOff.countLabel,
            valueColor: _offGreen,
          ),
        ],
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({
    required this.label,
    required this.value,
    this.valueColor = PortalColors.heading,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: PortalColors.border)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: portalText(fontSize: 10, color: PortalColors.muted),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.month,
    required this.weekOff,
    required this.loading,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final WeekOffUiModel weekOff;
  final bool loading;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static const _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: PortalColors.brandGradient,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 17,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule Calendar',
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Roster & week-off days',
                      style: portalText(
                        fontSize: 10.5,
                        color: PortalColors.muted,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: PortalColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PortalColors.border),
            ),
            child: Row(
              children: [
                _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      '${_monthNames[month.month - 1]} ${month.year}',
                      key: ValueKey(month),
                      textAlign: TextAlign.center,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                      ),
                    ),
                  ),
                ),
                _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
              ],
            ),
          ),
          SizedBox(
            height: 12,
            child: loading
                ? const Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        color: _offGreen,
                        backgroundColor: _offTint,
                      ),
                    ),
                  )
                : null,
          ),
          Row(
            children: [
              _LegendDot(
                color: _offGreen,
                label: 'Week Off (${weekOff.count})',
              ),
              const SizedBox(width: 14),
              const _LegendDot(color: Color(0xFFD9D7E3), label: 'Working'),
              const SizedBox(width: 14),
              const _LegendDot(
                color: PortalColors.brand,
                label: 'Today',
                ring: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Text(
                    _weekdays[i],
                    textAlign: TextAlign.center,
                    style: portalText(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: i == 0
                          ? PortalColors.red
                          : i == 6
                          ? _violet
                          : PortalColors.muted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _MonthGrid(
              key: ValueKey(month),
              month: month,
              weekOff: weekOff,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: PortalColors.surface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: PortalColors.border),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: PortalColors.heading),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    this.ring = false,
  });

  final Color color;
  final String label;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: ring ? Colors.transparent : color,
            shape: BoxShape.circle,
            border: ring ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: portalText(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: PortalColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({super.key, required this.month, required this.weekOff});

  final DateTime month;
  final WeekOffUiModel weekOff;

  @override
  Widget build(BuildContext context) {
    final leading = DateTime(month.year, month.month, 1).weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final rows = ((leading + daysInMonth) / 7).ceil();
    final now = DateTime.now();

    return Column(
      children: [
        for (var r = 0; r < rows; r++)
          Padding(
            padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : 6),
            child: Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: Builder(
                        builder: (_) {
                          final day = r * 7 + c - leading + 1;
                          if (day < 1 || day > daysInMonth) {
                            return const AspectRatio(
                              aspectRatio: 0.82,
                              child: SizedBox.shrink(),
                            );
                          }
                          final date = DateTime(month.year, month.month, day);
                          return _DayCell(
                            day: day,
                            isOff: weekOff.isOff(date),
                            isToday:
                                date.year == now.year &&
                                date.month == now.month &&
                                date.day == now.day,
                            isSunday: c == 0,
                          );
                        },
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

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isOff,
    required this.isToday,
    required this.isSunday,
  });

  final int day;
  final bool isOff;
  final bool isToday;
  final bool isSunday;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    final Color text;
    if (isToday) {
      bg = PortalColors.brand;
      border = PortalColors.brand;
      text = Colors.white;
    } else if (isOff) {
      bg = _offTint;
      border = _offBorder;
      text = _offGreen;
    } else {
      bg = PortalColors.background;
      border = Colors.transparent;
      text = isSunday ? PortalColors.red : PortalColors.heading;
    }

    return AspectRatio(
      aspectRatio: 0.82,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
          boxShadow: isToday
              ? [
                  BoxShadow(
                    color: PortalColors.brand.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: portalText(
                fontSize: 12.5,
                fontWeight: isOff || isToday
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: text,
                height: 1.1,
              ),
            ),
            if (isOff) ...[
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isToday ? Colors.white : _offGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'OFF',
                  style: portalText(
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    color: isToday ? PortalColors.brand : Colors.white,
                    letterSpacing: 0.3,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OffDaysSummary extends StatelessWidget {
  const _OffDaysSummary({
    required this.month,
    required this.weekOff,
    required this.loading,
    required this.fromProfile,
  });

  final DateTime month;
  final WeekOffUiModel weekOff;
  final bool loading;
  final bool fromProfile;

  List<DateTime> get offDays => weekOff.offDays;

  static const _shortWeekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final monthLabel = '${_monthNames[month.month - 1]} ${month.year}';
    final shortMonth = _monthNames[month.month - 1].substring(0, 3);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _offTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _offBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 17,
                color: _offGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Week-offs in $monthLabel: ',
                    children: [
                      TextSpan(
                        text: loading && offDays.isEmpty
                            ? '…'
                            : weekOff.countLabel,
                        style: portalText(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: _offGreen,
                        ),
                      ),
                    ],
                  ),
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (fromProfile) ...[
            Text(
              'Could not load from server, showing your profile week-off.',
              style: portalText(fontSize: 10.5, color: PortalColors.orange),
            ),
            const SizedBox(height: 8),
          ],
          if (offDays.isEmpty)
            Text(
              loading
                  ? 'Loading week-offs…'
                  : 'No week-off configured for this month.',
              style: portalText(fontSize: 11, color: PortalColors.muted),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final d in offDays)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: PortalColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _offBorder),
                    ),
                    child: Text.rich(
                      TextSpan(
                        text:
                            '${d.day.toString().padLeft(2, '0')} $shortMonth ',
                        children: [
                          TextSpan(
                            text: _shortWeekdays[d.weekday - 1],
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _offGreen,
                            ),
                          ),
                        ],
                      ),
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 36,
              color: PortalColors.muted,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: portalText(fontSize: 12, color: PortalColors.muted),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.brand,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
