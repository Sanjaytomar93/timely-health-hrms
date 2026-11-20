import 'package:timelay_health/features/expense/domain/entities/update_expense_params.dart';

class UpdateExpenseRequestModel {
  const UpdateExpenseRequestModel({
    required this.purpose,
    required this.date,
    required this.km,
    required this.outcome,
    required this.orderValue,
    required this.upsellValue,
    required this.remark,
    required this.stops,
  });

  final String purpose;
  final String date;
  final double km;
  final String outcome;
  final double orderValue;
  final double upsellValue;
  final String remark;
  final List<Map<String, dynamic>> stops;

  factory UpdateExpenseRequestModel.fromParams(UpdateExpenseParams params) {
    final d = params.date;
    final date =
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';

    return UpdateExpenseRequestModel(
      purpose: params.purpose,
      date: date,
      km: params.km,
      outcome: params.outcome,
      orderValue: params.orderValue,
      upsellValue: params.upsellValue,
      remark: params.remark,
      stops: [
        for (final s in params.stops)
          {
            'locationName': s.locationName,
            'outcome': s.outcome,
            'km': s.km,
            'orderValue': s.orderValue,
            'upsellValue': s.upsellValue,
          },
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    'purpose': purpose,
    'date': date,
    'km': km,
    'outcome': outcome,
    'orderValue': orderValue,
    'upsellValue': upsellValue,
    'remark': remark,
    'stops': stops,
  };
}
