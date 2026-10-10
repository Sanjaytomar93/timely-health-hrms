import 'package:timelay_health/features/issues/domain/entities/issue.dart';
import 'package:timelay_health/features/issues/domain/repositories/issue_repository.dart';

class GetMyIssuesUseCase {
  const GetMyIssuesUseCase(this._repository);

  final IssueRepository _repository;

  Future<List<Issue>> call(String employeeId) {
    return _repository.getMyIssues(employeeId: employeeId);
  }
}
