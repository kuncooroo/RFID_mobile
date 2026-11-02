import '../config/system_config.dart';
import '../models/presence.dart';
import 'system_api.dart';

/// Gate tap: optional capture photo, saldo debit, and points on the backend.
class VisitService {
  VisitService(this._api);

  final SystemApi _api;

  Future<CheckInRecord> recordVisit({
    required String rfidUid,
    List<int>? photo,
  }) {
    return _api.recordVisit(
      rfidUid: rfidUid,
      deviceId: SystemConfig.deviceId,
      locationId: SystemConfig.locationId > 0 ? SystemConfig.locationId : null,
      photo: photo,
    );
  }
}
