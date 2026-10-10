class PermissionEndpoints {
  const PermissionEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static const String request = '$_base/permissions/request';

  static String myPermissions(String employeeId) =>
      '$_base/permissions/my-permissions/${Uri.encodeComponent(employeeId)}';
}
