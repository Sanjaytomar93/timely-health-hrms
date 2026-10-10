class HolidayModel {
  const HolidayModel({
    required this.id,
    required this.name,
    required this.totalDays,
    required this.type,
    required this.state,
    required this.isActive,
    this.fromDate,
    this.toDate,
  });

  final String id;
  final String name;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int totalDays;
  final String type;
  final String state;
  final bool isActive;

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      fromDate: _parseDate(json['fromDate']),
      toDate: _parseDate(json['toDate']),
      totalDays: (json['totalDays'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
