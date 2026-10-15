import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/notifications/domain/failures/notification_failure.dart';
import 'package:timelay_health/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:timelay_health/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:timelay_health/features/notifications/presentation/models/notification_ui_model.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/notification_list_item.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/notification_detail_dialog.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit()..load(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  final Set<String> _selected = {};

  bool get _selecting => _selected.isNotEmpty;

  void _toggle(String id) {
    setState(() {
      if (!_selected.add(id)) _selected.remove(id);
    });
  }

  void _toggleAll(List<NotificationUiModel> items) {
    setState(() {
      final ids = items.map((e) => e.id).toSet();
      if (ids.isNotEmpty && ids.every(_selected.contains)) {
        _selected.removeAll(ids);
      } else {
        _selected.addAll(ids);
      }
    });
  }

  Future<void> _delete(List<String> ids) async {
    if (ids.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          ids.length == 1
              ? 'Delete notification?'
              : 'Delete ${ids.length} notifications?',
          style: portalText(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This cannot be undone.',
          style: portalText(fontSize: 13, color: PortalColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: portalText(
                color: PortalColors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final count = await context
          .read<NotificationsCubit>()
          .deleteNotifications(ids);
      if (!mounted) return;
      setState(() => _selected.removeAll(ids));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count notification(s) deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on NotificationFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortalColors.background,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            const _NotificationsAppBar(),
            Expanded(
              child: BlocConsumer<NotificationsCubit, NotificationsState>(
                listenWhen: (p, c) =>
                    c is NotificationsFailureState && c.allItems.isNotEmpty,
                listener: (context, state) {
                  if (state is NotificationsFailureState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final loading =
                      state is NotificationsLoading ||
                      state is NotificationsInitial;
                  final error =
                      state is NotificationsFailureState &&
                          state.allItems.isEmpty
                      ? state.message
                      : null;

                  return Column(
                    children: [
                      if (error == null)
                        _InboxHero(
                          unread: state.counts.unread,
                          total: state.counts.all,
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: _SearchField(
                          value: state.search,
                          onChanged: context
                              .read<NotificationsCubit>()
                              .setSearch,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _FilterRow(
                        filter: state.filter,
                        counts: state.counts,
                        onChanged: context.read<NotificationsCubit>().setFilter,
                      ),
                      const SizedBox(height: 8),
                      if (state.items.isNotEmpty)
                        _SelectionBar(
                          selecting: _selecting,
                          count: _selected.length,
                          allSelected: state.items.every(
                            (e) => _selected.contains(e.id),
                          ),
                          onToggleAll: () => _toggleAll(state.items),
                          onDelete: _selected.isEmpty
                              ? null
                              : () => _delete(_selected.toList()),
                        ),
                      Expanded(
                        child: RefreshIndicator(
                          color: PortalColors.purple,
                          onRefresh: () => context
                              .read<NotificationsCubit>()
                              .load(keepExisting: true),
                          child: loading && state.allItems.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    ShimmerCardList(itemCount: 6),
                                  ],
                                )
                              : error != null
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(24),
                                  children: [
                                    const SizedBox(height: 80),
                                    Text(
                                      error,
                                      textAlign: TextAlign.center,
                                      style: portalText(
                                        fontSize: 13,
                                        color: PortalColors.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Center(
                                      child: TextButton(
                                        onPressed: () => context
                                            .read<NotificationsCubit>()
                                            .load(),
                                        child: const Text('Retry'),
                                      ),
                                    ),
                                  ],
                                )
                              : state.items.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    24,
                                  ),
                                  children: const [_EmptyInbox()],
                                )
                              : ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    4,
                                    12,
                                    24,
                                  ),
                                  itemCount: state.items.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final item = state.items[index];
                                    return NotificationListItem(
                                      item: item,
                                      selecting: _selecting,
                                      selected: _selected.contains(item.id),
                                      onToggleSelect: () => _toggle(item.id),
                                      onDelete: () => _delete([item.id]),
                                      onTap: () async {
                                        final cubit = context
                                            .read<NotificationsCubit>();
                                        await cubit.markAsRead(item.id);
                                        if (!context.mounted) return;
                                        final action =
                                            await showNotificationDetailDialog(
                                              context,
                                              item: item,
                                            );
                                        if (!context.mounted) return;
                                        if (action ==
                                            NotificationDetailAction
                                                .goToDashboard) {
                                          EmployeeHomeShell.goToDashboard(
                                            context,
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
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

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.selecting,
    required this.count,
    required this.allSelected,
    required this.onToggleAll,
    required this.onDelete,
  });

  final bool selecting;
  final int count;
  final bool allSelected;
  final VoidCallback onToggleAll;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: selecting ? PortalColors.purpleTint : PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onToggleAll,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selecting ? PortalColors.purple : PortalColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  allSelected
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  color: PortalColors.purple,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selecting ? '$count selected' : 'Select all',
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.heading,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: onDelete == null
                        ? PortalColors.muted
                        : PortalColors.red,
                  ),
                  label: Text(
                    'Delete',
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: onDelete == null
                          ? PortalColors.muted
                          : PortalColors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationsAppBar extends StatelessWidget {
  const _NotificationsAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PortalColors.surface,
        border: Border(bottom: BorderSide(color: PortalColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
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
                  'Notifications',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    letterSpacing: 0.1,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your latest updates',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    color: PortalColors.muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const _MarkAllReadButton(),
        ],
      ),
    );
  }
}

class _MarkAllReadButton extends StatelessWidget {
  const _MarkAllReadButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      buildWhen: (previous, current) =>
          previous.counts.unread != current.counts.unread ||
          previous.markingAll != current.markingAll,
      builder: (context, state) {
        final hasUnread = state.counts.unread > 0;
        final enabled = hasUnread && !state.markingAll;
        return Material(
          color: enabled ? PortalColors.purpleTint : PortalColors.background,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: enabled ? () => _markAll(context) : null,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: state.markingAll
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PortalColors.purple,
                      ),
                    )
                  : Text(
                      'Mark all read',
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? PortalColors.purple
                            : PortalColors.muted,
                        height: 1.2,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _markAll(BuildContext context) async {
    try {
      await context.read<NotificationsCubit>().markAllAsRead();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is NotificationFailure
                ? e.message
                : 'Failed to mark all as read.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: portalText(fontSize: 13.5, color: PortalColors.heading),
      decoration: InputDecoration(
        hintText: 'Search notifications...',
        hintStyle: portalText(fontSize: 13.5, color: PortalColors.muted),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: PortalColors.muted,
          size: 20,
        ),
        filled: true,
        fillColor: PortalColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: _searchBorder(),
        enabledBorder: _searchBorder(),
        focusedBorder: _searchBorder(PortalColors.purple),
      ),
    );
  }

  OutlineInputBorder _searchBorder([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color ?? PortalColors.border),
    );
  }
}

class _InboxHero extends StatelessWidget {
  const _InboxHero({required this.unread, required this.total});

  final int unread;
  final int total;

  @override
  Widget build(BuildContext context) {
    final caughtUp = unread == 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PortalColors.purpleDeep, PortalColors.purpleLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PortalColors.purple.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              caughtUp
                  ? Icons.mark_email_read_rounded
                  : Icons.notifications_active_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caughtUp ? 'All caught up' : '$unread unread',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  caughtUp
                      ? 'No new updates right now'
                      : 'You have updates waiting',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$total',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  'total',
                  style: portalText(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.8),
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

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: PortalColors.purpleTint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: PortalColors.purple,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No notifications found',
            style: portalText(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'New leave, attendance, and shift updates will show up here.',
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 12,
              color: PortalColors.muted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filter,
    required this.counts,
    required this.onChanged,
  });

  final NotificationFilter filter;
  final NotificationFilterCounts counts;
  final ValueChanged<NotificationFilter> onChanged;

  static const _tabs = <(NotificationFilter, String)>[
    (NotificationFilter.all, 'All'),
    (NotificationFilter.unread, 'Unread'),
    (NotificationFilter.leaves, 'Leaves'),
    (NotificationFilter.shifts, 'Shifts'),
    (NotificationFilter.attendance, 'Attendance'),
    (NotificationFilter.announcements, 'Announcements'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (f, label) = _tabs[index];
          final selected = f == filter;
          final count = counts.forFilter(f);
          final showCount = f != NotificationFilter.unread || count > 0
              ? (f == NotificationFilter.all ||
                    f == NotificationFilter.leaves ||
                    f == NotificationFilter.attendance ||
                    f == NotificationFilter.announcements ||
                    f == NotificationFilter.shifts ||
                    f == NotificationFilter.unread)
              : false;

          return Material(
            color: selected ? PortalColors.purple : PortalColors.surface,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => onChanged(f),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? PortalColors.purple : PortalColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : PortalColors.secondaryText,
                      ),
                    ),
                    if (showCount &&
                        (f == NotificationFilter.all || count > 0)) ...[
                      const SizedBox(width: 6),
                      Container(
                        constraints: const BoxConstraints(minWidth: 20),
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white
                              : PortalColors.background,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$count',
                          style: portalText(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? PortalColors.purple
                                : PortalColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
