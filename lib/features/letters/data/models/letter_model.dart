class LetterModel {
  const LetterModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.letterType,
    required this.designation,
    required this.department,
    required this.joiningDate,
    required this.relievingDate,
    required this.status,
    required this.letterPdfUrl,
    this.sentAt,
    this.createdAt,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final String letterType;
  final String designation;
  final String department;
  final String joiningDate;
  final String relievingDate;
  final String status;
  final String letterPdfUrl;
  final DateTime? sentAt;
  final DateTime? createdAt;

  factory LetterModel.fromJson(Map<String, dynamic> json) {
    final content = json['content'] is Map<String, dynamic>
        ? json['content'] as Map<String, dynamic>
        : const <String, dynamic>{};
    String read(String key) =>
        (json[key] ?? content[key])?.toString().trim() ?? '';

    return LetterModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      employeeId: read('employeeId'),
      employeeName: read('employeeName'),
      letterType: json['letterType']?.toString().trim() ?? '',
      designation: content['designation']?.toString().trim() ?? '',
      department: content['department']?.toString().trim() ?? '',
      joiningDate: content['joiningDate']?.toString().trim() ?? '',
      relievingDate: content['relievingDate']?.toString().trim() ?? '',
      status: json['status']?.toString().trim() ?? '',
      letterPdfUrl: json['letterPdfUrl']?.toString().trim() ?? '',
      sentAt: _parseDate(json['sentAt']),
      createdAt: _parseDate(json['createdAt']),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
