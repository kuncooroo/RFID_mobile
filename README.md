# RFID

## Configuration

Pass environment-specific values at build or run time:

```sh
flutter run --dart-define=API_BASE_URL=https://api.example.com
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
```

`API_BASE_URL` defaults to an empty string so tests and requests with absolute
URLs continue to work. Release builds disable Google Fonts runtime downloads by
default. Bundle the selected font files as assets before using them in release,
or explicitly opt into runtime downloads with:

```sh
--dart-define=ALLOW_RUNTIME_FONT_FETCHING=true
```

Never pass secrets through `--dart-define`; compiled values can be extracted
from the application. Store authentication tokens through
`SecureStorageService`.
