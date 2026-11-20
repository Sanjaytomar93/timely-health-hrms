class EmployeeListEndpoints {
  const EmployeeListEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static const String getEmployees = '$_base/employees/get-employeesforapp';
}
