# Kutuku Scan Kiosk (self-service receiver)

Aplikasi kios lapangan terpisah dari `mobile/` (user app).  
**Tidak mengubah** Flutter user app.

## Flow

1. **Idle** — dengarkan USB RFID (keyboard wedge) + scan QR via kamera  
2. **Verify** — `POST /api/v1/kiosk/verify`  
3. **Countdown 3-2-1** — live webcam + capture  
4. **Upload** — `POST /api/v1/kiosk/upload-photo` (multipart)  
5. Kembali ke Idle

## Run

```bash
cd kiosk
flutter pub get

# Android device / emulator (ganti IP PC)
flutter run -d <device> --dart-define=API_BASE_URL=http://192.168.x.x:8000/api/v1

# Chrome (PC kiosk + USB RFID)
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

Optional API key (jika `KIOSK_API_KEY` di-set di backend `.env`):

```bash
--dart-define=KIOSK_API_KEY=your-secret
```

## QR payload yang diterima

- Plain UID / member code: `0182120545` atau `MEM-2001`
- JSON: `{"type":"kutuku_member","uid":"0182120545"}`
