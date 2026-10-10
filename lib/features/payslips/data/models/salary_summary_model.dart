import 'package:timelay_health/features/payslips/domain/entities/salary_summary.dart';

class SalarySummaryModel {
  const SalarySummaryModel({required this.summary});

  final SalarySummary summary;

  factory SalarySummaryModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final rows = json['data'] is List ? json['data'] as List : const [];
    final employee = json['employee'] is Map<String, dynamic>
        ? json['employee'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return SalarySummaryModel(
      summary: SalarySummary(
        totalRecords: _asInt(stats['totalRecords']),
        totalNetPay: _asDouble(stats['totalNetPay']),
        payslipsAvailable: _asInt(stats['payslipsAvailable']),
        avgSalary: _asDouble(stats['avgSalary']),
        months: rows
            .whereType<Map<String, dynamic>>()
            .map((row) => _month(row, employee))
            .toList(),
      ),
    );
  }

  static SalaryMonth _month(
    Map<String, dynamic> json,
    Map<String, dynamic> employee,
  ) {
    final weeks = json['weeklyBreakdown'] is List
        ? json['weeklyBreakdown'] as List
        : const [];
    final leaves = json['leavesBreakdown'] is Map<String, dynamic>
        ? json['leavesBreakdown'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return SalaryMonth(
      monthLabel: json['monthFormatted']?.toString() ?? '',
      monthKey: json['month']?.toString() ?? '',
      monthDays: _asInt(json['monthDays']),
      weekOffs: _asInt(json['weekOffs']),
      presentDays: _asDouble(json['presentDays']),
      halfDays: _asDouble(json['halfDays']),
      workingDays: _asDouble(json['workingDays']),
      earnedWeekOffs: _asDouble(json['earnedWeekOffs']),
      defaultWeekOffs: _asDouble(json['defaultWeekOffs']),
      totalLeaves: _asInt(json['totalLeaves']),
      expectedWorkingDays: _asInt(json['expectedWorkingDays']),
      payablePresentDays: _asDouble(json['payablePresentDays']),
      carryForwardDays: _asDouble(json['carryForwardDays']),
      salaryPerMonth: _asDouble(json['salaryPerMonth']),
      dailyRateLabel: _rate(json['dailyRate'] ?? json['salaryPerDay']),
      calculatedSalary: _asDouble(json['calculatedSalary']),
      baseCalculatedSalary: _asDouble(json['baseCalculatedSalary']),
      finalPay: _asDouble(json['finalPay']),
      otAmount: _asDouble(json['otAmount']),
      compOffEarned: _asDouble(json['compOffEarned']),
      compOffUsed: _asDouble(json['compOffUsed']),
      compOffBalance: _asDouble(json['compOffBalance']),
      isCurrentMonth: json['isCurrentMonth'] == true,
      canDownload: json['canDownload'] == true,
      joiningDate: _dateLabel(json['joiningDate']),
      bankName: _dash(json['bankName']),
      bankAccount: _dash(json['bankAccount']),
      panNo: _dash(json['panNo']),
      location: _dash(json['location']),
      holidayCount: _asInt(json['holidayCount']),
      fullWorkingDays: _asDouble(
        json['fullWorkingDays'] ?? json['workingDays'],
      ),
      otherDeductions: _asDouble(json['otherDeductions']),
      employeeCode: json['employeeId']?.toString().trim().isNotEmpty == true
          ? json['employeeId'].toString()
          : employee['employeeId']?.toString() ?? '',
      name: json['name']?.toString().trim().isNotEmpty == true
          ? json['name'].toString()
          : employee['name']?.toString() ?? '',
      department: json['department']?.toString().trim().isNotEmpty == true
          ? json['department'].toString()
          : employee['department']?.toString() ?? '',
      designation: json['designation']?.toString().trim().isNotEmpty == true
          ? json['designation'].toString()
          : employee['designation']?.toString() ?? '',
      approvedLeavesLabel: _leavesLabel(leaves),
      weeks: weeks.whereType<Map<String, dynamic>>().map(_week).toList(),
    );
  }

  static SalaryWeek _week(Map<String, dynamic> json) {
    return SalaryWeek(
      weekNumber: _asInt(json['weekNumber']),
      presentDays: _asDouble(json['presentDays']),
      halfDays: _asDouble(json['halfDays']),
      leaves: _asDouble(json['leaves']),
      effectiveWorkingDays: _asDouble(json['effectiveWorkingDays']),
      isEligibleForWeekoff: json['isEligibleForWeekoff'] == true,
    );
  }

  static String _leavesLabel(Map<String, dynamic> leaves) {
    const keys = ['CL', 'SL', 'EL', 'COFF', 'LOP', 'Other'];
    final parts = <String>[];
    for (final key in keys) {
      final count = _asDouble(leaves[key]);
      if (count <= 0) continue;
      parts.add('$key: ${_qty(count)}');
    }
    if (parts.isEmpty) return 'No Leaves';
    return parts.join('  ·  ');
  }

  static String _rate(dynamic value) {
    final amount = _asDouble(value);
    return '₹${amount.toStringAsFixed(2)}/day';
  }

  static String _dash(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text == 'null') return '-';
    return text;
  }

  static String _dateLabel(dynamic value) {
    final raw = value?.toString() ?? '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return '-';
    final local = parsed.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    return '$d/$m/${local.year}';
  }

  static String _qty(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(1);
  }

  static int _asInt(dynamic value) => _asDouble(value).round();

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
