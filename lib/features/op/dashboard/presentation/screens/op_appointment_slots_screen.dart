import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
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

  String _day = 'Monday';
  String _doctorId = 'all';
  String? _shift; // Morning / Evening
  String? _status; // Available / Booked / Blocked
  DateTime? _date;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _data = OpSlotsUi.demo;
    _slots = List.of(_data.slots);
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
      if (_shift != null && s.shift != _shift) return false;
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

  void _addSlots() {
    final base = _filtered.isNotEmpty ? _filtered.first : _slots.first;
    final nextNo =
        _slots.isEmpty ? 1 : _slots.map((e) => e.number).reduce((a, b) => a > b ? a : b) + 1;
    setState(() {
      _slots.add(
        OpSlotUi(
          id: 's${DateTime.now().millisecondsSinceEpoch}',
          number: nextNo,
          startTime: '08:00 AM',
          endTime: '08:20 AM',
          doctorId: base.doctorId,
          doctorName: base.doctorName,
          specialization: base.specialization,
          durationMins: 20,
          bufferMins: 5,
          fee: base.fee,
          shift: 'Morning',
          day: _day == 'All' ? 'Monday' : _day,
          status: OpSlotStatus.available,
        ),
      );
    });
    _snack('New slot added');
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
                setState(() => _slots = List.of(OpSlotsUi.demo.slots));
                _snack('Slots refreshed');
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
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
                            onAdd: _addSlots,
                          ),
                          const SizedBox(height: 12),
                          _StatsRow(
                            total: _slots.length,
                            dayCount: filtered.length,
                            dayLabel: _day == 'All' ? 'All' : _day,
                            available: available,
                            booked: booked,
                            hours: '$hours Hrs',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'DAY',
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: OpColors.muted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 36,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _data.days.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final d = _data.days[i];
                                final selected = d == _day;
                                return GestureDetector(
                                  onTap: () => setState(() => _day = d),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? OpColors.blue
                                          : OpColors.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: selected
                                            ? OpColors.blue
                                            : OpColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      d,
                                      style: portalText(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: selected
                                            ? Colors.white
                                            : OpColors.secondary,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'DOCTOR',
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: OpColors.muted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 68,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _data.doctors.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final d = _data.doctors[i];
                                final selected = d.id == _doctorId;
                                return _DoctorChip(
                                  doctor: d,
                                  selected: selected,
                                  onTap: () =>
                                      setState(() => _doctorId = d.id),
                                );
                              },
                            ),
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
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.78,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final slot = morning[i];
                              return _SlotCard(
                                slot: slot,
                                onBook: () => _book(slot),
                                onBlock: () => _block(slot),
                                onDelete: () => _delete(slot),
                              );
                            },
                            childCount: morning.length,
                          ),
                        ),
                      ),
                    ],
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
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
                          time: '03:00 PM - 08:00 PM',
                          count: evening.length,
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.78,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final slot = evening[i];
                              return _SlotCard(
                                slot: slot,
                                onBook: () => _book(slot),
                                onBlock: () => _block(slot),
                                onDelete: () => _delete(slot),
                              );
                            },
                            childCount: evening.length,
                          ),
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
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: OpColors.blueTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  totalLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: OpColors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: OpColors.blue,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Add Slots',
                        style: portalText(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onDate,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: OpColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: OpColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
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
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: OpColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: OpColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        size: 16, color: OpColors.muted),
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
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Drop(
                hint: 'Shift',
                value: shift,
                items: const ['Morning', 'Evening'],
                onChanged: onShift,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Drop(
                hint: 'Status',
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
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: OpColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: portalText(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: OpColors.secondary,
            ),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('All $hint',
                  style: portalText(fontSize: 12, color: OpColors.muted)),
            ),
            ...items.map(
              (e) => DropdownMenuItem<String?>(
                value: e,
                child: Text(e, style: portalText(fontSize: 12)),
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Stat(
                title: 'Total OP',
                value: '$total',
                icon: Icons.calendar_month_rounded,
                accent: OpColors.blue,
                tint: OpColors.blueTint,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Stat(
                title: dayLabel,
                value: '$dayCount',
                icon: Icons.schedule_rounded,
                accent: OpColors.primary,
                tint: OpColors.primaryTint,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Stat(
                title: 'Available',
                value: '$available',
                icon: Icons.check_circle_rounded,
                accent: OpColors.green,
                tint: OpColors.greenTint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Stat(
                title: 'Booked',
                value: '$booked',
                icon: Icons.groups_rounded,
                accent: OpColors.orange,
                tint: OpColors.orangeTint,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Stat(
                title: 'OP Hours',
                value: hours,
                icon: Icons.bolt_rounded,
                accent: OpColors.purple,
                tint: OpColors.purpleTint,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.tint,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: OpColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OpColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: OpColors.muted,
                  ),
                ),
                Text(
                  value,
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: accent,
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

class _DoctorChip extends StatelessWidget {
  const _DoctorChip({
    required this.doctor,
    required this.selected,
    required this.onTap,
  });

  final OpSlotDoctorChip doctor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 108,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? OpColors.blue : OpColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? OpColors.blue : OpColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? Colors.white.withValues(alpha: 0.2)
                        : doctor.color.withValues(alpha: 0.15),
                  ),
                  child: Text(
                    doctor.id == 'all' ? 'All' : doctor.initials,
                    style: portalText(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : doctor.color,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    doctor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : OpColors.heading,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${doctor.slotCount} slots',
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white.withValues(alpha: 0.85)
                    : OpColors.muted,
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
  });

  final String title;
  final String time;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: OpColors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title ($time)',
              style: portalText(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: OpColors.heading,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: OpColors.blueTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: OpColors.blue,
              ),
            ),
          ),
        ],
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
        color: OpColors.purpleTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OpColors.purple.withValues(alpha: 0.2)),
      ),
      child: Row(
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
                  '$subtitle ($time)',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: OpColors.purple.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              time,
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: OpColors.purple,
              ),
            ),
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

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: OpColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OpColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'SLOT #${slot.number}',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: OpColors.muted,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: slot.statusTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  slot.statusLabel,
                  style: portalText(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: slot.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            slot.timeRange,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: OpColors.heading,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.emoji_events_outlined, size: 12, color: OpColors.orange),
              const SizedBox(width: 4),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: slot.doctorName,
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: OpColors.blue,
                        ),
                      ),
                      TextSpan(
                        text: ' (${slot.specialization})',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: OpColors.muted,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 12, color: OpColors.muted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  slot.durationLabel,
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: OpColors.muted,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: OpColors.greenTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  slot.feeLabel,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: OpColors.green,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Material(
                  color: canBook ? OpColors.green : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: canBook ? onBook : null,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 32,
                      child: Center(
                        child: Text(
                          'Book',
                          style: portalText(
                            fontSize: 12,
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
              Expanded(
                child: Material(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onBlock,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 32,
                      child: Center(
                        child: Text(
                          slot.status == OpSlotStatus.blocked ? 'Open' : 'Block',
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: OpColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Material(
                color: OpColors.redTint,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(10),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: OpColors.red,
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
