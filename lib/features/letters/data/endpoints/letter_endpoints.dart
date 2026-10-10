class LetterEndpoints {
  const LetterEndpoints._();

  static const String _host = 'https://api.timelyhealth.in';
  static const String _base = '$_host/api';

  static String adminLetters(String employeeId) =>
      '$_base/employees/admin-letters/${Uri.encodeComponent(employeeId)}';

  /// Resolves `/uploads/...` paths returned by the API against the host.
  static String fileUrl(String path) {
    final value = path.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return value.startsWith('/') ? '$_host$value' : '$_host/$value';
  }
}
