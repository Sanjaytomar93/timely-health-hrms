import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/issues/presentation/models/issue_ui_model.dart';

sealed class IssuesState extends Equatable {
  const IssuesState({
    this.issues = const [],
    this.allIssues = const [],
    this.search = '',
    this.priority = 'All',
    this.status = 'All Status',
    this.type = 'All',
  });

  final List<IssueUiModel> issues;
  final List<IssueUiModel> allIssues;
  final String search;
  final String priority;
  final String status;
  final String type;

  @override
  List<Object?> get props => [
    issues,
    allIssues,
    search,
    priority,
    status,
    type,
  ];
}

class IssuesInitial extends IssuesState {
  const IssuesInitial();
}

class IssuesLoading extends IssuesState {
  const IssuesLoading({
    super.issues,
    super.allIssues,
    super.search,
    super.priority,
    super.status,
    super.type,
  });
}

class IssuesLoaded extends IssuesState {
  const IssuesLoaded({
    required super.issues,
    required super.allIssues,
    super.search,
    super.priority,
    super.status,
    super.type,
  });
}

class IssuesFailureState extends IssuesState {
  const IssuesFailureState(
    this.message, {
    super.issues,
    super.allIssues,
    super.search,
    super.priority,
    super.status,
    super.type,
  });

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}

class IssuesActionBusy extends IssuesState {
  const IssuesActionBusy({
    required super.issues,
    required super.allIssues,
    super.search,
    super.priority,
    super.status,
    super.type,
  });
}
