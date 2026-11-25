class AdminExpenseStats {
  const AdminExpenseStats({
    required this.totalEmployees,
    required this.totalVisits,
    required this.totalDistance,
    required this.totalReimbursement,
    required this.todayTotal,
  });

  final int totalEmployees;
  final int totalVisits;
  final double totalDistance;
  final double totalReimbursement;
  final double todayTotal;

  static const empty = AdminExpenseStats(
    totalEmployees: 0,
    totalVisits: 0,
    totalDistance: 0,
    totalReimbursement: 0,
    todayTotal: 0,
  );

  factory AdminExpenseStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return empty;
    return AdminExpenseStats(
      totalEmployees: _asInt(json['totalEmployees']),
      totalVisits: _asInt(json['totalVisits']),
      totalDistance: _asDouble(json['totalDistance']),
      totalReimbursement: _asDouble(json['totalReimbursement']),
      todayTotal: _asDouble(json['todayTotal']),
    );
  }

  String get totalEmployeesLabel => '$totalEmployees';
  String get totalVisitsLabel => '$totalVisits';
  String get totalDistanceLabel => AdminExpenseItem.formatNumber(totalDistance);
  String get totalReimbursementLabel =>
      AdminExpenseItem.formatInr(totalReimbursement);
  String get todayTotalLabel => AdminExpenseItem.formatInr(todayTotal);
}

class AdminExpenseUi {
  const AdminExpenseUi({
    required this.records,
    required this.stats,
  });

  final List<AdminExpenseItem> records;
  final AdminExpenseStats stats;

  static const empty = AdminExpenseUi(
    records: [],
    stats: AdminExpenseStats.empty,
  );

  factory AdminExpenseUi.fromApiJson(
    Map<String, dynamic> json, {
    DateTime? onlyDate,
    DateTime? rangeStart,
    DateTime? rangeEnd,
  }) {
    final raw = json['data'];
    final claims = raw is List
        ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : <Map<String, dynamic>>[];

    final filtered = claims.where((c) {
      final d = _asDate(c['date']);
      if (d == null) {
        return onlyDate == null && rangeStart == null;
      }
      final day = DateTime(d.year, d.month, d.day);
      if (onlyDate != null) {
        return day.year == onlyDate.year &&
            day.month == onlyDate.month &&
            day.day == onlyDate.day;
      }
      if (rangeStart != null && rangeEnd != null) {
        final start = DateTime(
          rangeStart.year,
          rangeStart.month,
          rangeStart.day,
        );
        final end = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);
        return !day.isBefore(start) && !day.isAfter(end);
      }
      return true;
    }).toList();

    final grouped = <String, _Agg>{};
    for (final claim in filtered) {
      final code = (claim['employeeId'] ?? '').toString().trim();
      if (code.isEmpty) continue;

      final details = claim['employeeDetails'] is Map
          ? Map<String, dynamic>.from(claim['employeeDetails'] as Map)
          : const <String, dynamic>{};

      final agg = grouped.putIfAbsent(
        code,
        () => _Agg(
          id: _asId(claim['_id'] ?? details['_id'] ?? code),
          name: (details['name'] ?? code).toString().trim(),
          code: code,
          designation: (details['role'] ?? details['department'] ?? '')
              .toString()
              .trim()
              .toUpperCase(),
        ),
      );

      agg.visits += 1;
      agg.distance += _asDouble(claim['km']);
      agg.reimbursement += _asDouble(claim['totalAmount']);
      final status = (claim['paymentStatus'] ?? claim['status'] ?? 'Pending')
          .toString()
          .trim();
      if (status.toLowerCase() != 'paid') {
        agg.hasPending = true;
      }
    }

    final records = grouped.values.map((a) {
      final initial = a.name.isNotEmpty ? a.name[0].toUpperCase() : '?';
      return AdminExpenseItem(
        id: a.id,
        name: a.name,
        code: a.code,
        designation: a.designation.isEmpty ? 'EMPLOYEE' : a.designation,
        initial: initial,
        status: a.hasPending ? 'Pending' : 'Paid',
        visits: '${a.visits} Visits',
        distance: '${AdminExpenseItem.formatNumber(a.distance)} KM',
        reimbursement: AdminExpenseItem.formatInr(a.reimbursement),
        isPaid: !a.hasPending,
        visitCount: a.visits,
        distanceValue: a.distance,
        reimbursementValue: a.reimbursement,
      );
    }).toList()
      ..sort((a, b) => b.reimbursementValue.compareTo(a.reimbursementValue));

    AdminExpenseStats stats;
    if (onlyDate != null || (rangeStart != null && rangeEnd != null)) {
      stats = AdminExpenseStats(
        totalEmployees: records.length,
        totalVisits: filtered.length,
        totalDistance: records.fold(0.0, (s, e) => s + e.distanceValue),
        totalReimbursement:
            records.fold(0.0, (s, e) => s + e.reimbursementValue),
        todayTotal: onlyDate != null
            ? records.fold(0.0, (s, e) => s + e.reimbursementValue)
            : AdminExpenseStats.fromJson(
                json['stats'] is Map<String, dynamic>
                    ? json['stats'] as Map<String, dynamic>
                    : null,
              ).todayTotal,
      );
    } else {
      final apiStats = AdminExpenseStats.fromJson(
        json['stats'] is Map<String, dynamic>
            ? json['stats'] as Map<String, dynamic>
            : null,
      );
      stats = apiStats.totalEmployees == 0 && records.isNotEmpty
          ? AdminExpenseStats(
              totalEmployees: records.length,
              totalVisits: apiStats.totalVisits > 0
                  ? apiStats.totalVisits
                  : filtered.length,
              totalDistance: apiStats.totalDistance > 0
                  ? apiStats.totalDistance
                  : records.fold(0.0, (s, e) => s + e.distanceValue),
              totalReimbursement: apiStats.totalReimbursement > 0
                  ? apiStats.totalReimbursement
                  : records.fold(0.0, (s, e) => s + e.reimbursementValue),
              todayTotal: apiStats.todayTotal,
            )
          : apiStats;
    }

    return AdminExpenseUi(records: records, stats: stats);
  }
}

class _Agg {
  _Agg({
    required this.id,
    required this.name,
    required this.code,
    required this.designation,
  });

  final String id;
  final String name;
  final String code;
  final String designation;
  int visits = 0;
  double distance = 0;
  double reimbursement = 0;
  bool hasPending = false;
}

class AdminExpenseItem {
  const AdminExpenseItem({
    required this.id,
    required this.name,
    required this.code,
    required this.designation,
    required this.initial,
    required this.status,
    required this.visits,
    required this.distance,
    required this.reimbursement,
    this.isPaid = false,
    this.visitCount = 0,
    this.distanceValue = 0,
    this.reimbursementValue = 0,
  });

  final String id;
  final String name;
  final String code;
  final String designation;
  final String initial;
  final String status;
  final String visits;
  final String distance;
  final String reimbursement;
  final bool isPaid;
  final int visitCount;
  final double distanceValue;
  final double reimbursementValue;

  static String formatInr(double value) {
    final fixed = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '₹${_withCommas(fixed)}';
  }

  static String formatNumber(double value) {
    final fixed = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return _withCommas(fixed);
  }

  static String _withCommas(String raw) {
    final parts = raw.split('.');
    final whole = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      final fromEnd = whole.length - i;
      buf.write(whole[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    if (parts.length > 1) return '${buf.toString()}.${parts[1]}';
    return buf.toString();
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
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
