import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/notifications/presentation/models/notification_ui_model.dart';

class NotificationFilterCounts extends Equatable {
  const NotificationFilterCounts({
    required this.all,
    required this.unread,
    required this.leaves,
    required this.shifts,
    required this.attendance,
    required this.announcements,
  });

  final int all;
  final int unread;
  final int leaves;
  final int shifts;
  final int attendance;
  final int announcements;

  static const empty = NotificationFilterCounts(
    all: 0,
    unread: 0,
    leaves: 0,
    shifts: 0,
    attendance: 0,
    announcements: 0,
  );

  int forFilter(NotificationFilter filter) {
    return switch (filter) {
      NotificationFilter.all => all,
      NotificationFilter.unread => unread,
      NotificationFilter.leaves => leaves,
      NotificationFilter.shifts => shifts,
      NotificationFilter.attendance => attendance,
      NotificationFilter.announcements => announcements,
    };
  }

  @override
  List<Object?> get props => [
    all,
    unread,
    leaves,
    shifts,
    attendance,
    announcements,
  ];
}

sealed class NotificationsState extends Equatable {
  const NotificationsState({
    this.items = const [],
    this.allItems = const [],
    this.filter = NotificationFilter.all,
    this.search = '',
    this.counts = NotificationFilterCounts.empty,
    this.markingAll = false,
  });

  final List<NotificationUiModel> items;
  final List<NotificationUiModel> allItems;
  final NotificationFilter filter;
  final String search;
  final NotificationFilterCounts counts;
  final bool markingAll;

  @override
  List<Object?> get props => [
    items,
    allItems,
    filter,
    search,
    counts,
    markingAll,
  ];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading({
    super.items,
    super.allItems,
    super.filter,
    super.search,
    super.counts,
    super.markingAll,
  });
}

class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded({
    required super.items,
    required super.allItems,
    required super.filter,
    required super.search,
    required super.counts,
    super.markingAll,
  });
}

class NotificationsFailureState extends NotificationsState {
  const NotificationsFailureState(
    this.message, {
    super.items,
    super.allItems,
    super.filter,
    super.search,
    super.counts,
    super.markingAll,
  });

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}
