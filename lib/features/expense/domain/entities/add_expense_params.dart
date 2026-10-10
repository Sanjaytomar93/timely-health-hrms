class AddExpenseStopInput {
  const AddExpenseStopInput({
    required this.locationName,
    required this.outcome,
    required this.orderValue,
    required this.upsellValue,
    required this.km,
  });

  final String locationName;
  final String outcome;
  final double orderValue;
  final double upsellValue;
  final double km;
}

class AddExpenseParams {
  const AddExpenseParams({
    required this.purpose,
    required this.date,
    required this.employeeId,
    required this.km,
    required this.remark,
    required this.stops,
  });

  final String purpose;
  final DateTime date;
  final String employeeId;
  final double km;
  final String remark;
  final List<AddExpenseStopInput> stops;
}
