import '../config/kiosk_config.dart';
import '../models/presence.dart';
import 'kiosk_api.dart';

/// Uploads capture, creates presence, then check-in. Backend is source of truth.
class PresenceService {
  PresenceService(this._api);

  final KioskApi _api;

  Future<PresenceRecord> submitCapture({
    required String rfidUid,
    required List<int> photoBytes,
  }) {
    return _api.recordPresence(
      rfidUid: rfidUid,
      bytes: photoBytes,
      deviceId: KioskConfig.deviceId,
      locationId: KioskConfig.locationId > 0 ? KioskConfig.locationId : null,
      filename: 'presence_${rfidUid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  Future<CheckInRecord> completeCheckIn({
    required PresenceRecord presence,
    required String rfidUid,
  }) {
    return _api.checkIn(presenceId: presence.id, rfidUid: rfidUid);
  }
}
