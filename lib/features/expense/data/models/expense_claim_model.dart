class ExpenseStopModel {
  const ExpenseStopModel({
    required this.id,
    required this.locationName,
    required this.outcome,
    required this.orderValue,
    required this.upsellValue,
    required this.km,
    required this.amount,
  });

  final String id;
  final String locationName;
  final String outcome;
  final double orderValue;
  final double upsellValue;
  final double km;
  final double amount;

  factory ExpenseStopModel.fromJson(Map<String, dynamic> json) {
    return ExpenseStopModel(
      id: _asId(json['_id'] ?? json['id']),
      locationName: json['locationName'] as String? ?? '',
      outcome: json['outcome'] as String? ?? '',
      orderValue: _asDouble(json['orderValue']),
      upsellValue: _asDouble(json['upsellValue']),
      km: _asDouble(json['km']),
      amount: _asDouble(json['amount']),
    );
  }
}

String _asId(dynamic value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  if (value is Map) {
    final oid = value[r'$oid'] ?? value['_id'] ?? value['id'] ?? value['oid'];
    return oid?.toString().trim() ?? '';
  }
  return value.toString().trim();
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

class ExpenseClaimModel {
  const ExpenseClaimModel({
    required this.id,
    required this.employeeId,
    required this.purpose,
    required this.date,
    required this.km,
    required this.rateApplied,
    required this.totalAmount,
    required this.orderValue,
    required this.upsellValue,
    required this.remark,
    required this.stops,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String employeeId;
  final String purpose;
  final DateTime? date;
  final double km;
  final double rateApplied;
  final double totalAmount;
  final double orderValue;
  final double upsellValue;
  final String remark;
  final List<ExpenseStopModel> stops;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ExpenseClaimModel.fromJson(Map<String, dynamic> json) {
    final stopsRaw = json['stops'] as List<dynamic>? ?? const [];
    return ExpenseClaimModel(
      id: _asId(json['_id'] ?? json['id']),
      employeeId: json['employeeId'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      date: _asDate(json['date']),
      km: _asDouble(json['km']),
      rateApplied: _asDouble(json['rateApplied']),
      totalAmount: _asDouble(json['totalAmount']),
      orderValue: _asDouble(json['orderValue']),
      upsellValue: _asDouble(json['upsellValue']),
      remark: json['remark'] as String? ?? '',
      stops: stopsRaw
          .whereType<Map<String, dynamic>>()
          .map(ExpenseStopModel.fromJson)
          .toList(),
      createdAt: _asDate(json['createdAt']),
      updatedAt: _asDate(json['updatedAt']),
    );
  }
}

DateTime? _asDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is Map) {
    final raw = value[r'$date'] ?? value['date'];
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is num) {
      return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    }
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  return null;
}

class MyExpensesResponseModel {
  const MyExpensesResponseModel({
    required this.success,
    required this.data,
    required this.totalClaims,
    required this.totalAmount,
    required this.monthlyClaims,
    required this.monthlyAmount,
    required this.totalDistance,
    required this.pendingClaims,
    required this.rate,
  });

  final bool success;
  final List<ExpenseClaimModel> data;
  final int totalClaims;
  final double totalAmount;
  final int monthlyClaims;
  final double monthlyAmount;
  final double totalDistance;
  final int pendingClaims;
  final double rate;

  factory MyExpensesResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = raw is List
        ? raw
              .whereType<Map<String, dynamic>>()
              .map(ExpenseClaimModel.fromJson)
              .toList()
        : <ExpenseClaimModel>[];
    final stats = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return MyExpensesResponseModel(
      success: json['success'] as bool? ?? false,
      data: list,
      totalClaims: _asInt(stats['totalClaims'], list.length),
      totalAmount: _asDouble(stats['totalAmount']),
      monthlyClaims: _asInt(stats['monthlyClaims'], list.length),
      monthlyAmount: _asDouble(stats['monthlyAmount']),
      totalDistance: _asDouble(stats['totalDistance']),
      pendingClaims: _asInt(stats['pendingClaims'], 0),
      rate: _asDouble(json['rate']),
    );
  }
}

int _asInt(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

class AddExpenseResponseModel {
  const AddExpenseResponseModel({
    required this.success,
    required this.message,
    required this.expense,
  });

  final bool success;
  final String message;
  final ExpenseClaimModel expense;

  factory AddExpenseResponseModel.fromJson(Map<String, dynamic> json) {
    final expenseJson = json['expense'];
    if (expenseJson is! Map<String, dynamic>) {
      throw const FormatException('Missing expense in response');
    }
    return AddExpenseResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      expense: ExpenseClaimModel.fromJson(expenseJson),
    );
  }
}
