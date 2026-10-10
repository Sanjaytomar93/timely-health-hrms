import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/events/data/datasources/event_remote_datasource.dart';
import 'package:timelay_health/features/events/data/models/my_event.dart';
import 'package:timelay_health/features/events/presentation/widgets/event_form_dialog.dart';
import 'package:timelay_health/features/events/presentation/widgets/event_style.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final _api = EventRemoteDataSource();
  final _searchController = TextEditingController();

  String _userId = '';
  String _userRole = 'employee';
  List<MyEvent> _events = const [];
  bool _loading = true;
  String? _error;

  EventStatus? _status;
  EventType? _type;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _events.isEmpty;
      _error = null;
    });
    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    if (!mounted) return;
    if (employee == null || employee.id.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Session expired. Please login again.';
      });
      return;
    }
    _userId = employee.id;
    _userRole = employee.role.toLowerCase().contains('admin')
        ? 'admin'
        : 'employee';
    try {
      final events = await _api.getMyEvents(_userId);
      if (!mounted) return;
      setState(() {
        _events = _sorted(events);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  static List<MyEvent> _sorted(List<MyEvent> events) {
    final list = [...events];
    list.sort((a, b) {
      final da = a.daysToNext;
      final db = b.daysToNext;
      if ((da >= 0) != (db >= 0)) return da >= 0 ? -1 : 1;
      return da >= 0 ? da.compareTo(db) : db.compareTo(da);
    });
    return list;
  }

  List<MyEvent> get _visible {
    final q = _query.trim().toLowerCase();
    return _events.where((e) {
      if (_status != null && e.status != _status) return false;
      if (_type != null && e.type != _type) return false;
      if (q.isNotEmpty &&
          !'${e.title} ${e.notes} ${e.type.label}'.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  MyEvent? get _spotlight {
    final upcoming = _events.where((e) => e.daysToNext >= 0).toList();
    return upcoming.isEmpty ? null : upcoming.first;
  }

  int _count(EventStatus s) => _events.where((e) => e.status == s).length;

  Future<void> _openForm([MyEvent? initial]) async {
    final saved = await showEventFormDialog(
      context,
      initial: initial,
      onSubmit: (input) => initial == null
          ? _api.createEvent(userId: _userId, userRole: _userRole, input: input)
          : _api.updateEvent(
              eventId: initial.id,
              userId: _userId,
              userRole: _userRole,
              input: input,
            ),
    );
    if (saved != true || !mounted) return;
    _toast(initial == null ? 'Event added 🎉' : 'Event updated');
    await _load();
  }

  Future<void> _delete(MyEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteDialog(event: event),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _api.deleteEvent(event.id);
      if (!mounted) return;
      setState(() => _events = _events.where((e) => e.id != event.id).toList());
      _toast('Event deleted');
    } catch (e) {
      if (mounted) _toast(e.toString());
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      backgroundColor: PortalColors.background,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            _EventsAppBar(onAddEvent: () => _openForm()),
            Expanded(
              child: RefreshIndicator(
                color: PortalColors.purple,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _SpotlightCard(event: _spotlight, loading: _loading),
                    _StatsRow(
                      total: _events.length,
                      upcoming: _count(EventStatus.upcoming),
                      today: _count(EventStatus.today),
                      completed: _count(EventStatus.completed),
                      selected: _status,
                      onSelect: (s) => setState(() => _status = s),
                    ),
                    _SearchBar(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    _TypeFilter(
                      selected: _type,
                      onChanged: (t) => setState(() => _type = t),
                    ),
                    const SizedBox(height: 6),
                    if (_loading)
                      const _LoadingList()
                    else if (_error != null && _events.isEmpty)
                      _ErrorState(message: _error!, onRetry: _load)
                    else if (visible.isEmpty)
                      _EmptyState(
                        filtered: _events.isNotEmpty,
                        onAdd: () => _openForm(),
                      )
                    else ...[
                      for (var i = 0; i < visible.length; i++)
                        _AnimatedEntry(
                          key: ValueKey(visible[i].id),
                          index: i,
                          child: _EventCard(
                            event: visible[i],
                            onEdit: () => _openForm(visible[i]),
                            onDelete: () => _delete(visible[i]),
                          ),
                        ),
                      _ListFooter(shown: visible.length, total: _events.length),
                      _AddEventBanner(onTap: () => _openForm()),
                    ],
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

class _EventsAppBar extends StatelessWidget {
  const _EventsAppBar({required this.onAddEvent});

  final VoidCallback onAddEvent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PortalColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox.square(dimension: 32, child: PortalBackButton()),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'My Events',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: PortalColors.heading,
                letterSpacing: 0.1,
              ),
            ),
          ),
          const TopNotificationButton(
            asset: 'assets/icons/payslips/ic_notification.svg',
          ),
          const SizedBox(width: 6),
          const TopCalendarButton(
            asset: 'assets/icons/payslips/ic_notification_cal.svg',
          ),
          const SizedBox(width: 8),
          _AddIconButton(onTap: onAddEvent),
        ],
      ),
    );
  }
}

class _AddIconButton extends StatelessWidget {
  const _AddIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4B4285), Color(0xFF7B5CE0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4B4285).withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}


class _SpotlightCard extends StatelessWidget {
  const _SpotlightCard({required this.event, required this.loading});

  final MyEvent? event;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final e = event;
    final days = e?.daysToNext ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment(-0.95, -0.6),
          end: Alignment(0.95, 0.8),
          colors: [Color(0xFF26204A), Color(0xFF4B4285), Color(0xFF7B5CE0)],
        ),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(right: -50, top: -60, child: _bubble(150, 0.08)),
          Positioned(right: 40, bottom: -70, child: _bubble(110, 0.06)),
          const Positioned(
            right: 6,
            top: 0,
            child: Text('✨', style: TextStyle(fontSize: 18)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e == null ? 'YOUR MOMENTS' : 'NEXT CELEBRATION',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.75),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      e?.type.emoji ?? '🗓️',
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e?.title ??
                              (loading ? 'Loading…' : 'Plan your first event'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e == null
                              ? 'Birthdays, anniversaries, appointments & wins — all in one place.'
                              : '${e.type.label} · ${formatEventDate(e.nextOccurrence)}',
                          style: portalText(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.88),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (e != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(
                        days == 0 ? '🎉' : '$days',
                        style: portalText(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          switch (days) {
                            0 => 'It\'s today! Time to celebrate',
                            1 => 'day to go — it\'s tomorrow!',
                            _ => 'days to go',
                          },
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.notifications_active_outlined,
                        size: 15,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reminderLabel(e.reminderBefore),
                        style: portalText(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: alpha),
    ),
  );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.total,
    required this.upcoming,
    required this.today,
    required this.completed,
    required this.selected,
    required this.onSelect,
  });

  final int total;
  final int upcoming;
  final int today;
  final int completed;
  final EventStatus? selected;
  final ValueChanged<EventStatus?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Total',
              value: total,
              icon: Icons.insights_rounded,
              color: const Color(0xFF3B6FE0),
              tint: const Color(0xFFEAF1FD),
              selected: selected == null,
              onTap: () => onSelect(null),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'Upcoming',
              value: upcoming,
              icon: Icons.schedule_rounded,
              color: PortalColors.green,
              tint: PortalColors.greenTint,
              selected: selected == EventStatus.upcoming,
              onTap: () => onSelect(EventStatus.upcoming),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'Today',
              value: today,
              icon: Icons.card_giftcard_rounded,
              color: PortalColors.orange,
              tint: PortalColors.orangeTint,
              selected: selected == EventStatus.today,
              onTap: () => onSelect(EventStatus.today),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'Done',
              value: completed,
              icon: Icons.emoji_events_outlined,
              color: const Color(0xFF7B5CE0),
              tint: const Color(0xFFF0ECFD),
              selected: selected == EventStatus.completed,
              onTap: () => onSelect(EventStatus.completed),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.tint,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? tint : PortalColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : PortalColors.border,
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: selected ? PortalColors.surface : tint,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.toDouble()),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => Text(
                '${v.round()}',
                style: portalText(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: selected ? color : PortalColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: PortalColors.border),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          onChanged: onChanged,
          style: portalText(fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Search events…',
            hintStyle: portalText(fontSize: 12.5, color: PortalColors.muted),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 20,
              color: PortalColors.muted,
            ),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: PortalColors.muted,
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
            isDense: true,
            filled: true,
            fillColor: PortalColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: PortalColors.brand),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeFilter extends StatelessWidget {
  const _TypeFilter({required this.selected, required this.onChanged});

  final EventType? selected;
  final ValueChanged<EventType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          _chip(
            label: 'All',
            emoji: null,
            color: PortalColors.brand,
            isSelected: selected == null,
            onTap: () => onChanged(null),
          ),
          for (final t in EventType.values) ...[
            const SizedBox(width: 8),
            _chip(
              label: t.label,
              emoji: t.emoji,
              color: t.color,
              isSelected: selected == t,
              onTap: () => onChanged(selected == t ? null : t),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required String? emoji,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : PortalColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isSelected ? color : PortalColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: portalText(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : PortalColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedEntry extends StatelessWidget {
  const _AnimatedEntry({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index.clamp(0, 6) * 70),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 18),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  final MyEvent event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final type = event.type;
    final reminder = event.reminderBefore == 0
        ? 'Same day'
        : '${event.reminderBefore}d before';
    final details = [
      type.label,
      reminder,
      if (event.repeat == EventRepeat.yearly) 'Yearly',
    ].join('  ·  ');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _DateBadge(date: event.date, type: type),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(type.emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _StatusPill(event: event),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: type.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        details,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: PortalColors.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
                if (event.notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    event.notes.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 10.5,
                      color: PortalColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _CardMenu(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date, required this.type});

  final DateTime date;
  final EventType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 50,
      decoration: BoxDecoration(
        color: type.tint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: portalText(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: type.color,
              height: 1.1,
            ),
          ),
          Text(
            '${eventMonths[date.month - 1].toUpperCase()} ${date.year % 100}',
            style: portalText(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: type.color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.color,
    required this.tint,
    this.icon,
  });

  final String label;
  final Color color;
  final Color tint;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.event});

  final MyEvent event;

  @override
  Widget build(BuildContext context) {
    if (event.status == EventStatus.today) {
      return const _Pill(
        label: 'Today 🎉',
        color: PortalColors.orange,
        tint: PortalColors.orangeTint,
      );
    }
    if (event.daysToNext > 0) {
      return _Pill(
        label: countdownLabel(event.daysToNext),
        color: PortalColors.green,
        tint: PortalColors.greenTint,
        icon: event.repeat == EventRepeat.yearly && event.daysFromToday < 0
            ? Icons.autorenew_rounded
            : Icons.schedule_rounded,
      );
    }
    return _Pill(
      label: countdownLabel(event.daysFromToday),
      color: PortalColors.muted,
      tint: PortalColors.background,
      icon: Icons.history_rounded,
    );
  }
}

class _CardMenu extends StatelessWidget {
  const _CardMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: PopupMenuButton<int>(
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: const Icon(Icons.more_vert_rounded, color: PortalColors.muted),
        color: PortalColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onSelected: (v) => v == 0 ? onEdit() : onDelete(),
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 0,
            child: _menuRow(Icons.edit_outlined, 'Edit', PortalColors.heading),
          ),
          PopupMenuItem(
            value: 1,
            child: _menuRow(
              Icons.delete_outline_rounded,
              'Delete',
              PortalColors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow(IconData icon, String label, Color color) => Row(
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 10),
      Text(
        label,
        style: portalText(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    ],
  );
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.shown, required this.total});

  final int shown;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Row(
        children: [
          Text.rich(
            TextSpan(
              style: portalText(fontSize: 11, color: PortalColors.muted),
              children: [
                const TextSpan(text: 'Showing '),
                TextSpan(
                  text: '$shown',
                  style: portalText(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                TextSpan(text: ' of $total event${total == 1 ? '' : 's'}'),
              ],
            ),
          ),
          const Spacer(),
          for (final t in EventType.values) ...[
            if (t != EventType.values.first) const SizedBox(width: 6),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: t.color, shape: BoxShape.circle),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            height: 72,
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            decoration: BoxDecoration(
              color: PortalColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PortalColors.border),
            ),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: PortalColors.brandLight,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtered, required this.onAdd});

  final bool filtered;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          const Text('🎈', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text(
            filtered ? 'No matching events' : 'No events yet',
            style: portalText(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            filtered
                ? 'Try a different filter or search term.'
                : 'Add birthdays, anniversaries, achievements or appointments and get reminded on time.',
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 11.5,
              color: PortalColors.muted,
              height: 1.4,
            ),
          ),
          if (!filtered) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: PortalColors.brand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'Add your first event',
                style: portalText(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 38,
            color: PortalColors.red,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: portalText(fontSize: 12, color: PortalColors.secondaryText),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: PortalColors.brand,
              side: const BorderSide(color: PortalColors.border),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddEventBanner extends StatelessWidget {
  const _AddEventBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0ECFD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF7B5CE0).withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4B4285), Color(0xFF7B5CE0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Add New Event',
              style: portalText(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B4285),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({required this.event});

  final MyEvent event;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PortalColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: PortalColors.redTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: PortalColors.red,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Delete event?',
              style: portalText(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '"${event.title}" will be removed permanently.',
              textAlign: TextAlign.center,
              style: portalText(fontSize: 12, color: PortalColors.muted),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PortalColors.secondaryText,
                      side: const BorderSide(color: PortalColors.border),
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: PortalColors.red,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Delete'),
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
