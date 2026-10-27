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
    this.details = '',
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
  final String details;

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

extension LetterModelResignation on LetterModel {
  static LetterModel fromResignation(Map<String, dynamic> json) {
    String read(String key) => json[key]?.toString().trim() ?? '';
    return LetterModel(
      id: read('_id'),
      employeeId: read('employeeId'),
      employeeName: read('employeeName'),
      letterType: 'resignation',
      designation: read('designation'),
      department: read('department'),
      joiningDate: _formatDate(_parseDate(json['joiningDate'])),
      relievingDate: _formatDate(_parseDate(json['lastWorkingDate'])),
      status: read('status'),
      letterPdfUrl: '',
      sentAt:
          _parseDate(json['resignationDate']) ?? _parseDate(json['createdAt']),
      createdAt: _parseDate(json['createdAt']),
      details: [
        if (read('reasonCategory').isNotEmpty)
          'Category: ${read('reasonCategory')}',
        if (read('reason').isNotEmpty) 'Reason: ${read('reason')}',
        if (read('comments').isNotEmpty) 'Comments: ${read('comments')}',
        if (read('noticePeriodDays').isNotEmpty)
          'Notice period: ${read('noticePeriodDays')} days',
        if (read('approvedBy').isNotEmpty) 'Approved by: ${read('approvedBy')}',
        if (read('rejectedReason').isNotEmpty)
          'Rejected reason: ${read('rejectedReason')}',
        if (read('adminRemark').isNotEmpty)
          'Admin remark: ${read('adminRemark')}',
      ].join('\n'),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final d = date.toLocal();
  return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
