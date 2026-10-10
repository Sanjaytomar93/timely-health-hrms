class ExpenseEndpoints {
  const ExpenseEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static const String add = '$_base/expense/add';

  static String myExpenses(String employeeId) =>
      '$_base/expense/my?employeeId=${Uri.encodeQueryComponent(employeeId)}';
}
