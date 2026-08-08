# RFID / Kutuku API

Laravel 12 REST API with Sanctum, Repository + Service layers, Form Requests, API Resources, policies, and unified JSON error handling.

## Stack

- Laravel 12
- MySQL
- Sanctum (Bearer tokens)
- Repository pattern
- Service pattern
- Form Request validation
- API Resources + pagination

## Setup (Laragon)

```bash
cd backend
composer install
cp .env.example .env   # if needed
php artisan key:generate
```

Configure MySQL in `.env`:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=rfid
DB_USERNAME=root
DB_PASSWORD=
```

Create the database, then:

```bash
php artisan migrate --seed
php artisan storage:link
php artisan serve
```

API base URL: `http://127.0.0.1:8000/api/v1`

**Full REST docs:** [docs/API.md](docs/API.md)

## Demo credentials

- Email: `demo@kutuku.test`
- Password: `password`
- RFID member: `MEM-1001` / `RFID-DEMO-001`

## Auth

```http
POST /api/v1/login
Content-Type: application/json

{"identifier":"demo@kutuku.test","password":"password"}
```

Use `Authorization: Bearer {token}` on protected routes.

## Response envelope

```json
{
  "success": true,
  "message": "optional",
  "data": {},
  "meta": { "current_page": 1, "per_page": 15, "total": 100, "last_page": 7 }
}
```

Errors:

```json
{
  "success": false,
  "message": "Validation failed.",
  "code": "validation_error",
  "errors": {},
  "data": null
}
```

## Architecture

```text
Http/Controllers/Api  → thin
Http/Requests         → validation
Services              → orchestration / transactions
Repositories          → persistence (bound via RepositoryServiceProvider)
Models / Policies
Http/Resources        → JSON shaping
Support/ApiResponse   → envelope
```

## Main routes

| Method | Path | Auth |
|--------|------|------|
| POST | `/register`, `/login`, `/forgot-password`, `/reset-password` | Public |
| GET | `/home`, `/categories`, `/products`, `/stores/{id}` | Public |
| GET/PUT | `/user`, `/user/profile`, `/user/password`, `/user/settings` | Sanctum |
| CRUD-ish | `/favorites`, `/cart`, `/addresses`, `/payment-methods` | Sanctum |
| POST | `/checkout` | Sanctum |
| GET | `/orders`, `/orders/history`, `/orders/{id}/track` | Sanctum |
| * | `/conversations`, `/notifications`, `/rfid/verify` | Sanctum |

Point the Flutter app at this API with:

```sh
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

(Use your machine LAN IP for a physical device.)

**Full REST docs:** [docs/API.md](docs/API.md)

### Token refresh

`POST /api/v1/refresh` (Sanctum) — send the **refresh** token as `Authorization: Bearer …`.
Returns a new access + refresh pair. Flutter `AuthInterceptor` handles this on `401`.
