import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/holidays/presentation/bloc/holidays_cubit.dart';
import 'package:timelay_health/features/holidays/presentation/bloc/holidays_state.dart';
import 'package:timelay_health/features/holidays/presentation/models/holiday_ui_model.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';

class HolidayCalendarScreen extends StatelessWidget {
  const HolidayCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HolidaysCubit()..load(),
      child: const _HolidayCalendarView(),
    );
  }
}

class _HolidayCalendarView extends StatefulWidget {
  const _HolidayCalendarView();

  @override
  State<_HolidayCalendarView> createState() => _HolidayCalendarViewState();
}

class _HolidayCalendarViewState extends State<_HolidayCalendarView> {
  final _search = TextEditingController();
  late int _month;
  late int _year;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    _selectedDay = now.day;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pickMonth(BuildContext context, DateTime? current) async {
    final cubit = context.read<HolidaysCubit>();
    final result = await showModalBottomSheet<_MonthPickResult>(
      context: context,
      backgroundColor: PortalColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _MonthPickerSheet(initial: current),
    );
    if (result == null || !mounted) return;
    cubit.setMonth(result.month);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month += delta;
      if (_month < 1) {
        _month = 12;
        _year -= 1;
      } else if (_month > 12) {
        _month = 1;
        _year += 1;
      }
      final daysInMonth = DateTime(_year, _month + 1, 0).day;
      if (_selectedDay > daysInMonth) _selectedDay = daysInMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortalColors.background,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            const _HolidayAppBar(),
            Expanded(
              child: BlocBuilder<HolidaysCubit, HolidaysState>(
                builder: (context, state) {
                  final loading =
                      state is HolidaysLoading && state.allHolidays.isEmpty;

                  if (loading) {
                    return const ShimmerCardList(scrollable: true);
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<HolidaysCubit>().load(keepExisting: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 32),
                      children: [
                        if (state is HolidaysFailureState &&
                            state.allHolidays.isEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                            child: Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: portalText(
                                fontSize: 12,
                                color: PortalColors.muted,
                              ),
                            ),
                          ),
                        _DateRow(
                          label: HolidayUiMapper.todayLabel(),
                          onRefresh: () => context.read<HolidaysCubit>().load(
                            keepExisting: true,
                          ),
                        ),
                        _StatCardsRow(stats: state.stats),
                        _CalendarCard(
                          month: _month,
                          year: _year,
                          selectedDay: _selectedDay,
                          holidays: state.allHolidays,
                          onPrev: () => _shiftMonth(-1),
                          onNext: () => _shiftMonth(1),
                          onSelectDay: (d) => setState(() => _selectedDay = d),
                        ),
                        _ByCategorySection(total: state.stats.total),
                        _SearchHolidaysCard(
                          search: _search,
                          month: state.month,
                          onMonthTap: () => _pickMonth(context, state.month),
                          onMonthClear: () =>
                              context.read<HolidaysCubit>().setMonth(null),
                          selectedChip: state.type,
                          foundCount: state.holidays.length,
                          onSearchChanged: (v) =>
                              context.read<HolidaysCubit>().setSearch(v),
                          onChip: (v) =>
                              context.read<HolidaysCubit>().setType(v),
                        ),
                        _HolidayListSection(items: state.holidays),
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

class _HolidayAppBar extends StatelessWidget {
  const _HolidayAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      color: PortalColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 2, 26, 0),
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
                  'Holiday Calendar',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    letterSpacing: 0.2,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Company holidays & observances',
                  style: portalText(
                    fontSize: 10,
                    color: PortalColors.muted,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const TopNotificationButton(
            asset: 'assets/icons/holiday/ic_notification.svg',
          ),
          const SizedBox(width: 12),
          const TopCalendarButton(
            asset: 'assets/icons/holiday/ic_notification_cal.svg',
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.label, required this.onRefresh});

  final String label;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 18, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 22,
            padding: const EdgeInsets.only(left: 12, right: 13),
            decoration: BoxDecoration(
              color: PortalColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PortalColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/holiday/ic_calendar_chip.svg',
                  width: 15,
                  height: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: PortalColors.secondaryText,
                    height: 13 / 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onRefresh,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 24,
              height: 22,
              decoration: BoxDecoration(
                color: PortalColors.purpleTint,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: PortalColors.border),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.autorenew_rounded,
                size: 15,
                color: PortalColors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({required this.stats});

  final HolidayStatsUiModel stats;

  @override
  Widget build(BuildContext context) {
    final year = stats.year == 0 ? DateTime.now().year : stats.year;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              iconBg: PortalColors.purpleTint,
              icon: Icons.calendar_today_rounded,
              iconColor: PortalColors.purple,
              label: 'TOTAL HOLIDAYS',
              value: '${stats.total}',
              subtitle: 'listed for $year',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              iconBg: PortalColors.greenTint,
              icon: Icons.autorenew_rounded,
              iconColor: PortalColors.green,
              label: 'UPCOMING',
              value: '${stats.upcoming}',
              subtitle: 'holidays ahead',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: iconColor),
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
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: PortalColors.green,
              height: 27 / 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: portalText(
              fontSize: 10,
              color: PortalColors.muted,
              height: 12 / 10,
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
    required this.year,
    required this.selectedDay,
    required this.holidays,
    required this.onPrev,
    required this.onNext,
    required this.onSelectDay,
  });

  final int month;
  final int year;
  final int selectedDay;
  final List<HolidayUiModel> holidays;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onSelectDay;

  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _legend = [
    (Color(0xFFEE7D3D), 'Festival'),
    (Color(0xFF1FA971), 'National Holiday'),
    (Color(0xFF26204A), 'Company Holiday'),
    (Color(0xFF8B6CE8), 'Observance'),
    (Color(0xFFE0499B), 'Restricted'),
    (Color(0xFFE0483E), 'Sunday'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 15, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _NavBtn(glyph: '‹', onTap: onPrev),
              Expanded(
                child: Text(
                  '${_monthNames[month - 1]} $year',
                  textAlign: TextAlign.center,
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 17 / 14,
                  ),
                ),
              ),
              _NavBtn(glyph: '›', onTap: onNext),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final d in _weekdays)
                Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: portalText(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.muted,
                      letterSpacing: 0.3,
                      height: 11 / 9,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _MonthGrid(
            month: month,
            year: year,
            selectedDay: selectedDay,
            holidays: holidays,
            onSelectDay: onSelectDay,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 13),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: PortalColors.border)),
            ),
            child: Wrap(
              spacing: 11,
              runSpacing: 7,
              children: [
                for (final item in _legend)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: item.$1,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item.$2,
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: PortalColors.secondaryText,
                          height: 12 / 10,
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

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.glyph, required this.onTap});

  final String glyph;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28,
        height: 28,
        padding: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
          color: PortalColors.background,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          glyph,
          style: portalText(
            fontSize: 16,
            color: PortalColors.muted,
            height: 19 / 16,
          ),
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.year,
    required this.selectedDay,
    required this.holidays,
    required this.onSelectDay,
  });

  final int month;
  final int year;
  final int selectedDay;
  final List<HolidayUiModel> holidays;
  final ValueChanged<int> onSelectDay;

  HolidayUiModel? _holidayForDay(int day) {
    for (final h in holidays) {
      final d = h.fromDate?.toLocal();
      if (d == null) continue;
      if (d.year == year && d.month == month && d.day == day) return h;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final leading = (first.weekday + 6) % 7;
    final prevDays = DateTime(year, month, 0).day;
    final total = leading + daysInMonth;
    final rows = (total / 7).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < rows; r++)
          Padding(
            padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: _buildCell(
                      r * 7 + c,
                      leading,
                      daysInMonth,
                      prevDays,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCell(int index, int leading, int daysInMonth, int prevDays) {
    if (index < leading) {
      final day = prevDays - leading + index + 1;
      return _DayCell(
        label: '$day',
        color: const Color(0xFFB7B5C7),
        muted: true,
      );
    }

    final day = index - leading + 1;
    if (day > daysInMonth) {
      return const _DayCell(label: '', muted: true);
    }

    final date = DateTime(year, month, day);
    final isSunday = date.weekday == DateTime.sunday;
    final isSelected = day == selectedDay;
    final holiday = _holidayForDay(day);
    final shortName = holiday?.name.split(' ').first;

    Color textColor = PortalColors.heading;
    if (isSelected) {
      textColor = Colors.white;
    } else if (holiday != null) {
      textColor = holiday.categoryColor;
    } else if (isSunday) {
      textColor = const Color(0xFFE0483E);
    }

    return GestureDetector(
      onTap: () => onSelectDay(day),
      behavior: HitTestBehavior.opaque,
      child: _DayCell(
        label: '$day',
        color: textColor,
        selected: isSelected,
        sublabel: shortName,
        sublabelColor: holiday?.categoryColor,
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    this.color = PortalColors.heading,
    this.muted = false,
    this.selected = false,
    this.sublabel,
    this.sublabelColor,
  });

  final String label;
  final Color color;
  final bool muted;
  final bool selected;
  final String? sublabel;
  final Color? sublabelColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 28,
            decoration: selected
                ? BoxDecoration(
                    color: PortalColors.purpleNav,
                    borderRadius: BorderRadius.circular(13),
                  )
                : null,
            alignment: Alignment.center,
            child: Text(
              label,
              style: portalText(
                fontSize: 11.5,
                fontWeight: muted ? FontWeight.w500 : FontWeight.w700,
                color: muted ? const Color(0xFFB7B5C7) : color,
                height: 14 / 11.5,
              ),
            ),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 1),
            Text(
              sublabel!,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: portalText(
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
                color: sublabelColor ?? const Color(0xFFE0499B),
                height: 9 / 7.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ByCategorySection extends StatelessWidget {
  const _ByCategorySection({required this.total});

  final int total;

  static const _legend = [
    (Color(0xFFEE7D3D), 'Festival'),
    (Color(0xFF1FA971), 'National Holiday'),
    (Color(0xFF26204A), 'Company Holiday'),
    (Color(0xFF8B6CE8), 'Observance'),
    (Color(0xFFE0499B), 'Restricted'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SectionTitle(
            icon: Icons.donut_large_rounded,
            title: 'By Category',
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9.5),
            child: Row(
              children: [
                SizedBox(
                  width: 111,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(111, 110),
                        painter: const _CategoryDonutPainter(),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: portalText(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.heading,
                              height: 22 / 18,
                            ),
                          ),
                          Text(
                            'TOTAL',
                            style: portalText(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.muted,
                              height: 10 / 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 73),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < _legend.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _legend[i].$1,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              _legend[i].$2,
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: PortalColors.secondaryText,
                                height: 13 / 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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

class _CategoryDonutPainter extends CustomPainter {
  const _CategoryDonutPainter();

  static const _segments = [
    (Color(0xFF1FA971), 0.35),
    (Color(0xFF26204A), 0.12),
    (Color(0xFFE0499B), 0.25),
    (Color(0xFFEE7D3D), 0.28),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius * 0.76);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.butt;

    paint.color = const Color(0xFFE9E7F2);
    canvas.drawCircle(center, radius * 0.76, paint);

    var start = -1.57079632679;
    for (final segment in _segments) {
      final sweep = segment.$2 * 6.28318530718;
      paint.color = segment.$1;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SearchHolidaysCard extends StatelessWidget {
  const _SearchHolidaysCard({
    required this.search,
    required this.month,
    required this.onMonthTap,
    required this.onMonthClear,
    required this.selectedChip,
    required this.foundCount,
    required this.onSearchChanged,
    required this.onChip,
  });

  final TextEditingController search;
  final DateTime? month;
  final VoidCallback onMonthTap;
  final VoidCallback onMonthClear;
  final String selectedChip;
  final int foundCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onChip;

  static const _chips = [
    'All',
    'Festival',
    'National Holiday',
    'Company Holiday',
    'Observance',
    'Restricted',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SectionTitle(
            icon: Icons.manage_search_rounded,
            title: 'Search Holidays',
          ),
          const SizedBox(height: 10),
          _SearchField(controller: search, onChanged: onSearchChanged),
          const SizedBox(height: 10),
          _MonthField(month: month, onTap: onMonthTap, onClear: onMonthClear),
          const SizedBox(height: 10),
          SizedBox(
            height: 30,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 2),
              itemCount: _chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 7),
              itemBuilder: (_, i) => _Chip(
                label: _chips[i],
                selected: selectedChip == _chips[i],
                onTap: () => onChip(_chips[i]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Found: $foundCount holidays',
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              height: 13 / 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _focus.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _clear() {
    widget.controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final hasText = widget.controller.text.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 40,
      padding: const EdgeInsets.only(left: 12, right: 6),
      decoration: BoxDecoration(
        color: focused ? PortalColors.surface : PortalColors.background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: focused ? PortalColors.purpleLight : PortalColors.border,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: PortalColors.purple.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 16,
            color: focused ? PortalColors.purple : PortalColors.muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              onChanged: widget.onChanged,
              cursorColor: PortalColors.purple,
              cursorHeight: 14,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration.collapsed(
                hintText: 'Search holiday name...',
                hintStyle: portalText(
                  fontSize: 11.4,
                  color: PortalColors.muted,
                  height: 14 / 11.4,
                ),
              ),
              style: portalText(
                fontSize: 11.4,
                fontWeight: FontWeight.w500,
                color: PortalColors.heading,
                height: 14 / 11.4,
              ),
            ),
          ),
          if (hasText) _ClearButton(onTap: _clear),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: PortalColors.border,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.close_rounded,
            size: 12,
            color: PortalColors.secondaryText,
          ),
        ),
      ),
    );
  }
}

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

class _MonthField extends StatelessWidget {
  const _MonthField({
    required this.month,
    required this.onTap,
    required this.onClear,
  });

  final DateTime? month;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final m = month;
    final active = m != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 39,
        padding: const EdgeInsets.only(left: 12, right: 6),
        decoration: BoxDecoration(
          color: active ? PortalColors.purpleTint : PortalColors.background,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: active ? PortalColors.purpleLight : PortalColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 16,
              color: active ? PortalColors.purple : PortalColors.muted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                active
                    ? '${_monthNames[m.month - 1]} ${m.year}'
                    : 'Filter by month',
                style: portalText(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? PortalColors.heading : PortalColors.muted,
                  height: 15 / 12,
                ),
              ),
            ),
            if (active)
              _ClearButton(onTap: onClear)
            else
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: PortalColors.muted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthPickResult {
  const _MonthPickResult(this.month);

  final DateTime? month;
}

class _MonthPickerSheet extends StatefulWidget {
  const _MonthPickerSheet({required this.initial});

  final DateTime? initial;

  @override
  State<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<_MonthPickerSheet> {
  late int _year = (widget.initial ?? DateTime.now()).year;

  @override
  Widget build(BuildContext context) {
    final selected = widget.initial;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _NavBtn(glyph: '‹', onTap: () => setState(() => _year--)),
                Expanded(
                  child: Text(
                    '$_year',
                    textAlign: TextAlign.center,
                    style: portalText(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.heading,
                      height: 17 / 14,
                    ),
                  ),
                ),
                _NavBtn(glyph: '›', onTap: () => setState(() => _year++)),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3,
              children: [
                for (var m = 1; m <= 12; m++)
                  _Chip(
                    label: _monthNames[m - 1].substring(0, 3),
                    selected:
                        selected != null &&
                        selected.year == _year &&
                        selected.month == m,
                    onTap: () => Navigator.of(
                      context,
                    ).pop(_MonthPickResult(DateTime(_year, m))),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _Chip(
              label: 'All months',
              selected: selected == null,
              onTap: () =>
                  Navigator.of(context).pop(const _MonthPickResult(null)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: selected ? PortalColors.purple : PortalColors.background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? PortalColors.purple : PortalColors.border,
          ),
        ),
        child: Center(
          widthFactor: 1,
          child: Text(
            label,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : PortalColors.secondaryText,
              height: 13 / 11,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, this.trailing});

  final IconData icon;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: PortalColors.purpleTint,
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 14, color: PortalColors.purple),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: portalText(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: PortalColors.heading,
            height: 16 / 13,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: PortalColors.purple,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              trailing!,
              style: portalText(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 11 / 9.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HolidayListSection extends StatelessWidget {
  const _HolidayListSection({required this.items});

  final List<HolidayUiModel> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: _SectionTitle(
              icon: Icons.event_note_rounded,
              title: 'Holiday / Occasion',
              trailing: items.isEmpty ? null : '${items.length}',
            ),
          ),
          const SizedBox(height: 20),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No holidays found',
                  style: portalText(fontSize: 12, color: PortalColors.muted),
                ),
              ),
            )
          else
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _HolidayCard(item: items[i]),
            ],
          if (items.isNotEmpty) ...[
            const SizedBox(height: 30),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: PortalColors.purpleTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'View all ${items.length} holidays ›',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.purple,
                    height: 13 / 11,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HolidayCard extends StatelessWidget {
  const _HolidayCard({required this.item});

  final HolidayUiModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              item.index,
              style: portalText(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB7B5C7),
                height: 13 / 10.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.categoryBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.celebration_outlined,
              size: 16,
              color: item.categoryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 16 / 13,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: item.categoryBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.category,
                    style: portalText(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: item.categoryColor,
                      height: 11 / 9.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.dateRange,
                  style: portalText(
                    fontSize: 10.5,
                    color: PortalColors.muted,
                    height: 13 / 10.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FD),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.daysLabel,
              style: portalText(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3B6FE0),
                height: 11 / 9.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
