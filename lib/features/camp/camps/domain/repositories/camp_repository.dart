import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';

abstract class CampRepository {
  Future<List<Camp>> getAssignedCamps(String employeeName);

  Future<CampPatient> getPatientById(String patientId);
}
