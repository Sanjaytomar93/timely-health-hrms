import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/features/letters/presentation/bloc/letters_cubit.dart';
import 'package:timelay_health/features/letters/presentation/bloc/letters_state.dart';
import 'package:timelay_health/features/letters/presentation/models/employee_letter.dart';
import 'package:timelay_health/features/letters/presentation/screens/letter_viewer_screen.dart';
import 'package:timelay_health/features/letters/presentation/utils/letter_download.dart';
import 'package:timelay_health/features/letters/presentation/widgets/resignation_form_sheet.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';

extension _LetterTypeStyle on LetterType {
  IconData get icon => switch (this) {
    LetterType.experience => Icons.workspace_premium_outlined,
    LetterType.relieving => Icons.event_note_outlined,
    LetterType.resignation => Icons.exit_to_app_rounded,
  };

  Color get color => switch (this) {
    LetterType.experience => PortalColors.green,
    LetterType.relieving => PortalColors.orange,
    LetterType.resignation => PortalColors.red,
  };

  Color get tint => switch (this) {
    LetterType.experience => PortalColors.greenTint,
    LetterType.relieving => PortalColors.orangeTint,
    LetterType.resignation => PortalColors.redTint,
  };
}

class MyLettersScreen extends StatelessWidget {
  const MyLettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LettersCubit()..load(),
      child: const _MyLettersView(),
    );
  }
}

class _MyLettersView extends StatefulWidget {
  const _MyLettersView();

  @override
  State<_MyLettersView> createState() => _MyLettersViewState();
}

class _MyLettersViewState extends State<_MyLettersView> {
  Employee? _employee;
  LetterType _type = LetterType.experience;

  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  Future<void> _loadEmployee() async {
    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    if (!mounted) return;
    setState(() => _employee = employee);
  }

  Future<void> _refresh() =>
      context.read<LettersCubit>().load(keepExisting: true);

  Future<void> _openResignationForm() async {
    final employeeId = _employee?.employeeId.trim() ?? '';
    if (employeeId.isEmpty) return;
    final hasPending = context.read<LettersCubit>().state.letters.any(
      (l) =>
          l.type == LetterType.resignation &&
          l.status.toLowerCase() == 'pending',
    );
    if (hasPending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You already have a pending resignation request. '
            'Please wait for HR/Admin to review it.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final submitted = await showResignationFormSheet(
      context,
      employeeId: employeeId,
    );
    if (!submitted || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resignation request submitted successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LettersCubit>().state;
    final letters = state.letters;
    List<EmployeeLetter> ofType(LetterType type) =>
        letters.where((l) => l.type == type).toList();
    final visible = ofType(_type);
    final allSent = letters.isNotEmpty && letters.every((l) => l.isSent);
    final isLoading =
        (state is LettersLoading || state is LettersInitial) && letters.isEmpty;
    final error = state is LettersFailureState ? state.message : null;

    return Scaffold(
      backgroundColor: PortalColors.background,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            const _LettersAppBar(),
            Expanded(
              child: RefreshIndicator(
                color: PortalColors.purple,
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    _LettersHeader(employee: _employee),
                    const _LettersBanner(),
                    _LetterStatsRow(
                      total: letters.length,
                      countOf: (t) => ofType(t).length,
                      allSent: allSent,
                      selected: _type,
                      onSelect: (t) => setState(() => _type = t),
                    ),
                    _LettersListCard(
                      type: _type,
                      letters: visible,
                      isLoading: isLoading,
                      error: error,
                      onRetry: _refresh,
                      onTypeChanged: (t) => setState(() => _type = t),
                      refreshing: state is LettersLoading,
                      onSubmitResignation: _openResignationForm,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LettersAppBar extends StatelessWidget {
  const _LettersAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PortalColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: [
          const PortalBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'My Letters',
              style: portalText(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: PortalColors.heading,
                letterSpacing: 0.2,
                height: 1.2,
              ),
            ),
          ),
          const TopNotificationButton(
            asset: 'assets/icons/payslips/ic_notification.svg',
          ),
          const SizedBox(width: 14),
          const TopCalendarButton(
            asset: 'assets/icons/payslips/ic_notification_cal.svg',
          ),
        ],
      ),
    );
  }
}

class _LettersHeader extends StatelessWidget {
  const _LettersHeader({this.employee});

  final Employee? employee;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: employee == null
                      ? const SizedBox.shrink()
                      : _Chip(
                          icon: Icons.person_rounded,
                          label: employee!.displayName,
                          trailing: employee!.employeeId,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              _Chip(icon: Icons.calendar_today_outlined, label: _todayLabel()),
            ],
          ),
        ],
      ),
    );
  }

  static String _todayLabel() {
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
    final d = DateTime.now();
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, this.trailing});

  final IconData icon;
  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: PortalColors.purple),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: PortalColors.heading,
                height: 14 / 11.5,
              ),
            ),
          ),
          if (trailing != null && trailing!.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              '· $trailing',
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: PortalColors.muted,
                height: 14 / 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LettersBanner extends StatelessWidget {
  const _LettersBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(17, 16, 18, 0),
      padding: const EdgeInsets.all(18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment(-0.92, -0.4),
          end: Alignment(0.92, 0.4),
          colors: PortalColors.brandGradient,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -48,
            top: -58,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OFFICIAL DOCUMENTS',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 1,
                        height: 12 / 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Experience, Relieving & Resignation',
                      style: portalText(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 19 / 15.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Letters sent by HR appear here. Open any letter to view details or download a copy.',
                      style: portalText(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 16 / 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/menu/ic_letters.svg',
                  width: 26,
                  height: 26,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
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

class _LetterStatsRow extends StatelessWidget {
  const _LetterStatsRow({
    required this.total,
    required this.countOf,
    required this.allSent,
    required this.selected,
    required this.onSelect,
  });

  final int total;
  final int Function(LetterType) countOf;
  final bool allSent;
  final LetterType selected;
  final ValueChanged<LetterType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.fromLTRB(17, 4, 18, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatCard(
              label: 'TOTAL LETTERS',
              value: '$total',
              subtitle: 'in your inbox',
              icon: Icons.inbox_outlined,
              tint: const Color(0xFFEAF1FD),
              iconColor: const Color(0xFF3B6FE0),
            ),
            for (final type in LetterType.values) ...[
              const SizedBox(width: 8),
              _StatCard(
                label: type.label.toUpperCase(),
                value: '${countOf(type)}',
                subtitle: selected == type ? 'viewing now' : 'tap to view',
                icon: type.icon,
                tint: type.tint,
                iconColor: type.color,
                selected: selected == type,
                onTap: () => onSelect(type),
              ),
            ],
            const SizedBox(width: 8),
            _StatCard(
              label: 'STATUS',
              value: allSent ? 'Sent' : '—',
              subtitle: 'official letters',
              icon: Icons.send_outlined,
              tint: PortalColors.greenTint,
              iconColor: PortalColors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.iconColor,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final Color iconColor;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 133,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? tint : PortalColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? iconColor : PortalColors.border,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: selected ? iconColor : tint,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 15,
                color: selected ? Colors.white : iconColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: portalText(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: PortalColors.muted,
                letterSpacing: 0.4,
                height: 11 / 9.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: portalText(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: value == '—' ? PortalColors.muted : iconColor,
                height: 24 / 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 9.5,
                color: PortalColors.muted,
                height: 11 / 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LettersListCard extends StatelessWidget {
  const _LettersListCard({
    required this.type,
    required this.letters,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onTypeChanged,
    required this.refreshing,
    required this.onSubmitResignation,
  });

  final bool refreshing;
  final VoidCallback onSubmitResignation;
  final LetterType type;
  final List<EmployeeLetter> letters;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<LetterType> onTypeChanged;

  Widget _content() {
    if (isLoading) {
      return const Padding(
        key: ValueKey('loading'),
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(color: PortalColors.purple),
        ),
      );
    }
    if (letters.isEmpty && error != null) {
      return _LettersError(
        key: const ValueKey('error'),
        message: error!,
        onRetry: onRetry,
      );
    }
    if (letters.isEmpty) {
      return _EmptyLetters(key: ValueKey('empty-$type'), type: type);
    }
    return Column(
      key: ValueKey('list-$type'),
      children: [
        for (var i = 0; i < letters.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _LetterCard(letter: letters[i]),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final noun = '${type.label.toLowerCase()} letter';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 18, 0),
      padding: const EdgeInsets.all(16),
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
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: type.tint,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(type.icon, size: 14, color: type.color),
              ),
              const SizedBox(width: 8),
              Text(
                '${type.label} Letters',
                style: portalText(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                  height: 16 / 13.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'View and download your official company letters.',
            style: portalText(
              fontSize: 10.5,
              color: PortalColors.muted,
              height: 13 / 10.5,
            ),
          ),
          const SizedBox(height: 12),
          _TypeToggle(selected: type, onChanged: onTypeChanged),
          if (type == LetterType.resignation) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                _RefreshPill(refreshing: refreshing, onTap: onRetry),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: onSubmitResignation,
                  style: FilledButton.styleFrom(
                    backgroundColor: PortalColors.brandLight,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 14),
                  label: Text(
                    'Submit Resignation',
                    style: portalText(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _content(),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: PortalColors.border),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: portalText(
                      fontSize: 10.5,
                      color: PortalColors.muted,
                    ),
                    children: [
                      const TextSpan(text: 'Showing '),
                      TextSpan(
                        text: '${letters.length}',
                        style: portalText(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: PortalColors.heading,
                        ),
                      ),
                      TextSpan(text: ' $noun${letters.length == 1 ? '' : 's'}'),
                    ],
                  ),
                ),
              ),
              if (letters.isNotEmpty && letters.every((l) => l.isSent))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: PortalColors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'All verified & sent',
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.green,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.selected, required this.onChanged});

  final LetterType selected;
  final ValueChanged<LetterType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          for (final type in LetterType.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(type),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  height: 38,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    gradient: selected == type
                        ? const LinearGradient(
                            colors: PortalColors.brandGradient,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: selected == type
                        ? [
                            BoxShadow(
                              color: PortalColors.brand.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type.icon,
                          size: 14,
                          color: selected == type ? Colors.white : type.color,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          type.label,
                          style: portalText(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: selected == type
                                ? Colors.white
                                : PortalColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  const _LetterCard({required this.letter});

  final EmployeeLetter letter;

  @override
  Widget build(BuildContext context) {
    final initial = letter.employeeName.trim().isEmpty
        ? 'E'
        : letter.employeeName.trim()[0].toUpperCase();
    final isResignation = letter.type == LetterType.resignation;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: letter.type.tint,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Icon(
                  letter.type.icon,
                  size: 18,
                  color: letter.type.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${letter.type.label} Letter',
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                        height: 16 / 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isResignation
                          ? 'Submitted on ${letter.sentOnDate}'
                          : 'Sent ${letter.sentOnDate} · ${letter.sentOnTime}',
                      style: portalText(
                        fontSize: 10,
                        color: PortalColors.muted,
                        height: 12 / 10,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(status: letter.status),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: PortalColors.background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: PortalColors.purpleTint,
                      child: Text(
                        initial,
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: PortalColors.purple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            letter.employeeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.heading,
                            ),
                          ),
                          Text(
                            letter.employeeId,
                            style: portalText(
                              fontSize: 9.5,
                              color: PortalColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF1FD),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        letter.designation.toUpperCase(),
                        style: portalText(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3B6FE0),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.date_range_outlined,
                      size: 13,
                      color: PortalColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isResignation
                          ? 'Joining → Last day'
                          : 'Employment period',
                      style: portalText(
                        fontSize: 10,
                        color: PortalColors.muted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      letter.periodLabel,
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isResignation) ...[
            const SizedBox(height: 12),
            _ResignationDetails(letter: letter),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'View',
                    icon: Icons.visibility_outlined,
                    background: PortalColors.brand,
                    foreground: Colors.white,
                    onTap: () => LetterViewerScreen.open(context, letter),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: 'Download',
                    icon: Icons.download_rounded,
                    background: PortalColors.purpleTint,
                    foreground: PortalColors.purple,
                    onTap: () => downloadEmployeeLetter(context, letter),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatefulWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  State<_StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<_StatusPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (color, tint) = _statusColors(widget.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 0.2, end: 1).animate(_blink),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            widget.status.toUpperCase(),
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

(Color, Color) _statusColors(String status) => switch (status.toLowerCase()) {
  'pending' => (PortalColors.orange, PortalColors.orangeTint),
  'rejected' => (PortalColors.red, PortalColors.redTint),
  _ => (PortalColors.green, PortalColors.greenTint),
};

class _RefreshPill extends StatefulWidget {
  const _RefreshPill({required this.refreshing, required this.onTap});

  final bool refreshing;
  final VoidCallback onTap;

  @override
  State<_RefreshPill> createState() => _RefreshPillState();
}

class _RefreshPillState extends State<_RefreshPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.refreshing) _spin.repeat();
  }

  @override
  void didUpdateWidget(covariant _RefreshPill old) {
    super.didUpdateWidget(old);
    if (widget.refreshing && !_spin.isAnimating) {
      _spin.repeat();
    } else if (!widget.refreshing && _spin.isAnimating) {
      _spin
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PortalColors.surface,
      shape: const StadiumBorder(side: BorderSide(color: PortalColors.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: widget.refreshing ? null : widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _spin,
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 17,
                  color: resignationAccent,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Refresh',
                style: portalText(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResignationDetails extends StatelessWidget {
  const _ResignationDetails({required this.letter});

  final EmployeeLetter letter;

  @override
  Widget build(BuildContext context) {
    final fields = <String, String>{
      for (final line in letter.details.split('\n'))
        if (line.contains(': '))
          line.substring(0, line.indexOf(': ')): line.substring(
            line.indexOf(': ') + 2,
          ),
    };
    final status = letter.status.toLowerCase();
    final (color, tint) = _statusColors(status);
    final (icon, title, subtitle) = switch (status) {
      'approved' => (
        Icons.verified_rounded,
        'Resignation Approved',
        fields['Approved by'] == null
            ? 'Your resignation has been accepted.'
            : 'Approved by ${fields['Approved by']}',
      ),
      'rejected' => (
        Icons.cancel_rounded,
        'Resignation Rejected',
        fields['Rejected reason'] ?? 'Your resignation was not accepted.',
      ),
      _ => (
        Icons.hourglass_top_rounded,
        'Awaiting Approval',
        'Your request is under review by HR.',
      ),
    };
    final tiles = [
      if (fields['Category'] != null)
        (Icons.local_offer_outlined, 'Category', fields['Category']!),
      if (fields['Notice period'] != null)
        (Icons.timelapse_rounded, 'Notice', fields['Notice period']!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [tint, tint.withValues(alpha: 0.35)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: portalText(
                        fontSize: 10.5,
                        color: PortalColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (tiles.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _InfoTile(data: tiles[i])),
              ],
            ],
          ),
        ],
        if (fields['Reason'] != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: PortalColors.background,
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(color: PortalColors.purple, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.format_quote_rounded,
                      size: 16,
                      color: PortalColors.purple,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'REASON',
                      style: portalText(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: PortalColors.purple,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  fields['Reason']!,
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PortalColors.heading,
                    height: 1.45,
                  ),
                ),
                if (fields['Comments'] != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '“${fields['Comments']}”',
                    style: portalText(
                      fontSize: 11,
                      color: PortalColors.muted,
                      height: 1.4,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (fields['Admin remark'] != null) ...[
          const SizedBox(height: 10),
          _InfoTile(
            data: (
              Icons.admin_panel_settings_outlined,
              'Admin remark',
              fields['Admin remark']!,
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.data});

  final (IconData, String, String) data;

  @override
  Widget build(BuildContext context) {
    final (icon, label, value) = data;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: PortalColors.purpleTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: PortalColors.purple),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: portalText(fontSize: 9.5, color: PortalColors.muted),
                ),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 36,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: foreground),
              const SizedBox(width: 6),
              Text(
                label,
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LettersError extends StatelessWidget {
  const _LettersError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 32,
            color: PortalColors.muted,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 11.5,
              color: PortalColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: PortalColors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLetters extends StatelessWidget {
  const _EmptyLetters({super.key, required this.type});

  final LetterType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: PortalColors.purpleTint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/menu/ic_letters.svg',
              width: 28,
              height: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No ${type.label.toLowerCase()} letter yet',
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your letter will appear here once HR sends it.',
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 11,
              color: PortalColors.muted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
