import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/notifications/data/repositories_impl/notification_repository_impl.dart';
import 'package:timelay_health/features/notifications/domain/failures/notification_failure.dart';
import 'package:timelay_health/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:timelay_health/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:timelay_health/features/notifications/presentation/models/notification_ui_model.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    GetNotificationsUseCase? getNotificationsUseCase,
    MarkAllNotificationsReadUseCase? markAllReadUseCase,
    MarkNotificationReadUseCase? markReadUseCase,
    DeleteNotificationsUseCase? deleteNotificationsUseCase,
  }) : _getNotifications =
           getNotificationsUseCase ??
           GetNotificationsUseCase(NotificationRepositoryImpl()),
       _markAllRead =
           markAllReadUseCase ??
           MarkAllNotificationsReadUseCase(NotificationRepositoryImpl()),
       _markRead =
           markReadUseCase ??
           MarkNotificationReadUseCase(NotificationRepositoryImpl()),
       _deleteNotifications =
           deleteNotificationsUseCase ??
           DeleteNotificationsUseCase(NotificationRepositoryImpl()),
       super(const NotificationsInitial());

  final GetNotificationsUseCase _getNotifications;
  final MarkAllNotificationsReadUseCase _markAllRead;
  final MarkNotificationReadUseCase _markRead;
  final DeleteNotificationsUseCase _deleteNotifications;

  List<NotificationUiModel> _all = const [];
  NotificationFilter _filter = NotificationFilter.all;
  String _search = '';

  Future<void> load({bool keepExisting = false}) async {
    emit(
      NotificationsLoading(
        items: keepExisting ? state.items : const [],
        allItems: keepExisting ? _all : const [],
        filter: _filter,
        search: _search,
        counts: keepExisting ? state.counts : NotificationFilterCounts.empty,
      ),
    );

    final employeeId =
        AuthSession.currentEmployee?.employeeId ??
        (await AuthSession.load())?.employeeId ??
        '';

    if (isClosed) return;
    if (employeeId.isEmpty) {
      emit(
        NotificationsFailureState(
          'Employee ID missing. Please login again.',
          items: keepExisting ? state.items : const [],
          allItems: keepExisting ? _all : const [],
          filter: _filter,
          search: _search,
          counts: keepExisting ? state.counts : NotificationFilterCounts.empty,
        ),
      );
      return;
    }

    try {
      final records = await _getNotifications(employeeId);
      if (isClosed) return;
      _all = NotificationUiMapper.toUiList(records);
      _emitFiltered();
    } on NotificationFailure catch (e) {
      if (isClosed) return;
      emit(
        NotificationsFailureState(
          e.message,
          items: keepExisting ? state.items : const [],
          allItems: keepExisting ? _all : const [],
          filter: _filter,
          search: _search,
          counts: keepExisting ? state.counts : NotificationFilterCounts.empty,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        NotificationsFailureState(
          'Failed to load notifications. Please try again.',
          items: keepExisting ? state.items : const [],
          allItems: keepExisting ? _all : const [],
          filter: _filter,
          search: _search,
          counts: keepExisting ? state.counts : NotificationFilterCounts.empty,
        ),
      );
    }
  }

  void setSearch(String value) {
    _search = value;
    _emitFiltered();
  }

  void setFilter(NotificationFilter filter) {
    _filter = filter;
    _emitFiltered();
  }

  Future<void> markAllAsRead() async {
    if (_all.every((e) => e.isRead)) return;

    final employeeId =
        AuthSession.currentEmployee?.employeeId ??
        (await AuthSession.load())?.employeeId ??
        '';
    if (employeeId.isEmpty) return;

    emit(
      NotificationsLoaded(
        items: state.items,
        allItems: _all,
        filter: _filter,
        search: _search,
        counts: state.counts,
        markingAll: true,
      ),
    );

    try {
      await _markAllRead(employeeId);
      if (isClosed) return;
      _all = _all.map((e) => e.copyWith(isRead: true)).toList();
      _emitFiltered();
    } on NotificationFailure {
      if (isClosed) return;
      _emitFiltered();
      rethrow;
    } catch (_) {
      if (isClosed) return;
      _emitFiltered();
      throw const NotificationFailure('Failed to mark notifications as read.');
    }
  }

  Future<int> deleteNotifications(List<String> ids) async {
    final unique = ids.toSet().toList();
    if (unique.isEmpty) return 0;
    final count = await _deleteNotifications(unique);
    if (isClosed) return count;
    _all = _all.where((e) => !unique.contains(e.id)).toList();
    _emitFiltered();
    return count;
  }

  Future<void> markAsRead(String id) async {
    final index = _all.indexWhere((e) => e.id == id);
    if (index < 0) return;
    if (_all[index].isRead) return;

    final previous = _all;
    _all = [
      for (var i = 0; i < _all.length; i++)
        if (i == index) _all[i].copyWith(isRead: true) else _all[i],
    ];
    _emitFiltered();

    try {
      await _markRead(id);
    } catch (_) {
      if (isClosed) return;
      _all = previous;
      _emitFiltered();
    }
  }

  void _emitFiltered() {
    final counts = _buildCounts(_all);
    emit(
      NotificationsLoaded(
        items: _applyFilters(_all),
        allItems: _all,
        filter: _filter,
        search: _search,
        counts: counts,
      ),
    );
  }

  NotificationFilterCounts _buildCounts(List<NotificationUiModel> source) {
    var unread = 0;
    var leaves = 0;
    var shifts = 0;
    var attendance = 0;
    var announcements = 0;
    for (final item in source) {
      if (!item.isRead) unread++;
      if (NotificationUiMapper.matchesFilter(item, NotificationFilter.leaves)) {
        leaves++;
      }
      if (NotificationUiMapper.matchesFilter(item, NotificationFilter.shifts)) {
        shifts++;
      }
      if (NotificationUiMapper.matchesFilter(
        item,
        NotificationFilter.attendance,
      )) {
        attendance++;
      }
      if (NotificationUiMapper.matchesFilter(
        item,
        NotificationFilter.announcements,
      )) {
        announcements++;
      }
    }
    return NotificationFilterCounts(
      all: source.length,
      unread: unread,
      leaves: leaves,
      shifts: shifts,
      attendance: attendance,
      announcements: announcements,
    );
  }

  List<NotificationUiModel> _applyFilters(List<NotificationUiModel> source) {
    final q = _search.trim().toLowerCase();
    return source.where((item) {
      if (!NotificationUiMapper.matchesFilter(item, _filter)) return false;
      if (q.isEmpty) return true;
      final hay =
          '${item.title} ${item.message} ${item.categoryLabel} ${item.typeRaw}'
              .toLowerCase();
      return hay.contains(q);
    }).toList();
  }
}
