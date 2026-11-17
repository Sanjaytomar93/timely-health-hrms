import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_doctors_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_slots_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_top_bar.dart';

class OpAppointmentSlotsScreen extends StatefulWidget {
  const OpAppointmentSlotsScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<OpAppointmentSlotsScreen> createState() =>
      _OpAppointmentSlotsScreenState();
}

class _OpAppointmentSlotsScreenState extends State<OpAppointmentSlotsScreen> {
  final _search = TextEditingController();
  late List<OpSlotUi> _slots;
  late final OpSlotsUi _data;

  late String _day;
  String _doctorId = 'all';
  String? _shift; // Morning / Evening
  String? _status; // Available / Booked / Blocked
  DateTime? _date;
  String _query = '';

  static String _todayName() {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[DateTime.now().weekday - 1];
  }

  @override
  void initState() {
    super.initState();
    _data = OpSlotsUi.demo;
    _day = _todayName();
    _date = DateTime.now();
    _slots = List.of(_data.slots)
        .map((s) => OpSlotUi(
              id: s.id,
              number: s.number,
              startTime: s.startTime,
              endTime: s.endTime,
              doctorId: s.doctorId,
              doctorName: s.doctorName,
              specialization: s.specialization,
              durationMins: s.durationMins,
              bufferMins: s.bufferMins,
              fee: s.fee,
              shift: s.shift,
              day: _day,
              status: s.status,
            ))
        .toList();
    _search.addListener(() => setState(() => _query = _search.text.trim()));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<OpSlotUi> get _filtered {
    return _slots.where((s) {
      if (_day != 'All' && s.day != _day) return false;
      if (_doctorId != 'all' && s.doctorId != _doctorId) return false;
      if (_shift != null) {
        if (_shift == 'Break Period') return false;
        final key = _shift!.startsWith('Morning')
            ? 'Morning'
            : _shift!.startsWith('Evening')
                ? 'Evening'
                : _shift!;
        if (s.shift != key) return false;
      }
      if (_status != null) {
        final ok = switch (_status) {
          'Available' => s.status == OpSlotStatus.available,
          'Booked' => s.status == OpSlotStatus.booked,
          'Blocked' => s.status == OpSlotStatus.blocked,
          _ => true,
        };
        if (!ok) return false;
      }
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        final hit = s.doctorName.toLowerCase().contains(q) ||
            s.specialization.toLowerCase().contains(q) ||
            s.timeRange.toLowerCase().contains(q) ||
            'slot #${s.number}'.contains(q);
        if (!hit) return false;
      }
      return true;
    }).toList();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(2024),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: OpColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _book(OpSlotUi slot) {
    if (slot.status != OpSlotStatus.available) return;
    setState(() {
      final i = _slots.indexWhere((e) => e.id == slot.id);
      if (i >= 0) _slots[i] = slot.copyWith(status: OpSlotStatus.booked);
    });
    _snack('Slot #${slot.number} booked');
  }

  void _block(OpSlotUi slot) {
    setState(() {
      final i = _slots.indexWhere((e) => e.id == slot.id);
      if (i < 0) return;
      final next = slot.status == OpSlotStatus.blocked
          ? OpSlotStatus.available
          : OpSlotStatus.blocked;
      _slots[i] = slot.copyWith(status: next);
    });
    _snack(
      slot.status == OpSlotStatus.blocked
          ? 'Slot #${slot.number} unblocked'
          : 'Slot #${slot.number} blocked',
    );
  }

  void _delete(OpSlotUi slot) {
    setState(() => _slots.removeWhere((e) => e.id == slot.id));
    _snack('Slot #${slot.number} deleted');
  }

  Future<void> _addSlots() async {
    final doctors = _data.doctors.where((d) => d.id != 'all').toList();
    final created = await showModalBottomSheet<List<OpSlotUi>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GenerateSlotsSheet(
        doctors: doctors,
        timeSlots: OpDoctorsUi.timeSlots,
      ),
    );
    if (created == null || created.isEmpty) return;
    setState(() => _slots.addAll(created));
    _snack('${created.length} slot(s) generated');
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final available =
        filtered.where((s) => s.status == OpSlotStatus.available).length;
    final booked =
        filtered.where((s) => s.status == OpSlotStatus.booked).length;
    final morning = filtered.where((s) => s.shift == 'Morning').toList();
    final evening = filtered.where((s) => s.shift == 'Evening').toList();
    final hours = (filtered.length * 20 / 60).toStringAsFixed(1);

    return ColoredBox(
      color: OpColors.background,
      child: Column(
        children: [
          OpTopBar(
            title: 'Appointment Slots',
            showBack: true,
            onMenuTap:
                widget.onMenuTap ?? () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: RefreshIndicator(
              color: OpColors.primary,
              onRefresh: () async {
                final today = _todayName();
                setState(() {
                  _day = today;
                  _date = DateTime.now();
                  _slots = List.of(OpSlotsUi.demo.slots)
                      .map((s) => OpSlotUi(
                            id: s.id,
                            number: s.number,
                            startTime: s.startTime,
                            endTime: s.endTime,
                            doctorId: s.doctorId,
                            doctorName: s.doctorName,
                            specialization: s.specialization,
                            durationMins: s.durationMins,
                            bufferMins: s.bufferMins,
                            fee: s.fee,
                            shift: s.shift,
                            day: today,
                            status: s.status,
                          ))
                      .toList();
                });
                _snack('Slots refreshed');
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TopControls(
                            totalLabel:
                                '${_slots.length} Total Slots • $_day',
                            dateLabel:
                                _date == null ? 'dd/mm/yyyy' : _fmtDate(_date!),
                            onDate: _pickDate,
                            search: _search,
                            shift: _shift,
                            status: _status,
                            onShift: (v) => setState(() => _shift = v),
                            onStatus: (v) => setState(() => _status = v),
                            onAdd: () => _addSlots(),
                          ),
                          const SizedBox(height: 14),
                          _StatsRow(
                            total: _slots.length,
                            dayCount: filtered.length,
                            dayLabel: _day == 'All' ? 'All' : _day,
                            available: available,
                            booked: booked,
                            hours: '$hours Hrs',
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Text(
                                'Select OP Day',
                                style: portalText(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: OpColors.heading,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_months[(_date ?? DateTime.now()).month - 1]} ${(_date ?? DateTime.now()).year}',
                                style: portalText(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: OpColors.muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Builder(
                            builder: (context) {
                              final dayW =
                                  (MediaQuery.sizeOf(context).width - 32 - 21) /
                                      4;
                              return SizedBox(
                                height: 52,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _data.days.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: 7),
                                  itemBuilder: (context, i) {
                                    final d = _data.days[i];
                                    final selected = d == _day;
                                    final count = d == 'All'
                                        ? _slots.length
                                        : _slots
                                            .where((s) => s.day == d)
                                            .length;
                                    return _DayCard(
                                      width: dayW,
                                      day: d,
                                      slots: count,
                                      selected: selected,
                                      onTap: () => setState(() => _day = d),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Builder(
                            builder: (context) {
                              final chipW =
                                  ((MediaQuery.sizeOf(context).width - 32 - 14) /
                                          3.2)
                                      .clamp(96.0, 128.0);
                              return SizedBox(
                                height: 32,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _data.doctors.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: 6),
                                  itemBuilder: (context, i) {
                                    final d = _data.doctors[i];
                                    final selected = d.id == _doctorId;
                                    return _DoctorChip(
                                      width: chipW,
                                      doctor: d,
                                      selected: selected,
                                      onTap: () =>
                                          setState(() => _doctorId = d.id),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No slots found',
                          style: portalText(
                            fontSize: 14,
                            color: OpColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    if (morning.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _ShiftHeader(
                          title: 'Morning Shift',
                          time: '09:00 AM - 02:00 PM',
                          count: morning.length,
                          morning: true,
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                        sliver: SliverList.separated(
                          itemCount: morning.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final slot = morning[i];
                            return _SlotCard(
                              slot: slot,
                              onBook: () => _book(slot),
                              onBlock: () => _block(slot),
                              onDelete: () => _delete(slot),
                            );
                          },
                        ),
                      ),
                    ],
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                        child: _BreakBanner(
                          title: _data.breakTitle,
                          subtitle: _data.breakSubtitle,
                          time: _data.breakTime,
                        ),
                      ),
                    ),
                    if (evening.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _ShiftHeader(
                          title: 'Evening Shift',
                          time: '05:00 PM - 10:00 PM',
                          count: evening.length,
                          morning: false,
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList.separated(
                          itemCount: evening.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final slot = evening[i];
                            return _SlotCard(
                              slot: slot,
                              onBook: () => _book(slot),
                              onBlock: () => _block(slot),
                              onDelete: () => _delete(slot),
                            );
                          },
                        ),
                      ),
                    ] else
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}

class _TopControls extends StatelessWidget {
  const _TopControls({
    required this.totalLabel,
    required this.dateLabel,
    required this.onDate,
    required this.search,
    required this.shift,
    required this.status,
    required this.onShift,
    required this.onStatus,
    required this.onAdd,
  });

  final String totalLabel;
  final String dateLabel;
  final VoidCallback onDate;
  final TextEditingController search;
  final String? shift;
  final String? status;
  final ValueChanged<String?> onShift;
  final ValueChanged<String?> onStatus;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: OpColors.heroGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: OpColors.primary.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      totalLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Manage OP schedule & bookings',
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 15, color: OpColors.primary),
                        const SizedBox(width: 3),
                        Text(
                          'Add Slots',
                          style: portalText(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: OpColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onDate,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: OpColors.surface,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: OpColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 15,
                        color: OpColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          dateLabel,
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: dateLabel == 'dd/mm/yyyy'
                                ? OpColors.muted
                                : OpColors.heading,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: OpColors.surface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: OpColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        size: 15, color: OpColors.muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: search,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Search slots...',
                          hintStyle:
                              portalText(fontSize: 12, color: OpColors.muted),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Drop(
                hint: 'All Shifts',
                value: shift,
                items: const [
                  'Morning Shift',
                  'Evening Shift',
                  'Break Period',
                ],
                onChanged: onShift,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Drop(
                hint: 'All Statuses',
                value: status,
                items: const ['Available', 'Booked', 'Blocked'],
                onChanged: onStatus,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Drop extends StatelessWidget {
  const _Drop({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: OpColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: OpColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
          style: portalText(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: OpColors.heading,
          ),
          hint: Text(
            hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: OpColors.secondary,
            ),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                hint,
                style: portalText(fontSize: 11, color: OpColors.muted),
              ),
            ),
            ...items.map(
              (e) => DropdownMenuItem<String?>(
                value: e,
                child: Text(
                  e,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.total,
    required this.dayCount,
    required this.dayLabel,
    required this.available,
    required this.booked,
    required this.hours,
  });

  final int total;
  final int dayCount;
  final String dayLabel;
  final int available;
  final int booked;
  final String hours;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = ((width - 32 - 16) / 3).clamp(100.0, 140.0);
    final items = [
      _StatCard(
        width: cardWidth,
        title: 'Total OP',
        value: '$total',
        subtitle: 'slots',
        valueColor: OpColors.heading,
        icon: Icons.calendar_month_rounded,
        iconColor: OpColors.blue,
        iconBg: OpColors.blueTint,
      ),
      _StatCard(
        width: cardWidth,
        title: dayLabel,
        value: '$dayCount',
        subtitle: 'today',
        valueColor: OpColors.primary,
        icon: Icons.schedule_rounded,
        iconColor: OpColors.primary,
        iconBg: OpColors.primaryTint,
      ),
      _StatCard(
        width: cardWidth,
        title: 'Available',
        value: '$available',
        subtitle: 'open',
        valueColor: OpColors.green,
        icon: Icons.check_circle_rounded,
        iconColor: OpColors.green,
        iconBg: OpColors.greenTint,
      ),
      _StatCard(
        width: cardWidth,
        title: 'Booked',
        value: '$booked',
        subtitle: 'patients',
        valueColor: OpColors.orange,
        icon: Icons.groups_rounded,
        iconColor: OpColors.orange,
        iconBg: OpColors.orangeTint,
      ),
      _StatCard(
        width: cardWidth,
        title: 'OP Hours',
        value: hours,
        subtitle: 'duration',
        valueColor: OpColors.purple,
        icon: Icons.bolt_rounded,
        iconColor: OpColors.purple,
        iconBg: OpColors.purpleTint,
      ),
    ];

    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => items[i],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.valueColor,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;
  final Color valueColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: OpColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: portalText(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                    height: 1.05,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: OpColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.width,
    required this.day,
    required this.slots,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final String day;
  final int slots;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? OpColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: selected ? OpColors.primary : const Color(0xFFE8ECF2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : OpColors.heading,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$slots Slots',
              style: portalText(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: selected
                    ? const Color(0xFF86EFAC)
                    : OpColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorChip extends StatelessWidget {
  const _DoctorChip({
    required this.width,
    required this.doctor,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final OpSlotDoctorChip doctor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAll = doctor.id == 'all';
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? OpColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? OpColors.primary : const Color(0xFFE8ECF2),
          ),
        ),
        child: Row(
          children: [
            if (!isAll) ...[
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.2)
                      : doctor.color.withValues(alpha: 0.15),
                ),
                child: Text(
                  doctor.initials.isEmpty ? 'D' : doctor.initials[0],
                  style: portalText(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : doctor.color,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                isAll ? 'All Doctors' : doctor.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : OpColors.heading,
                ),
              ),
            ),
            const SizedBox(width: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.18)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                '${doctor.slotCount}',
                style: portalText(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : OpColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShiftHeader extends StatelessWidget {
  const _ShiftHeader({
    required this.title,
    required this.time,
    required this.count,
    required this.morning,
  });

  final String title;
  final String time;
  final int count;
  final bool morning;

  @override
  Widget build(BuildContext context) {
    final bg = morning ? const Color(0xFFFFF7E8) : const Color(0xFFEFF6FF);
    final fg = morning ? const Color(0xFF92400E) : const Color(0xFF1E3A8A);
    final badgeBg = morning ? const Color(0xFFFDE68A) : const Color(0xFFDBEAFE);
    final icon = morning ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: morning ? const Color(0xFFFCD34D) : const Color(0xFF93C5FD),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: fg),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: portalText(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: fg,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          time,
                          style: portalText(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: fg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Scheduled Sessions & Walk-ins',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: fg.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: OpColors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count Slots',
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakBanner extends StatelessWidget {
  const _BreakBanner({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OpColors.purple.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: OpColors.purple,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.coffee_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: portalText(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: OpColors.purple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: OpColors.purple.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'NO OP SLOTS',
                            style: portalText(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: OpColors.purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: OpColors.purple.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Break Duration',
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: OpColors.purple,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: OpColors.purple.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  time,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: OpColors.purple,
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

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.slot,
    required this.onBook,
    required this.onBlock,
    required this.onDelete,
  });

  final OpSlotUi slot;
  final VoidCallback onBook;
  final VoidCallback onBlock;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final canBook = slot.status == OpSlotStatus.available;
    final specColor = OpDoctorUi.specializationColor(slot.specialization);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  'SLOT #${slot.number}',
                  style: portalText(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${slot.startTime} – ${slot.endTime}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: OpColors.heading,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: slot.statusTint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: slot.statusColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      slot.statusLabel,
                      style: portalText(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: slot.statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('👨‍⚕️', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            slot.doctorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: OpColors.heading,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      slot.specialization,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: specColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${slot.durationMins} Mins (+${slot.bufferMins}m)',
                          style: portalText(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: OpColors.greenTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      slot.feeLabel,
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: OpColors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Consult Fee',
                    style: portalText(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: OpColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: canBook ? OpColors.primary : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(9),
                  child: InkWell(
                    onTap: canBook ? onBook : null,
                    borderRadius: BorderRadius.circular(9),
                    child: SizedBox(
                      height: 32,
                      child: Center(
                        child: Text(
                          'Book',
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: canBook ? Colors.white : OpColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                child: InkWell(
                  onTap: onBlock,
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      slot.status == OpSlotStatus.blocked ? 'Open' : 'Block',
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: OpColors.secondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                child: InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
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

class _GenerateSlotsSheet extends StatefulWidget {
  const _GenerateSlotsSheet({
    required this.doctors,
    required this.timeSlots,
  });

  final List<OpSlotDoctorChip> doctors;
  final List<String> timeSlots;

  @override
  State<_GenerateSlotsSheet> createState() => _GenerateSlotsSheetState();
}

class _GenerateSlotsSheetState extends State<_GenerateSlotsSheet> {
  OpSlotDoctorChip? _doctor;
  DateTime? _from;
  DateTime? _to;
  final _days = <String>{};
  String _start = '09:00 AM';
  String _end = '09:20 AM';
  int _duration = 20;
  int _gap = 5;
  final _fee = TextEditingController(text: '300');
  String _shift = 'Morning Shift';

  static const _week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _dayMap = {
    'Mon': 'Monday',
    'Tue': 'Tuesday',
    'Wed': 'Wednesday',
    'Thu': 'Thursday',
    'Fri': 'Friday',
    'Sat': 'Saturday',
    'Sun': 'Sunday',
  };

  @override
  void dispose() {
    _fee.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _from : _to) ?? now,
      firstDate: DateTime(2024),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => isFrom ? _from = picked : _to = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SimplePick(
        title: isStart ? 'Start Time' : 'End Time',
        items: widget.timeSlots,
        selected: isStart ? _start : _end,
      ),
    );
    if (picked == null) return;
    setState(() => isStart ? _start = picked : _end = picked);
  }

  String _fmt(DateTime? d) => d == null
      ? 'dd/mm/yyyy'
      : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _generate() {
    if (_doctor == null) return;
    final fee = int.tryParse(_fee.text.trim()) ?? 300;
    final shift = _shift.startsWith('Evening') ? 'Evening' : 'Morning';
    final days = _days.isEmpty
        ? ['Monday']
        : _days.map((d) => _dayMap[d]!).toList();
    final out = <OpSlotUi>[];
    var n = DateTime.now().millisecondsSinceEpoch % 100000;
    for (final day in days) {
      out.add(
        OpSlotUi(
          id: 'gen$n',
          number: n % 1000,
          startTime: _start,
          endTime: _end,
          doctorId: _doctor!.id,
          doctorName: _doctor!.name,
          specialization: 'General Physician',
          durationMins: _duration,
          bufferMins: _gap,
          fee: fee,
          shift: shift,
          day: day,
          status: OpSlotStatus.available,
        ),
      );
      n++;
    }
    Navigator.pop(context, out);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: OpColors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generate New Slots',
                          style: portalText(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: OpColors.heading,
                          ),
                        ),
                        Text(
                          'Bulk create by date range or days',
                          style: portalText(fontSize: 11, color: OpColors.muted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                children: [
                  _lbl('Select Doctor *'),
                  _box(
                    child: InkWell(
                      onTap: () async {
                        final name = await showModalBottomSheet<String>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _SimplePick(
                            title: 'Select Doctor',
                            items: widget.doctors.map((d) => d.name).toList(),
                            selected: _doctor?.name,
                          ),
                        );
                        if (name == null) return;
                        for (final d in widget.doctors) {
                          if (d.name == name) {
                            setState(() => _doctor = d);
                            break;
                          }
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.medical_services_outlined, size: 16, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _doctor?.name ?? 'Select a doctor',
                              style: portalText(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _doctor == null
                                    ? const Color(0xFF94A3B8)
                                    : OpColors.heading,
                              ),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _lbl('Date Range (Bulk)'),
                  Row(
                    children: [
                      Expanded(child: _dateField('FROM', _fmt(_from), () => _pickDate(isFrom: true))),
                      const SizedBox(width: 8),
                      Expanded(child: _dateField('TO', _fmt(_to), () => _pickDate(isFrom: false))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _lbl('Select Recurring Days'),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _week.map((d) {
                      final on = _days.contains(d);
                      return GestureDetector(
                        onTap: () => setState(() => on ? _days.remove(d) : _days.add(d)),
                        child: Container(
                          width: 40,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: on ? OpColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: on ? OpColors.primary : const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            d,
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: on ? Colors.white : OpColors.secondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _lbl('Start Time *'),
                            _box(
                              child: InkWell(
                                onTap: () => _pickTime(isStart: true),
                                child: Row(
                                  children: [
                                    const Icon(Icons.schedule_rounded, size: 15, color: Color(0xFF94A3B8)),
                                    const SizedBox(width: 6),
                                    Text(_start, style: portalText(fontSize: 13, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _lbl('End Time *'),
                            _box(
                              child: InkWell(
                                onTap: () => _pickTime(isStart: false),
                                child: Row(
                                  children: [
                                    const Icon(Icons.schedule_rounded, size: 15, color: Color(0xFF94A3B8)),
                                    const SizedBox(width: 6),
                                    Text(_end, style: portalText(fontSize: 13, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _lbl('Slot Duration (Minutes) *'),
                  _numChips(
                    value: _duration,
                    options: const [15, 20, 25, 30],
                    onChanged: (v) => setState(() => _duration = v),
                  ),
                  const SizedBox(height: 10),
                  _lbl('Gap Between Slots (Minutes)'),
                  _numChips(
                    value: _gap,
                    options: const [0, 5, 10, 15],
                    onChanged: (v) => setState(() => _gap = v),
                  ),
                  const SizedBox(height: 10),
                  _lbl('Consultation Fee (₹) *'),
                  _box(
                    child: TextField(
                      controller: _fee,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: portalText(fontSize: 13.5, fontWeight: FontWeight.w700),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _lbl('Shift Category *'),
                  _box(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _shift,
                        items: const [
                          'Morning Shift',
                          'Evening Shift',
                          'Break Period',
                        ]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _shift = v ?? _shift),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(42),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                        ),
                        child: Text('Cancel', style: portalText(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _doctor == null ? null : _generate,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          'Generate Slots',
                          style: portalText(fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OpColors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(42),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                        ),
                      ),
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

  Widget _lbl(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          t,
          style: portalText(fontSize: 11, fontWeight: FontWeight.w700, color: OpColors.secondary),
        ),
      );

  Widget _box({required Widget child}) => Container(
        constraints: const BoxConstraints(minHeight: 42),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        alignment: Alignment.centerLeft,
        child: child,
      );

  Widget _dateField(String label, String value, VoidCallback onTap) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: portalText(fontSize: 10, fontWeight: FontWeight.w700, color: OpColors.muted)),
          const SizedBox(height: 4),
          _box(
            child: InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 15, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(
                    value,
                    style: portalText(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: value == 'dd/mm/yyyy' ? const Color(0xFF94A3B8) : OpColors.heading,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _numChips({
    required int value,
    required List<int> options,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: _box(
            child: Text(
              '$value mins',
              style: portalText(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 6,
            children: options.map((o) {
              final on = o == value;
              return GestureDetector(
                onTap: () => onChanged(o),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: on ? OpColors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: on ? OpColors.blue : const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    '${o}m',
                    style: portalText(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: on ? Colors.white : OpColors.secondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SimplePick extends StatelessWidget {
  const _SimplePick({
    required this.title,
    required this.items,
    required this.selected,
  });

  final String title;
  final List<String> items;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.5),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Text(title, style: portalText(fontSize: 15, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final on = item == selected;
                  return ListTile(
                    dense: true,
                    title: Text(
                      item,
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                        color: on ? OpColors.primary : OpColors.heading,
                      ),
                    ),
                    trailing: on ? const Icon(Icons.check_rounded, size: 18, color: OpColors.primary) : null,
                    onTap: () => Navigator.pop(context, item),
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
