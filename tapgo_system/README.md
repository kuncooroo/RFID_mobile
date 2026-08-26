# TapGo System (self-service kiosk)

Aplikasi kios lapangan terpisah dari `tapgo_app/` (user app).

## Flow

```text
Splash (cek backend)
→ Idle (tap RFID / QR)
→ Lookup POST /api/v1/kiosk/rfid/verify
   ├─ Terdaftar → info member → foto (opsional) → sukses
   └─ Belum terdaftar → Register → foto → konfirmasi → Save
      POST /api/v1/kiosk/register + upload-photo
→ Idle
```

## Run

```bash
cd tapgo_system
flutter pub get

# Android (ganti IP PC)
flutter run -d <device> --dart-define=API_BASE_URL=http://192.168.x.x:8000/api/v1

# Chrome + USB RFID reader
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

Optional: `--dart-define=KIOSK_API_KEY=...` jika `KIOSK_API_KEY` di-set di backend.
