class AuthEndpoints {
  const AuthEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static const String login = '$_base/employees/login';

  static const String logout = '$_base/employees/logout';

  static const String forgotPasswordSendOtp =
      '$_base/employees/forgot-password/send-otp';

  static const String forgotPasswordVerifyOtp =
      '$_base/employees/forgot-password/verify-otp';

  static const String forgotPasswordReset =
      '$_base/employees/forgot-password/reset';

  static String getEmployee(String employeeId) =>
      '$_base/employees/get-employee?employeeId=${Uri.encodeQueryComponent(employeeId)}';
}
