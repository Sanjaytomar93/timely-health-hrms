class ExpenseSummaryUi {
  const ExpenseSummaryUi({
    required this.totalClaims,
    required this.totalAmountLabel,
    required this.monthlyClaims,
    required this.distanceLabel,
    required this.pendingLabel,
    required this.rateLabel,
    required this.dateLabel,
  });

  final String totalClaims;
  final String totalAmountLabel;
  final String monthlyClaims;
  final String distanceLabel;
  final String pendingLabel;
  final String rateLabel;
  final String dateLabel;

  static const empty = ExpenseSummaryUi(
    totalClaims: '0',
    totalAmountLabel: '₹0',
    monthlyClaims: '0',
    distanceLabel: '0 km',
    pendingLabel: '0',
    rateLabel: '₹0 per KM',
    dateLabel: '',
  );
}

class ExpenseStopUiModel {
  const ExpenseStopUiModel({
    required this.locationName,
    required this.outcome,
    required this.kmLabel,
    this.km = 0,
    this.orderValue = 0,
    this.upsellValue = 0,
  });

  final String locationName;
  final String outcome;
  final String kmLabel;
  final double km;
  final double orderValue;
  final double upsellValue;
}

class ExpenseClaimUiModel {
  const ExpenseClaimUiModel({
    required this.id,
    required this.purpose,
    required this.dateLabel,
    required this.amountLabel,
    required this.kmLabel,
    required this.rateLabel,
    required this.stopsCountLabel,
    required this.remark,
    required this.stops,
    this.date,
    this.rateApplied = 4,
  });

  final String id;
  final String purpose;
  final String dateLabel;
  final String amountLabel;
  final String kmLabel;
  final String rateLabel;
  final String stopsCountLabel;
  final String remark;
  final List<ExpenseStopUiModel> stops;
  final DateTime? date;
  final double rateApplied;
}
