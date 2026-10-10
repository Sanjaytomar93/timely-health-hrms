import 'package:timelay_health/features/expense/domain/entities/add_expense_params.dart';

class AddExpenseStopRequestModel {
  const AddExpenseStopRequestModel({
    required this.locationName,
    required this.outcome,
    required this.orderValue,
    required this.upsellValue,
    required this.km,
  });

  final String locationName;
  final String outcome;
  final String orderValue;
  final String upsellValue;
  final String km;

  factory AddExpenseStopRequestModel.fromInput(AddExpenseStopInput input) {
    String numAsString(double value) {
      if (value == value.roundToDouble()) {
        return value.round().toString();
      }
      return value.toString();
    }

    return AddExpenseStopRequestModel(
      locationName: input.locationName,
      outcome: input.outcome,
      orderValue: numAsString(input.orderValue),
      upsellValue: numAsString(input.upsellValue),
      km: numAsString(input.km),
    );
  }

  Map<String, dynamic> toJson() => {
    'locationName': locationName,
    'outcome': outcome,
    'orderValue': orderValue,
    'upsellValue': upsellValue,
    'km': km,
  };
}

class AddExpenseRequestModel {
  const AddExpenseRequestModel({
    required this.purpose,
    required this.date,
    required this.employeeId,
    required this.km,
    required this.remark,
    required this.stops,
  });

  final String purpose;
  final String date;
  final String employeeId;
  final double km;
  final String remark;
  final List<AddExpenseStopRequestModel> stops;

  factory AddExpenseRequestModel.fromParams(AddExpenseParams params) {
    final d = params.date;
    final date =
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';

    return AddExpenseRequestModel(
      purpose: params.purpose,
      date: date,
      employeeId: params.employeeId,
      km: params.km,
      remark: params.remark,
      stops: params.stops.map(AddExpenseStopRequestModel.fromInput).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'purpose': purpose,
    'date': date,
    'employeeId': employeeId,
    'km': km,
    'remark': remark,
    'stops': stops.map((s) => s.toJson()).toList(),
  };
}
