class IssueEndpoints {
  const IssueEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String raise(String employeeId) =>
      '$_base/employees/raise-issue/${Uri.encodeComponent(employeeId)}';

  static String myIssues(String employeeId) =>
      '$_base/employees/get-employee-issues/${Uri.encodeComponent(employeeId)}';

  static String delete(String issueId) =>
      '$_base/employees/delete-issue/${Uri.encodeComponent(issueId)}';

  static String update(String issueId) =>
      '$_base/employees/update-issue/${Uri.encodeComponent(issueId)}';
}
