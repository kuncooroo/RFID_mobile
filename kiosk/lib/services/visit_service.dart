import '../config/kiosk_config.dart';
import '../models/presence.dart';
import 'kiosk_api.dart';

/// RFID visit without camera — backend awards points.
class VisitService {
  VisitService(this._api);

  final KioskApi _api;

  Future<CheckInRecord> recordVisit({required String rfidUid}) {
    return _api.recordVisit(
      rfidUid: rfidUid,
      deviceId: KioskConfig.deviceId,
      locationId: KioskConfig.locationId > 0 ? KioskConfig.locationId : null,
    );
  }
}
