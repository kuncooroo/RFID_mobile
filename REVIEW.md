# Engineering Review — RFID (Flutter + Laravel)

Scores are 1–10. Refactors applied for critical/high items are noted under **Fixed now**.

---

## Combined scorecard

| Area | Flutter | Laravel | Combined |
|------|--------:|--------:|---------:|
| Architecture | 7.5 | 7.5 | **7.5** |
| Scalability | 6.5 | 6.0 | **6.5** |
| Maintainability | 6.5 | 7.0 | **7.0** |
| Performance | 6.5 | 6.5 | **6.5** |
| Security | 5.0 → ~6.5* | 4.5 → ~7.0* | **~7.0*** |
| Folder Structure | 7.0 | 8.0 | **7.5** |
| Code Style | 7.5 | 8.0 | **7.5** |
| Framework Best Practices | 6.5 | 6.5 | **6.5** |
| SOLID | 7.0 | 6.5 | **7.0** |

\*After targeted security/session refactors in this pass.

**Overall: ~7.0 / 10** — coherent Feature-First + layered API foundation; harden money/auth/RFID before scaling features.

---

## What is working well

- Flutter Feature-First layout, Riverpod controllers, repository interfaces, GoRouter session redirects
- Shared design system + thin presentation controllers
- Laravel Controller → Service → Repository + Form Requests + API Resources + envelope
- Dio + Sanctum bearer model aligned with mobile secure storage

## What not to redesign

- Feature modules / Riverpod / GoRouter shell
- Controller → Service → Repository layering
- `ApiResponse` envelope and Form Request validation
- Existing UI screens and visual system

---

## Fixed now (no redesign)

### Laravel
1. **Sanctum abilities** — access `['access']` vs refresh `['refresh']` with TTLs; route middleware `ability:access` / `ability:refresh`
2. **Refresh rotation** — deletes only the presented refresh token (multi-device safe)
3. **Checkout** — ignores client `shipping_fee`/`discount`; server shipping rule; status `Pending`
4. **RFID ownership** — card must belong to caller (or unbound claim)
5. **Payment tokens** — `provider_token` encrypted cast
6. **Throttles** — refresh, checkout, RFID, messages
7. **Order policies** — `authorize` on show/track/cancel
8. **Seeder** — blocked outside `local`/`testing`

### Flutter
1. **Splash** — only clears tokens on `401`; keeps session when offline
2. **RFID** — no hardcoded member fallback; fails closed; `gateOpened` defaults `false`
3. **API URL** — no silent release default; debug-only emulator fallback
4. **Auth refresh** — bare `refreshDio` (no interceptor recursion)
5. **Favorites toggle** — add only on 404/422, not on every error

---

## Remaining improvements (priority)

| Priority | Item |
|----------|------|
| P1 | Wire policies on Address/Conversation (or delete unused policies) |
| P1 | Move stock `lockForUpdate` into `ProductRepository` |
| P1 | Preserve `ApiException` fields through auth (offline vs validation) |
| P2 | Delete unused `Local*` repositories (keep Mock + Remote) |
| P2 | Search recent queries → SharedPreferences, not secure storage |
| P2 | Feature tests: abilities, checkout ownership/totals, RFID ownership |
| P2 | Android cleartext network config for debug HTTP only |
| P3 | Register flow: apply session immediately like login |
| P3 | Soft-delete uniqueness strategy for users/products |
| P3 | Phone-based password reset path |

---

## Suggested next hardening sprint (estimate)

1. Policy consistency + ProductRepository stock lock  
2. Feature test suite for auth abilities & checkout  
3. Remove dead Local repositories  
4. Payment provider integration (leave orders `Pending` until webhook)
