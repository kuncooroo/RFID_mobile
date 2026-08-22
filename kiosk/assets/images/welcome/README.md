# Welcome card images

Replace these files to change the illustrations on the first (Welcome) screen.

| Card | File path |
|------|-----------|
| TAP MEMBER CARD (left) | `assets/images/welcome/tap_member_card.png` |
| REGISTER (right) | `assets/images/welcome/register.png` |

## How to replace

1. Export your illustration as **PNG** (or WebP — then rename paths in `lib/theme/welcome_assets.dart`).
2. Recommended size: about **560×432** (or similar 4:3 / landscape).
3. Overwrite the file with the **same filename**.
4. Hot restart the kiosk app (`R` in the Flutter terminal, or stop & run again).

No code change needed if you keep the same filenames.

## Optional: SVG / different names

Edit `lib/theme/welcome_assets.dart` if you want different paths, then list them under `flutter: assets:` in `pubspec.yaml`.
