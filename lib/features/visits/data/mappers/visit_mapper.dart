import 'package:timelay_health/features/visits/data/models/visit_model.dart';
import 'package:timelay_health/features/visits/domain/entities/visit.dart';

class VisitMapper {
  const VisitMapper._();

  static Visit toEntity(VisitModel model) {
    return Visit(
      id: model.id,
      employeeId: model.employeeId,
      centerName: model.centerName,
      clientName: model.clientName,
      contact: model.contact,
      address: model.address,
      addressLink: model.addressLink,
      status: model.status,
      remarks: model.remarks,
      employeeLocation: model.employeeLocation == null
          ? null
          : VisitEmployeeLocation(
              latitude: model.employeeLocation!.latitude,
              longitude: model.employeeLocation!.longitude,
              accuracy: model.employeeLocation!.accuracy,
              capturedAt: model.employeeLocation!.capturedAt,
              mapsLink: model.employeeLocation!.mapsLink,
            ),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static AddVisitRequestModel toRequest(AddVisitParams params) {
    return AddVisitRequestModel(
      centerName: params.centerName,
      clientName: params.clientName,
      contact: params.contact,
      address: params.address,
      addressLink: params.addressLink,
      employeeId: params.employeeId,
      employeeLocation: VisitEmployeeLocationModel(
        latitude: params.latitude,
        longitude: params.longitude,
        accuracy: params.accuracy,
      ),
      remarks: params.remarks,
      status: params.status,
    );
  }

  static AddVisitRequestModel toUpdateRequest(UpdateVisitParams params) {
    return AddVisitRequestModel(
      centerName: params.centerName,
      clientName: params.clientName,
      contact: params.contact,
      address: params.address,
      addressLink: params.addressLink,
      employeeId: params.employeeId,
      employeeLocation: VisitEmployeeLocationModel(
        latitude: params.latitude,
        longitude: params.longitude,
        accuracy: params.accuracy,
      ),
      remarks: params.remarks,
      status: params.status,
    );
  }
}
