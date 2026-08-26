import '../config/system_config.dart';
import '../models/presence.dart';
import 'system_api.dart';

/// RFID visit without camera — backend awards points.
class VisitService {
  VisitService(this._api);

  final SystemApi _api;

  Future<CheckInRecord> recordVisit({required String rfidUid}) {
    return _api.recordVisit(
      rfidUid: rfidUid,
      deviceId: SystemConfig.deviceId,
      locationId: SystemConfig.locationId > 0 ? SystemConfig.locationId : null,
    );
  }
}
