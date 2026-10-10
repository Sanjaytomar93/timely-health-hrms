import 'package:timelay_health/features/issues/domain/entities/issue.dart';
import 'package:timelay_health/features/issues/domain/repositories/issue_repository.dart';

class RaiseIssueUseCase {
  const RaiseIssueUseCase(this._repository);

  final IssueRepository _repository;

  Future<Issue> call(RaiseIssueParams params) {
    return _repository.raiseIssue(params);
  }
}
