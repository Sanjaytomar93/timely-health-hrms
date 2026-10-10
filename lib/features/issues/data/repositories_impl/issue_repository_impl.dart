import 'package:timelay_health/features/issues/data/datasources/issue_remote_datasource.dart';
import 'package:timelay_health/features/issues/data/mappers/issue_mapper.dart';
import 'package:timelay_health/features/issues/domain/entities/issue.dart';
import 'package:timelay_health/features/issues/domain/repositories/issue_repository.dart';

class IssueRepositoryImpl implements IssueRepository {
  IssueRepositoryImpl({IssueRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? IssueRemoteDataSource();

  final IssueRemoteDataSource _remote;

  @override
  Future<List<Issue>> getMyIssues({required String employeeId}) async {
    final models = await _remote.getMyIssues(employeeId: employeeId);
    return models.map(IssueMapper.toEntity).toList();
  }

  @override
  Future<Issue> raiseIssue(RaiseIssueParams params) async {
    final model = await _remote.raiseIssue(params);
    return IssueMapper.toEntity(model);
  }

  @override
  Future<Issue> updateIssue({
    required String issueId,
    required RaiseIssueParams params,
  }) async {
    final model = await _remote.updateIssue(issueId: issueId, params: params);
    return IssueMapper.toEntity(model);
  }

  @override
  Future<void> deleteIssue({required String issueId}) {
    return _remote.deleteIssue(issueId: issueId);
  }
}
