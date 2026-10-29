class ExpenseOverview {
  const ExpenseOverview({
    required this.claims,
    required this.totalClaims,
    required this.totalAmount,
    required this.monthlyClaims,
    required this.totalDistance,
    required this.pendingClaims,
    required this.rate,
  });

  final List<ExpenseClaim> claims;
  final int totalClaims;
  final double totalAmount;
  final int monthlyClaims;
  final double totalDistance;
  final int pendingClaims;
  final double rate;

  static const empty = ExpenseOverview(
    claims: [],
    totalClaims: 0,
    totalAmount: 0,
    monthlyClaims: 0,
    totalDistance: 0,
    pendingClaims: 0,
    rate: 0,
  );
}

class ExpenseStop {
  const ExpenseStop({
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
}

class ExpenseClaim {
  const ExpenseClaim({
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
    this.status = 'Pending',
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
  final List<ExpenseStop> stops;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
