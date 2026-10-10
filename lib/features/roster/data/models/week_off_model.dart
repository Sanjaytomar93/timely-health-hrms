class WeekOffModel {
  const WeekOffModel({
    required this.employeeId,
    required this.month,
    required this.totalWeekOffs,
    required this.weekOffDates,
    required this.selectionMode,
    required this.weekOffDays,
    required this.source,
  });

  final String employeeId;
  final String month;
  final int? totalWeekOffs;
  final List<String> weekOffDates;
  final String selectionMode;
  final List<String> weekOffDays;
  final String source;

  factory WeekOffModel.fromJson(Map<String, dynamic> json) {
    List<String> strings(Object? raw) => raw is List
        ? raw
              .map((e) => e?.toString().trim() ?? '')
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];

    var dates = strings(json['weekOffDates']);
    final list = json['weekOffList'];
    if (dates.isEmpty && list is List) {
      dates = strings(list.whereType<Map>().map((e) => e['date']).toList());
    }

    final total = json['totalWeekOffs'];
    return WeekOffModel(
      employeeId: json['employeeId']?.toString() ?? '',
      month: json['month']?.toString() ?? '',
      totalWeekOffs: total is num ? total.toInt() : null,
      weekOffDates: dates,
      selectionMode: json['selectionMode']?.toString() ?? '',
      weekOffDays: strings(json['weekOffDays']),
      source: json['source']?.toString() ?? '',
    );
  }
}

class MyWeekOffResponseModel {
  const MyWeekOffResponseModel({required this.success, required this.data});

  final bool success;
  final WeekOffModel data;

  factory MyWeekOffResponseModel.fromJson(Map<String, dynamic> json) {
    return MyWeekOffResponseModel(
      success: json['success'] as bool? ?? false,
      data: WeekOffModel.fromJson(json),
    );
  }
}
