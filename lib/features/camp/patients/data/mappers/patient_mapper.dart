import 'package:timelay_health/features/camp/camps/data/mappers/camp_mapper.dart';
import 'package:timelay_health/features/camp/camps/data/models/camp_model.dart';
import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';

class PatientMapper {
  const PatientMapper._();

  static CampPatient toEntity(CampPatientModel model) =>
      CampMapper.toPatientEntity(model);
}
