import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

class PortalFilterPickers {
  PortalFilterPickers._();

  static const monthNames = <String>[
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

  static Future<String?> showGrid({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String allLabel,
    required List<String> items,
    required String selected,
    String? highlightItem,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => PortalFilterGridPickerSheet(
        title: title,
        subtitle: subtitle,
        icon: icon,
        allLabel: allLabel,
        items: items,
        selected: selected,
        highlightItem: highlightItem,
      ),
    );
  }

  static Future<DateTimeRange?> showDateRange({
    required BuildContext context,
    DateTime? initialStart,
    DateTime? initialEnd,
  }) {
    return showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => PortalDateRangePickerSheet(
        initialStart: initialStart,
        initialEnd: initialEnd,
      ),
    );
  }

  static String chipDate(DateTime d) => '${d.day}/${d.month}';

  static String ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String monthAbbr(int month) {
    const abbr = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return abbr[month - 1];
  }
}

class PortalFilterGridPickerSheet extends StatelessWidget {
  const PortalFilterGridPickerSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.allLabel,
    required this.items,
    required this.selected,
    this.highlightItem,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String allLabel;
  final List<String> items;
  final String selected;
  final String? highlightItem;

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.72;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PortalColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: PortalColors.brandTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 19, color: PortalColors.brand),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: portalText(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.heading,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          subtitle,
                          style: portalText(
                            fontSize: 11.5,
                            color: PortalColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: PortalColors.muted,
                    splashRadius: 18,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Material(
                color: selected == allLabel
                    ? PortalColors.brandTint
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(allLabel),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected == allLabel
                            ? PortalColors.brand
                            : PortalColors.border,
                        width: selected == allLabel ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected == allLabel
                              ? Icons.check_circle_rounded
                              : Icons.all_inclusive_rounded,
                          size: 18,
                          color: selected == allLabel
                              ? PortalColors.brand
                              : PortalColors.muted,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          allLabel,
                          style: portalText(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: selected == allLabel
                                ? PortalColors.brand
                                : PortalColors.heading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                  ),
                  itemBuilder: (ctx, index) {
                    final name = items[index];
                    final isSelected = selected == name;
                    final isHighlight = highlightItem == name;
                    return Material(
                      color: isSelected
                          ? PortalColors.brand
                          : (isHighlight
                              ? PortalColors.brandTint
                              : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(name),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? PortalColors.brand
                                  : (isHighlight
                                      ? PortalColors.brand
                                          .withValues(alpha: 0.45)
                                      : PortalColors.border),
                              width: isSelected || isHighlight ? 1.3 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            name,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : (isHighlight
                                      ? PortalColors.brand
                                      : PortalColors.heading),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PortalDateRangePickerSheet extends StatefulWidget {
  const PortalDateRangePickerSheet({
    super.key,
    this.initialStart,
    this.initialEnd,
  });

  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  State<PortalDateRangePickerSheet> createState() =>
      _PortalDateRangePickerSheetState();
}

class _PortalDateRangePickerSheetState
    extends State<PortalDateRangePickerSheet> {
  late DateTime _viewMonth;
  DateTime? _start;
  DateTime? _end;
  bool _pickingEnd = false;

  static const _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
    final base = _start ?? DateTime.now();
    _viewMonth = DateTime(base.year, base.month);
    _pickingEnd = _start != null && _end == null;
  }

  DateTime _only(DateTime d) => DateTime(d.year, d.month, d.day);

  String _label(DateTime? d) {
    if (d == null) return 'Select date';
    return '${d.day.toString().padLeft(2, '0')} ${PortalFilterPickers.monthAbbr(d.month)} ${d.year}';
  }

  void _onDayTap(DateTime day) {
    final d = _only(day);
    setState(() {
      if (!_pickingEnd || _start == null) {
        _start = d;
        _end = null;
        _pickingEnd = true;
      } else {
        if (d.isBefore(_start!)) {
          _end = _start;
          _start = d;
        } else {
          _end = d;
        }
        _pickingEnd = false;
      }
    });
  }

  bool _inRange(DateTime day) {
    if (_start == null || _end == null) return false;
    final d = _only(day);
    return !d.isBefore(_start!) && !d.isAfter(_end!);
  }

  bool _isStart(DateTime day) =>
      _start != null && _only(day) == _only(_start!);

  bool _isEnd(DateTime day) => _end != null && _only(day) == _only(_end!);

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_viewMonth.year, _viewMonth.month, 1).weekday % 7;
    final cells = <DateTime?>[
      ...List<DateTime?>.filled(firstWeekday, null),
      ...List.generate(
        daysInMonth,
        (i) => DateTime(_viewMonth.year, _viewMonth.month, i + 1),
      ),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final canApply = _start != null && _end != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PortalColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: PortalColors.brandTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.date_range_rounded,
                    size: 19,
                    color: PortalColors.brand,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date Range',
                        style: portalText(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: PortalColors.heading,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Pick start and end date',
                        style: portalText(
                          fontSize: 11.5,
                          color: PortalColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: PortalColors.muted,
                  splashRadius: 18,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _PortalDateFieldCard(
                    label: 'Start Date',
                    value: _label(_start),
                    active: !_pickingEnd,
                    filled: _start != null,
                    onTap: () => setState(() => _pickingEnd = false),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: PortalColors.brand.withValues(alpha: 0.45),
                  ),
                ),
                Expanded(
                  child: _PortalDateFieldCard(
                    label: 'End Date',
                    value: _label(_end),
                    active: _pickingEnd,
                    filled: _end != null,
                    onTap: () {
                      if (_start != null) {
                        setState(() => _pickingEnd = true);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PortalColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          _viewMonth = DateTime(
                            _viewMonth.year,
                            _viewMonth.month - 1,
                          );
                        }),
                        icon: const Icon(Icons.chevron_left_rounded),
                        color: PortalColors.heading,
                        splashRadius: 18,
                      ),
                      Expanded(
                        child: Text(
                          '${PortalFilterPickers.monthNames[_viewMonth.month - 1]} ${_viewMonth.year}',
                          textAlign: TextAlign.center,
                          style: portalText(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.heading,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          _viewMonth = DateTime(
                            _viewMonth.year,
                            _viewMonth.month + 1,
                          );
                        }),
                        icon: const Icon(Icons.chevron_right_rounded),
                        color: PortalColors.heading,
                        splashRadius: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (final d in _weekDays)
                        Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: PortalColors.muted,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cells.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 2,
                    ),
                    itemBuilder: (_, i) {
                      final day = cells[i];
                      if (day == null) return const SizedBox.shrink();

                      final isStart = _isStart(day);
                      final isEnd = _isEnd(day);
                      final inRange = _inRange(day);
                      final isEdge = isStart || isEnd;
                      final isToday = _only(day) == _only(DateTime.now());

                      return GestureDetector(
                        onTap: () => _onDayTap(day),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isEdge
                                ? PortalColors.brand
                                : (inRange
                                    ? PortalColors.brandTint
                                    : Colors.transparent),
                            shape:
                                isEdge ? BoxShape.circle : BoxShape.rectangle,
                            borderRadius: isEdge
                                ? null
                                : (inRange ? BorderRadius.circular(8) : null),
                            border: isToday && !isEdge && !inRange
                                ? Border.all(
                                    color: PortalColors.brand
                                        .withValues(alpha: 0.35),
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: portalText(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isEdge
                                  ? Colors.white
                                  : (inRange
                                      ? PortalColors.brand
                                      : PortalColors.heading),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _start = null;
                        _end = null;
                        _pickingEnd = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PortalColors.muted,
                      side: const BorderSide(color: PortalColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Clear',
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.muted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: canApply
                        ? () => Navigator.of(context).pop(
                              DateTimeRange(start: _start!, end: _end!),
                            )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PortalColors.brand,
                      disabledBackgroundColor:
                          PortalColors.brand.withValues(alpha: 0.35),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Range',
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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

class _PortalDateFieldCard extends StatelessWidget {
  const _PortalDateFieldCard({
    required this.label,
    required this.value,
    required this.active,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool active;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? PortalColors.brandTint : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? PortalColors.brand : PortalColors.border,
              width: active ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: active ? PortalColors.brand : PortalColors.muted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: filled ? PortalColors.heading : PortalColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
