import 'package:timelay_health/features/admin/shift/presentation/models/admin_shift_model.dart';

abstract class AdminShiftRepository {
  Future<AdminShiftUi> getAssignments();
}
