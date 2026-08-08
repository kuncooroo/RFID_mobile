# RFID — Kutuku Mobile + Laravel API

Aplikasi e-commerce RFID berbasis **Flutter** (mobile) dan **Laravel 12** (REST API + Sanctum).

| Bagian | Path | Stack |
|--------|------|--------|
| Mobile app | `mobile/` | Flutter · Riverpod · GoRouter · Dio |
| Backend API | `backend/` | Laravel 12 · MySQL · Sanctum |

Dokumentasi terkait:

- [Backend README](backend/README.md)
- [REST API docs](backend/docs/API.md)
- [Engineering review](REVIEW.md)

---

## Daftar isi

1. [Prasyarat](#1-prasyarat)
2. [Clone repository](#2-clone-repository)
3. [Setup backend (Laravel)](#3-setup-backend-laravel)
4. [Setup mobile (Flutter)](#4-setup-mobile-flutter)
5. [Menjalankan project](#5-menjalankan-project)
6. [Akun demo](#6-akun-demo)
7. [Struktur folder](#7-struktur-folder)
8. [Konfigurasi penting](#8-konfigurasi-penting)
9. [Troubleshooting](#9-troubleshooting)
10. [Kontribusi](#10-kontribusi)

---

## 1. Prasyarat

Pastikan sudah terpasang:

### Umum

- [Git](https://git-scm.com/)
- Editor: VS Code / Android Studio / Cursor

### Backend

- **PHP 8.2+** (disarankan 8.3)
- **Composer 2**
- **MySQL 8** (atau MariaDB)
- Opsional: [Laragon](https://laragon.org/) (Windows) / Laravel Herd / Sail

### Mobile

- **Flutter Stable** (SDK `^3.9.2` — cek `mobile/pubspec.yaml`)
- Android Studio + Android SDK (untuk emulator/device)
- Xcode (hanya jika build iOS di macOS)

Cek versi:

```bash
php -v
composer -V
mysql --version
flutter doctor -v
```

---

## 2. Clone repository

Ganti URL dengan repo GitHub Anda:

```bash
git clone https://github.com/<USERNAME>/<REPO>.git
cd <REPO>
```

Struktur setelah clone:

```text
rfid/
├── mobile/          # Flutter app
├── backend/         # Laravel API
├── REVIEW.md
└── README.md
```

---

## 3. Setup backend (Laravel)

### 3.1 Install dependency

```bash
cd backend
composer install
```

### 3.2 Environment

```bash
cp .env.example .env
php artisan key:generate
```

Edit `.env` (contoh Laragon / MySQL lokal):

```env
APP_NAME="RFID API"
APP_URL=http://127.0.0.1:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=rfid
DB_USERNAME=root
DB_PASSWORD=
```

### 3.3 Buat database

Di MySQL / Laragon:

```sql
CREATE DATABASE rfid CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Atau via CLI:

```bash
mysql -u root -e "CREATE DATABASE IF NOT EXISTS rfid CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

### 3.4 Migrasi + seeder

```bash
php artisan migrate --seed
php artisan storage:link
```

> Seeder hanya berjalan di environment `local` / `testing`.
>
> Demo seed sekarang mencakup **alamat + metode pembayaran** untuk `demo@kutuku.test`, selain katalog produk.

### 3.5 Jalankan API

```bash
php artisan serve --host=127.0.0.1 --port=8000
```

API base URL:

```text
http://127.0.0.1:8000/api/v1
```

Uji cepat:

```bash
curl http://127.0.0.1:8000/api/v1/home
```

---

## 4. Setup mobile (Flutter)

Buka terminal baru:

```bash
cd mobile
flutter pub get
```

### 4.1 Pilih `API_BASE_URL`

| Lingkungan | Nilai `API_BASE_URL` |
|------------|----------------------|
| Android emulator | `http://10.0.2.2:8000/api/v1` |
| iOS simulator | `http://127.0.0.1:8000/api/v1` |
| Device fisik (sama Wi‑Fi) | `http://<IP-KOMPUTER>:8000/api/v1` |
| Production | `https://api.domain-anda.com/api/v1` |

Cek IP komputer (Windows):

```bash
ipconfig
```

Gunakan IPv4 adapter Wi‑Fi / Ethernet, contoh: `192.168.1.10`.

### 4.2 Cleartext HTTP (debug Android)

Untuk development HTTP lokal, pastikan debug manifest mengizinkan cleartext (biasanya sudah di `android/app/src/debug/`).  
**Release wajib HTTPS** — jangan kirim HTTP ke production.

---

## 5. Menjalankan project

### Urutan yang disarankan

1. Start MySQL  
2. Start backend: `php artisan serve`  
3. Start Flutter  

### Flutter — Android emulator

```bash
cd mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

### Flutter — iOS simulator

```bash
cd mobile
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

### Flutter — device fisik

```bash
cd mobile
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000/api/v1
```

Pastikan HP dan PC satu jaringan, dan firewall mengizinkan port `8000`.

### Mode mock (tanpa backend)

Untuk demo UI saja (data lokal/mock):

```bash
flutter run --dart-define=USE_MOCK_AUTH=true --dart-define=USE_MOCK_HOME=true
```

Flag mock lain mengikuti pola `USE_MOCK_<FEATURE>=true` (lihat provider di tiap feature).

---

## 6. Akun demo

Setelah `php artisan migrate --seed`:

| Field | Value |
|-------|--------|
| Email | `demo@kutuku.test` |
| Password | `password` |
| RFID member | `MEM-1001` / `RFID-DEMO-001` |

Login API:

```bash
curl -X POST http://127.0.0.1:8000/api/v1/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"identifier\":\"demo@kutuku.test\",\"password\":\"password\"}"
```

---

## 7. Struktur folder

```text
rfid/
├── mobile/
│   ├── lib/
│   │   ├── core/           # router, session
│   │   ├── features/       # Feature First modules
│   │   ├── shared/         # design system & widgets
│   │   └── src/            # network, storage, config
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
├── backend/
│   ├── app/
│   │   ├── Http/           # Controllers, Requests, Resources
│   │   ├── Services/
│   │   ├── Repositories/
│   │   ├── Models/
│   │   └── Policies/
│   ├── database/migrations/
│   ├── routes/api.php
│   └── docs/API.md
└── README.md
```

---

## 8. Konfigurasi penting

### Flutter dart-defines

```bash
# Wajib untuk release
--dart-define=API_BASE_URL=https://api.example.com/api/v1

# Opsional: izinkan Google Fonts download di runtime
--dart-define=ALLOW_RUNTIME_FONT_FETCHING=true
```

- Jangan masukkan secret (API key, password) lewat `--dart-define`.
- Token auth disimpan di **Flutter Secure Storage**.

### Laravel Sanctum

- Access token ability: `access` (TTL ~12 jam)
- Refresh token ability: `refresh` (TTL ~30 hari)
- Endpoint refresh: `POST /api/v1/refresh`

### Auth header

```http
Authorization: Bearer {access_token}
Accept: application/json
```

---

## 9. Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Flutter tidak bisa hit API dari emulator | Gunakan `10.0.2.2`, bukan `127.0.0.1` |
| Device fisik timeout | Cek IP LAN, firewall, `php artisan serve --host=0.0.0.0` |
| `SQLSTATE` / DB connection | Pastikan MySQL jalan & `DB_*` di `.env` benar |
| `401` setelah login | Pastikan pakai access token, bukan refresh token |
| `composer install` gagal | Upgrade PHP/Composer; hapus `vendor/` lalu install ulang |
| `flutter pub get` gagal | Jalankan `flutter doctor` dan upgrade Flutter |
| Cleartext blocked (Android) | Pastikan build **debug**, atau pakai HTTPS |
| Seeder tidak jalan di production | Disengaja — hanya `local`/`testing` |

Jalankan API agar bisa diakses dari device di jaringan lokal:

```bash
cd backend
php artisan serve --host=0.0.0.0 --port=8000
```

---

## 10. Kontribusi

1. Fork / clone repo  
2. Buat branch: `git checkout -b feature/nama-fitur`  
3. Commit perubahan  
4. Push dan buat Pull Request  

### Checklist sebelum PR

- [ ] Backend: `php artisan migrate` sukses  
- [ ] Flutter: `flutter analyze` bersih  
- [ ] Tidak commit `.env`, key, atau credential  
- [ ] Update docs jika mengubah API / setup  

---

## Lisensi

Proyek ini bersifat privat kecuali ditentukan lain di repository GitHub.
