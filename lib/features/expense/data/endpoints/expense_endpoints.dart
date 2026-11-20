class ExpenseEndpoints {
  const ExpenseEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static const String add = '$_base/expense/add';

  static String myExpenses(String employeeId) =>
      '$_base/expense/my?employeeId=${Uri.encodeQueryComponent(employeeId)}';

  static String update(String id) =>
      '$_base/expense/updateexpense/${Uri.encodeComponent(id)}';

  static String delete(String id) =>
      '$_base/expense/deleteexpense/${Uri.encodeComponent(id)}';
}
