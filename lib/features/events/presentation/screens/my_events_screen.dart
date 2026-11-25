import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: PortalSystemUi.darkStatusBar.copyWith(
        statusBarColor: PortalColors.brand,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const HomeSideDrawer(),
        backgroundColor: PortalColors.background,
        body: PortalSafeArea(
          bottom: false,
          child: Column(
            children: [
              _MyEventsTopBar(
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: PortalColors.purple,
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      _SpotlightCard(
                        event: _spotlight,
                        loading: _loading,
                        onAdd: () => _openForm(),
                      ),
                      const SizedBox(height: 12),
                      _StatsRow(
                        total: _events.length,
                        upcoming: _count(EventStatus.upcoming),
                        today: _count(EventStatus.today),
                        completed: _count(EventStatus.completed),
                        selected: _status,
                        onSelect: (s) => setState(() => _status = s),
                      ),
                      const SizedBox(height: 12),
                      _SearchBar(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _TypeFilterDropdown(
                              selected: _type,
                              onChanged: (t) => setState(() => _type = t),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _AddNewInlineButton(
                              onTap: () => _openForm(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.event_note_outlined,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'MY CELEBRATIONS',
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${visible.length}',
                              style: portalText(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_loading)
                        const _LoadingList()
                      else if (_error != null && _events.isEmpty)
                        _ErrorState(message: _error!, onRetry: _load)
                      else if (visible.isEmpty)
                        _EmptyState(
                          filtered: _events.isNotEmpty,
                          onAdd: () => _openForm(),
                        )
                      else
                        for (var i = 0; i < visible.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          _AnimatedEntry(
                            key: ValueKey(visible[i].id),
                            index: i,
                            child: _EventCard(
                              event: visible[i],
                              onEdit: () => _openForm(visible[i]),
                              onDelete: () => _delete(visible[i]),
                            ),
                          ),
                        ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: EmployeeBottomNav(
          currentIndex: 3,
          onTap: (i) => EmployeeHomeShell.goToTab(context, i),
        ),
      ),
    );
  }
}

class _MyEventsTopBar extends StatelessWidget {
  const _MyEventsTopBar({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PortalColors.brand,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMenuTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: PortalColors.brandTint,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/top_bar/ic_top_menu.svg',
                width: 18,
                height: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My Events',
                  style: portalText(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Personal celebrations & milestones',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const TopNotificationButton(
            asset: 'assets/icons/payslips/ic_notification.svg',
          ),
          const SizedBox(width: 8),
          const TopCalendarButton(
            asset: 'assets/icons/payslips/ic_notification_cal.svg',
          ),
        ],
      ),
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  const _SpotlightCard({
    required this.event,
    required this.loading,
    required this.onAdd,
  });

  final MyEvent? event;
  final bool loading;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final e = event;
    final days = e?.daysToNext ?? 0;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E143E),
            Color(0xFF2A1550),
            Color(0xFF381A6B),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E143E).withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -50,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34D399).withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            e == null
                                ? Icons.celebration_outlined
                                : Icons.auto_awesome_rounded,
                            size: 11,
                            color: const Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 4.5),
                          Text(
                            e == null ? 'YOUR MOMENTS' : 'NEXT CELEBRATION',
                            style: portalText(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (e != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: (days == 0
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF34D399))
                              .withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (days == 0
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF34D399))
                                .withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          days == 0
                              ? '🎉 Today!'
                              : (days == 1 ? 'Tomorrow!' : 'In $days days'),
                          style: portalText(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: days == 0
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFF6EE7B7),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: onAdd,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Add',
                                style: portalText(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        e?.type.emoji ?? '🗓️',
                        style: const TextStyle(fontSize: 24),
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
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e == null
                                ? 'Track birthdays, anniversaries & milestones with ease.'
                                : '${e.type.label} · ${formatEventDate(e.nextOccurrence)}',
                            style: portalText(
                              fontSize: 11.5,
                              color: Colors.white.withValues(alpha: 0.78),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (e != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_outlined,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Reminder: ${reminderLabel(e.reminderBefore)}',
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                        if (e.repeat == EventRepeat.yearly)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Yearly',
                              style: portalText(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
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
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total',
            value: total,
            icon: Icons.calendar_view_day_rounded,
            accentColor: const Color(0xFF6366F1),
            selected: selected == null,
            onTap: () {
              HapticFeedback.lightImpact();
              onSelect(null);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Upcoming',
            value: upcoming,
            icon: Icons.access_time_rounded,
            accentColor: const Color(0xFF10B981),
            selected: selected == EventStatus.upcoming,
            onTap: () {
              HapticFeedback.lightImpact();
              onSelect(EventStatus.upcoming);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Today',
            value: today,
            icon: Icons.cake_rounded,
            accentColor: const Color(0xFFF59E0B),
            showBadge: today > 0,
            selected: selected == EventStatus.today,
            onTap: () {
              HapticFeedback.lightImpact();
              onSelect(EventStatus.today);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Past',
            value: completed,
            icon: Icons.history_rounded,
            accentColor: const Color(0xFF8B5CF6),
            selected: selected == EventStatus.completed,
            onTap: () {
              HapticFeedback.lightImpact();
              onSelect(EventStatus.completed);
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.selected,
    required this.onTap,
    this.showBadge = false,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color accentColor;
  final bool selected;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.08)
              : PortalColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accentColor : const Color(0xFFE2E8F0),
            width: selected ? 1.4 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 12, color: accentColor),
                ),
                if (showBadge)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: portalText(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: selected ? accentColor : const Color(0xFF1E293B),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 9.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? accentColor : const Color(0xFF64748B),
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
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: PortalColors.border),
    );
    return ValueListenableBuilder<TextEditingValue>(
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
            size: 18,
            color: PortalColors.muted,
          ),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  color: PortalColors.muted,
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          isDense: true,
          filled: true,
          fillColor: PortalColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: PortalColors.brand),
          ),
        ),
      ),
    );
  }
}

class _TypeFilterDropdown extends StatelessWidget {
  const _TypeFilterDropdown({
    required this.selected,
    required this.onChanged,
  });

  final EventType? selected;
  final ValueChanged<EventType?> onChanged;

  Future<void> _pick(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => _TypePickerSheet(
        selected: selected,
        onPick: (t) {
          Navigator.of(ctx).pop();
          onChanged(t);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = selected != null;
    final label = selected == null
        ? 'All Types'
        : '${selected!.emoji} ${selected!.label}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pick(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isActive ? PortalColors.brandTint : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? PortalColors.brand.withValues(alpha: 0.35)
                  : PortalColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? PortalColors.brand
                        : PortalColors.secondaryText,
                  ),
                ),
              ),
              if (isActive)
                GestureDetector(
                  onTap: () => onChanged(null),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: PortalColors.brand,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: PortalColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypePickerSheet extends StatelessWidget {
  const _TypePickerSheet({
    required this.selected,
    required this.onPick,
  });

  final EventType? selected;
  final ValueChanged<EventType?> onPick;

  @override
  Widget build(BuildContext context) {
    final options = <(EventType?, String, String)>[
      (null, 'All', '✨'),
      for (final t in EventType.values) (t, t.label, t.emoji),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: PortalColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Filter by type',
              style: portalText(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: PortalColors.heading,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose an event category',
              style: portalText(
                fontSize: 12,
                color: PortalColors.muted,
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.35,
              ),
              itemBuilder: (_, i) {
                final (type, label, emoji) = options[i];
                final active = selected == type;
                final color = type?.color ?? PortalColors.brand;
                return Material(
                  color: active ? color.withValues(alpha: 0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => onPick(type),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: active
                              ? color.withValues(alpha: 0.45)
                              : PortalColors.border,
                          width: active ? 1.4 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: active ? color : PortalColors.heading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddNewInlineButton extends StatelessWidget {
  const _AddNewInlineButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: PortalColors.brandGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                'Add Event',
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
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _DateBadge(date: event.date, type: type),
          const SizedBox(width: 10),
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

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: PortalColors.surface,
              borderRadius: BorderRadius.circular(14),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
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
