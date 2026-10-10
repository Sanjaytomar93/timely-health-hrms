import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/issues/domain/entities/issue.dart';

class IssueUiModel extends Equatable {
  const IssueUiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.issueType,
    required this.priority,
    required this.status,
    required this.dateLabel,
    required this.raisedOn,
    required this.employeeName,
    required this.department,
  });

  final String id;
  final String title;
  final String description;
  final String issueType;
  final String priority;
  final String status;
  final String dateLabel;
  final String raisedOn;
  final String employeeName;
  final String department;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    issueType,
    priority,
    status,
    dateLabel,
    raisedOn,
    employeeName,
    department,
  ];
}

class IssueUiMapper {
  const IssueUiMapper._();

  static IssueUiModel toUi(Issue issue) {
    return IssueUiModel(
      id: issue.id,
      title: issue.issueTitle.isEmpty ? 'Issue' : issue.issueTitle,
      description: issue.issueDescription,
      issueType: issue.issueType.isEmpty ? '—' : issue.issueType,
      priority: issue.priority.isEmpty ? '—' : issue.priority,
      status: issue.status.isEmpty ? 'Open' : issue.status,
      dateLabel: _dateLabel(issue.createdAt),
      raisedOn: _raisedOn(issue.createdAt),
      employeeName: issue.employeeName,
      department: issue.department,
    );
  }

  static List<IssueUiModel> toUiList(List<Issue> issues) =>
      issues.map(toUi).toList();

  static String _dateLabel(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    return '$d/$m/${local.year}';
  }

  static String _raisedOn(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final ss = local.second.toString().padLeft(2, '0');
    return '${_dateLabel(date)}, $hh:$mm:$ss';
  }
}
