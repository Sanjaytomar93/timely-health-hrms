class UpdateExpenseStopInput {
  const UpdateExpenseStopInput({
    required this.km,
    required this.orderValue,
    required this.upsellValue,
    this.locationName = '',
    this.outcome = '',
  });

  final double km;
  final double orderValue;
  final double upsellValue;
  final String locationName;
  final String outcome;
}

class UpdateExpenseParams {
  const UpdateExpenseParams({
    required this.id,
    required this.purpose,
    required this.date,
    required this.km,
    required this.outcome,
    required this.orderValue,
    required this.upsellValue,
    required this.remark,
    required this.stops,
  });

  final String id;
  final String purpose;
  final DateTime date;
  final double km;
  final String outcome;
  final double orderValue;
  final double upsellValue;
  final String remark;
  final List<UpdateExpenseStopInput> stops;
}
