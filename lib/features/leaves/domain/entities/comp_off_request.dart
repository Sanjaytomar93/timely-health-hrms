class CompOffRequest {
  const CompOffRequest({
    required this.id,
    required this.reason,
    required this.days,
    required this.status,
    this.workDate,
    this.leaveDate,
    this.workType,
    this.totalHours,
    this.approvedBy,
    this.requestedOn,
  });

  final String id;
  final DateTime? workDate;
  final DateTime? leaveDate;
  final String? workType;
  final double? totalHours;
  final double days;
  final String reason;
  final String status;
  final String? approvedBy;
  final DateTime? requestedOn;
}

class CompOffRequests {
  const CompOffRequests({
    required this.totalCompOff,
    required this.usedCompOffCount,
    required this.remainingCompOffCount,
    required this.status,
    required this.records,
  });

  static const empty = CompOffRequests(
    totalCompOff: 0,
    usedCompOffCount: 0,
    remainingCompOffCount: 0,
    status: '',
    records: [],
  );

  final int totalCompOff;
  final int usedCompOffCount;
  final int remainingCompOffCount;
  final String status;
  final List<CompOffRequest> records;
}
