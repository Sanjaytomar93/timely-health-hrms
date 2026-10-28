import 'package:timelay_health/features/expense/domain/entities/expense_claim.dart';
import 'package:timelay_health/features/expense/presentation/models/expense_claim_ui_model.dart';

class ExpenseUiMapper {
  const ExpenseUiMapper._();

  static ExpenseSummaryUi toSummary(ExpenseOverview overview) {
    return ExpenseSummaryUi(
      totalClaims: '${overview.totalClaims}',
      totalAmountLabel: _amountLabel(overview.totalAmount),
      monthlyClaims: '${overview.monthlyClaims}',
      distanceLabel:
          '${overview.totalDistance.toStringAsFixed(overview.totalDistance % 1 == 0 ? 0 : 1)} km',
      pendingLabel: '${overview.pendingClaims}',
      rateLabel:
          '₹${overview.rate.toStringAsFixed(overview.rate % 1 == 0 ? 0 : 1)} per KM',
      dateLabel: _todayLabel(DateTime.now()),
    );
  }

  static String _todayLabel(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = date.toLocal();
    return '${weekdays[local.weekday - 1]}, '
        '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  static ExpenseClaimUiModel toUi(ExpenseClaim entity) {
    final km = entity.km;
    return ExpenseClaimUiModel(
      id: entity.id,
      purpose: _title(entity.purpose),
      dateLabel: _dateLabel(entity.date),
      amountLabel: _amountLabel(entity.totalAmount),
      kmLabel: '${km.toStringAsFixed(km % 1 == 0 ? 0 : 1)} km',
      rateLabel: '₹${entity.rateApplied.toStringAsFixed(0)}/km',
      stopsCountLabel: '${entity.stops.length} stops',
      remark: entity.remark,
      stops: entity.stops.map(_stopToUi).toList(),
      date: entity.date,
      rateApplied: entity.rateApplied > 0 ? entity.rateApplied : 4,
    );
  }

  static List<ExpenseClaimUiModel> toUiList(List<ExpenseClaim> entities) {
    return entities.map(toUi).toList();
  }

  static ExpenseStopUiModel _stopToUi(ExpenseStop stop) {
    final km = stop.km;
    return ExpenseStopUiModel(
      locationName: stop.locationName.isEmpty ? 'Stop' : stop.locationName,
      outcome: stop.outcome,
      kmLabel: '${km.toStringAsFixed(km % 1 == 0 ? 0 : 1)} km',
      km: stop.km,
      orderValue: stop.orderValue,
      upsellValue: stop.upsellValue,
    );
  }

  static String _dateLabel(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    return '$dd/$mm/${local.year}';
  }

  static String _title(String value) {
    final text = value.trim();
    if (text.isEmpty) return 'Expense claim';
    return text[0].toUpperCase() + text.substring(1);
  }

  static String _amountLabel(double totalAmount) {
    final amount = totalAmount.round();
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '₹$formatted';
  }
}
