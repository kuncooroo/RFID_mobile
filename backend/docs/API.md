# RFID / Kutuku REST API Documentation

**Version:** `v1`  
**Base URL:** `http://127.0.0.1:8000/api/v1`  
**Stack:** Laravel 12 · MySQL · Sanctum · JSON REST  

---

## Table of Contents

1. [Overview](#1-overview)
2. [Authentication](#2-authentication)
3. [Headers](#3-headers)
4. [Response Envelope](#4-response-envelope)
5. [Error Responses](#5-error-responses)
6. [Status Codes](#6-status-codes)
7. [Pagination](#7-pagination)
8. [Filtering, Sorting & Searching](#8-filtering-sorting--searching)
9. [Auth Endpoints](#9-auth-endpoints)
10. [Profile & Settings](#10-profile--settings)
11. [Home & Catalog](#11-home--catalog)
12. [Products & Stores](#12-products--stores)
13. [Favorites](#13-favorites)
14. [Cart](#14-cart)
15. [Addresses & Payment Methods](#15-addresses--payment-methods)
16. [Checkout & Orders](#16-checkout--orders)
17. [Messaging](#17-messaging)
18. [Notifications](#18-notifications)
19. [RFID](#19-rfid)
20. [Resource Schemas](#20-resource-schemas)

---

## 1. Overview

All endpoints return JSON. Protected routes require a Sanctum personal access token issued by login or register.

| Item | Value |
|------|--------|
| API prefix | `/api/v1` |
| Content type | `application/json` |
| Auth scheme | `Bearer {token}` |
| Rate limits | Auth: `10/min` (login/register), `5/min` (password reset) |

**Demo credentials (after seed)**

| Field | Value |
|-------|--------|
| Email | `demo@kutuku.test` |
| Password | `password` |
| RFID member | `MEM-1001` or `RFID-DEMO-001` |

---

## 2. Authentication

### How it works

1. Call `POST /register` or `POST /login`.
2. Store `data.token` securely (Flutter Secure Storage).
3. Send `Authorization: Bearer {token}` on protected routes.
4. Call `POST /logout` to revoke the current token.

### Auth levels

| Level | Description |
|-------|-------------|
| **Public** | No token required |
| **Optional** | Token optional (e.g. product detail sets `is_favorite` when present) |
| **Required** | `auth:sanctum` — missing/invalid token → `401` |

---

## 3. Headers

### Common headers

| Header | Required | Description |
|--------|----------|-------------|
| `Accept` | Recommended | Always `application/json` (forced by middleware) |
| `Content-Type` | Yes (body requests) | `application/json` or `multipart/form-data` (RFID image) |
| `Authorization` | Protected routes | `Bearer {token}` |
| `Accept-Language` | Optional | `en`, `id`, `ar`, `zh` — sets app locale |

### Example

```http
Accept: application/json
Content-Type: application/json
Authorization: Bearer 1|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Accept-Language: en
```

---

## 4. Response Envelope

### Success

```json
{
  "success": true,
  "message": "optional human-readable message",
  "data": {},
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 100,
    "last_page": 7,
    "links": {}
  }
}
```

- `meta` is present on paginated list endpoints.
- `message` may be `null`.

### Auth token payload (`data`)

```json
{
  "token": "1|plainTextToken",
  "token_type": "Bearer",
  "user": { }
}
```

---

## 5. Error Responses

### Envelope

```json
{
  "success": false,
  "message": "Validation failed.",
  "code": "validation_error",
  "errors": {
    "email": ["The email has already been taken."]
  },
  "data": null
}
```

### Common error codes

| `code` | Meaning |
|--------|---------|
| `validation_error` | Form Request failed |
| `unauthenticated` | Missing/invalid Sanctum token |
| `not_found` | Route or model not found |
| `server_error` | Unexpected server exception |
| `invalid_current_password` | Wrong current password |
| `already_favorited` | Favorite already exists |
| `favorite_not_found` | Favorite missing |
| `insufficient_stock` | Product stock too low |
| `cart_item_not_found` | Cart line missing |
| `empty_checkout` | No selected cart items |
| `invalid_address` | Address not owned by user |
| `invalid_payment_method` | Payment method not owned |
| `order_not_found` | Order missing / not owned |
| `cannot_cancel` | Order status not cancellable |
| `conversation_not_found` | Conversation missing / not participant |
| `notification_not_found` | Notification not owned |
| `rfid_member_not_found` | RFID member inactive/missing |
| `verification_not_found` | RFID verification not owned |

---

## 6. Status Codes

| Code | Usage |
|------|--------|
| `200` | OK — successful read/update/delete |
| `201` | Created — register, create resources, checkout, RFID verify |
| `401` | Unauthenticated |
| `403` | Forbidden (owned-resource mismatch in some flows) |
| `404` | Not found |
| `422` | Validation / domain rule failure |
| `429` | Too many requests (throttled auth) |
| `500` | Server error |

---

## 7. Pagination

Paginated endpoints accept:

| Query | Type | Default | Max | Description |
|-------|------|---------|-----|-------------|
| `per_page` | integer | `15` (notifications `20`, messages `30`) | `50` (products) | Page size |
| `page` | integer | `1` | — | Page number (Laravel default) |

### Paginated success example

```json
{
  "success": true,
  "message": null,
  "data": [ ],
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 42,
    "last_page": 3,
    "links": {
      "first": "http://127.0.0.1:8000/api/v1/products?page=1",
      "last": "http://127.0.0.1:8000/api/v1/products?page=3",
      "prev": null,
      "next": "http://127.0.0.1:8000/api/v1/products?page=2"
    }
  }
}
```

### Endpoints that paginate

| Endpoint | Default `per_page` |
|----------|--------------------|
| `GET /products` | 15 |
| `GET /categories/{id}/products` | 15 |
| `GET /stores/{id}/products` | 15 |
| `GET /products/{id}/reviews` | 15 |
| `GET /favorites` | 15 |
| `GET /orders` | 15 |
| `GET /orders/history` | 15 |
| `GET /conversations` | 15 |
| `GET /conversations/{id}/messages` | 30 |
| `GET /notifications` | 20 |

---

## 8. Filtering, Sorting & Searching

Primarily on **`GET /products`**.

### Searching

| Param | Type | Description |
|-------|------|-------------|
| `q` | string (max 200) | Search `name`, `brand`, `description` (LIKE) |

```http
GET /api/v1/products?q=sneakers
```

### Filtering

| Param | Type | Description |
|-------|------|-------------|
| `category_id` | integer | Exact category |
| `store_id` | integer | Exact store |
| `min_price` | number ≥ 0 | Minimum price |
| `max_price` | number ≥ 0 | Maximum price |
| `color_ids[]` | integer[] | Product must have one of these colors |
| `locations[]` | string[] | Store `location` must match |

```http
GET /api/v1/products?category_id=1&min_price=20&max_price=100&color_ids[]=1&color_ids[]=3&locations[]=Jakarta
```

### Sorting

| Param | Values | Behavior |
|-------|--------|----------|
| `sort` | `all` (default) | Newest by `id` desc |
| | `price_asc` | Price ascending |
| | `price_desc` | Price descending |
| | `rating` | `rating_avg` descending |
| | `newest` | `created_at` descending |

```http
GET /api/v1/products?sort=price_asc&q=shirt&per_page=20&page=1
```

### Combined example

```http
GET /api/v1/products?q=demo&category_id=2&store_id=1&min_price=40&max_price=80&sort=rating&per_page=10&page=1
```

---

## 9. Auth Endpoints

### Register

| | |
|--|--|
| **Endpoint** | `/register` |
| **Method** | `POST` |
| **Authentication** | Public |
| **Headers** | `Content-Type: application/json`, `Accept: application/json` |
| **Status codes** | `201`, `422`, `429` |

**Validation**

| Field | Rules |
|-------|--------|
| `name` | required, string, max 120 |
| `email` | nullable, email, unique, required without `phone` |
| `phone` | nullable, string, max 30, unique, required without `email` |
| `password` | required, confirmed, min 8, letters + numbers |
| `password_confirmation` | required with password |

**Request**

```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "phone": "+15551234567",
  "password": "password1",
  "password_confirmation": "password1"
}
```

**Response `201`**

```json
{
  "success": true,
  "message": "Registered successfully",
  "data": {
    "token": "1|...",
    "token_type": "Bearer",
    "user": { }
  }
}
```

**Error `422`**

```json
{
  "success": false,
  "message": "Validation failed.",
  "code": "validation_error",
  "errors": {
    "email": ["The email has already been taken."]
  },
  "data": null
}
```

---

### Login

| | |
|--|--|
| **Endpoint** | `/login` |
| **Method** | `POST` |
| **Authentication** | Public |
| **Headers** | `Content-Type: application/json` |
| **Status codes** | `200`, `422`, `429` |

**Validation**

| Field | Rules |
|-------|--------|
| `identifier` | required — email **or** phone |
| `password` | required |
| `device_name` | optional, max 100 |

**Request**

```json
{
  "identifier": "demo@kutuku.test",
  "password": "password"
}
```

**Response `200`** — same shape as register (`token` + `user`).

**Error `422`** — invalid credentials on `identifier`.

---

### Logout

| | |
|--|--|
| **Endpoint** | `/logout` |
| **Method** | `POST` |
| **Authentication** | Required |
| **Status codes** | `200`, `401` |

**Response `200`**

```json
{
  "success": true,
  "message": "Logged out successfully",
  "data": null
}
```

---

### Forgot password

| | |
|--|--|
| **Endpoint** | `/forgot-password` |
| **Method** | `POST` |
| **Authentication** | Public |
| **Status codes** | `200`, `422`, `429` |

**Validation:** `email` — required, email, exists in `users`.

**Request**

```json
{ "email": "demo@kutuku.test" }
```

**Response `200`**

```json
{
  "success": true,
  "message": "We have emailed your password reset link.",
  "data": null
}
```

---

### Reset password

| | |
|--|--|
| **Endpoint** | `/reset-password` |
| **Method** | `POST` |
| **Authentication** | Public |
| **Status codes** | `200`, `422`, `429` |

**Validation**

| Field | Rules |
|-------|--------|
| `email` | required, email |
| `token` | required |
| `password` | required, confirmed, password rules |
| `password_confirmation` | required |

**Request**

```json
{
  "email": "demo@kutuku.test",
  "token": "reset-token-from-email",
  "password": "newpass12",
  "password_confirmation": "newpass12"
}
```

---

## 10. Profile & Settings

### Get current user

| | |
|--|--|
| **Endpoint** | `/user` |
| **Method** | `GET` |
| **Authentication** | Required |
| **Status codes** | `200`, `401` |

**Response `200`** — `data` is [User](#user).

---

### Update profile

| | |
|--|--|
| **Endpoint** | `/user/profile` |
| **Method** | `PUT` |
| **Authentication** | Required |
| **Status codes** | `200`, `401`, `422` |

**Validation**

| Field | Rules |
|-------|--------|
| `name` | sometimes, string, max 120 |
| `email` | sometimes, email, unique (ignore self) |
| `phone` | nullable, unique (ignore self) |
| `avatar_path` | nullable, string |

**Request**

```json
{
  "name": "Jane Updated",
  "phone": "+15559876543"
}
```

---

### Change password

| | |
|--|--|
| **Endpoint** | `/user/password` |
| **Method** | `PUT` |
| **Authentication** | Required |
| **Status codes** | `200`, `401`, `422` |

**Validation**

| Field | Rules |
|-------|--------|
| `current_password` | required |
| `password` | required, confirmed, password rules |
| `password_confirmation` | required |

**Error `422`** — `code: invalid_current_password`

---

### Get settings

| | |
|--|--|
| **Endpoint** | `/user/settings` |
| **Method** | `GET` |
| **Authentication** | Required |
| **Status codes** | `200`, `401` |

---

### Update settings

| | |
|--|--|
| **Endpoint** | `/user/settings` |
| **Method** | `PUT` |
| **Authentication** | Required |
| **Status codes** | `200`, `401`, `422` |

**Validation (all optional)**

| Field | Rules |
|-------|--------|
| `language_code` | string, max 10 |
| `language_label` | string, max 100 |
| `push_notifications_enabled` | boolean |
| `email_notifications_enabled` | boolean |
| `order_updates_enabled` | boolean |
| `promo_notifications_enabled` | boolean |
| `biometric_enabled` | boolean |
| `two_factor_enabled` | boolean |
| `currency_code` | string, size 3 |

---

### List languages

| | |
|--|--|
| **Endpoint** | `/languages` |
| **Method** | `GET` |
| **Authentication** | Public |
| **Status codes** | `200` |

**Response**

```json
{
  "success": true,
  "message": null,
  "data": [
    { "code": "en", "label": "English" },
    { "code": "id", "label": "Bahasa Indonesia" },
    { "code": "ar", "label": "Arabic" },
    { "code": "zh", "label": "Chinese" }
  ]
}
```

---

## 11. Home & Catalog

### Home feed

| | |
|--|--|
| **Endpoint** | `/home` |
| **Method** | `GET` |
| **Authentication** | Public |
| **Status codes** | `200` |

**Response `data`**

```json
{
  "promotions": [ ],
  "categories": [ ],
  "new_arrivals": [ ]
}
```

---

### List categories

| | |
|--|--|
| **Endpoint** | `/categories` |
| **Method** | `GET` |
| **Authentication** | Public |
| **Status codes** | `200` |

Returns active root categories with `children`.

---

### Show category

| | |
|--|--|
| **Endpoint** | `/categories/{category}` |
| **Method** | `GET` |
| **Authentication** | Public |
| **Status codes** | `200`, `404` |

---

### Category products

| | |
|--|--|
| **Endpoint** | `/categories/{category}/products` |
| **Method** | `GET` |
| **Authentication** | Public |
| **Pagination** | `page`, `per_page` |
| **Status codes** | `200`, `404` |

---

## 12. Products & Stores

### List / search products

| | |
|--|--|
| **Endpoint** | `/products` |
| **Method** | `GET` |
| **Authentication** | Public |
| **Pagination** | Yes |
| **Searching** | `q` |
| **Filtering** | `category_id`, `store_id`, `min_price`, `max_price`, `color_ids[]`, `locations[]` |
| **Sorting** | `sort` |
| **Status codes** | `200`, `422` |

See [§8 Filtering, Sorting & Searching](#8-filtering-sorting--searching).

---

### Show product

| | |
|--|--|
| **Endpoint** | `/products/{product}` |
| **Method** | `GET` |
| **Authentication** | Optional (Bearer enables `is_favorite`) |
| **Status codes** | `200`, `404` |

---

### Product reviews

| | |
|--|--|
| **Endpoint** | `/products/{product}/reviews` |
| **Method** | `GET` |
| **Authentication** | Public |
| **Pagination** | Yes |
| **Status codes** | `200`, `404` |

---

### Create review

| | |
|--|--|
| **Endpoint** | `/reviews` |
| **Method** | `POST` |
| **Authentication** | Required |
| **Status codes** | `201`, `401`, `422` |

**Validation**

| Field | Rules |
|-------|--------|
| `product_id` | required, exists:products |
| `rating` | required, integer 1–5 |
| `body` | nullable, max 2000 |

---

### Show store

| | |
|--|--|
| **Endpoint** | `/stores/{store}` |
| **Method** | `GET` |
| **Authentication** | Public |
| **Status codes** | `200`, `404` |

---

### Store products

| | |
|--|--|
| **Endpoint** | `/stores/{store}/products` |
| **Method** | `GET` |
| **Authentication** | Public |
| **Pagination** | Yes |
| **Status codes** | `200`, `404` |

---

## 13. Favorites

### List favorites

| | |
|--|--|
| **Endpoint** | `/favorites` |
| **Method** | `GET` |
| **Authentication** | Required |
| **Pagination** | Yes |
| **Status codes** | `200`, `401` |

---

### Add favorite

| | |
|--|--|
| **Endpoint** | `/favorites` |
| **Method** | `POST` |
| **Authentication** | Required |
| **Status codes** | `201`, `401`, `422` |

**Validation:** `product_id` — required, exists.

**Error:** `already_favorited` (`422`)

---

### Remove favorite

| | |
|--|--|
| **Endpoint** | `/favorites/{product}` |
| **Method** | `DELETE` |
| **Authentication** | Required |
| **Status codes** | `200`, `401`, `404` |

Path `{product}` is the **product id**.

---

### Clear favorites

| | |
|--|--|
| **Endpoint** | `/favorites` |
| **Method** | `DELETE` |
| **Authentication** | Required |
| **Status codes** | `200`, `401` |

---

## 14. Cart

### Get cart

| | |
|--|--|
| **Endpoint** | `/cart` |
| **Method** | `GET` |
| **Authentication** | Required |
| **Status codes** | `200`, `401` |

---

### Add cart item

| | |
|--|--|
| **Endpoint** | `/cart/items` |
| **Method** | `POST` |
| **Authentication** | Required |
| **Status codes** | `201`, `401`, `422` |

**Validation**

| Field | Rules |
|-------|--------|
| `product_id` | required, exists |
| `quantity` | optional, 1–99 (default 1) |
| `color_name` | optional, max 50 |
| `size` | optional, max 20 |

**Error:** `insufficient_stock`

---

### Update cart item

| | |
|--|--|
| **Endpoint** | `/cart/items/{cartItem}` |
| **Method** | `PUT` |
| **Authentication** | Required |
| **Status codes** | `200`, `401`, `404`, `422` |

**Validation**

| Field | Rules |
|-------|--------|
| `quantity` | sometimes, 1–99 |
| `is_selected` | sometimes, boolean |

---

### Remove cart item

| | |
|--|--|
| **Endpoint** | `/cart/items/{cartItem}` |
| **Method** | `DELETE` |
| **Authentication** | Required |
| **Status codes** | `200`, `401`, `404` |

---

### Select all

| | |
|--|--|
| **Endpoint** | `/cart/select-all` |
| **Method** | `POST` |
| **Authentication** | Required |
| **Status codes** | `200`, `401`, `422` |

**Validation:** `selected` — required boolean.

```json
{ "selected": true }
```

---

## 15. Addresses & Payment Methods

### List addresses

| | |
|--|--|
| **Endpoint** | `/addresses` |
| **Method** | `GET` |
| **Authentication** | Required |
| **Status codes** | `200`, `401` |

---

### Create address

| | |
|--|--|
| **Endpoint** | `/addresses` |
| **Method** | `POST` |
| **Authentication** | Required |
| **Status codes** | `201`, `401`, `422` |

**Validation**

| Field | Rules |
|-------|--------|
| `label` | nullable, max 50 |
| `recipient_name` | required, max 120 |
| `phone` | required, max 30 |
| `line1` | required, max 255 |
| `line2` | nullable |
| `city` | required |
| `state` | nullable |
| `postal_code` | nullable |
| `country` | nullable, max 2 (default `US`) |
| `is_default` | boolean |

---

### Update address

| | |
|--|--|
| **Endpoint** | `/addresses/{address}` |
| **Method** | `PUT` |
| **Authentication** | Required |
| **Status codes** | `200`, `401`, `404`, `422` |

Same validation as create.

---

### Delete address

| | |
|--|--|
| **Endpoint** | `/addresses/{address}` |
| **Method** | `DELETE` |
| **Authentication** | Required |
| **Status codes** | `200`, `401`, `404` |

---

### List payment methods

| | |
|--|--|
| **Endpoint** | `/payment-methods` |
| **Method** | `GET` |
| **Authentication** | Required |
| **Status codes** | `200`, `401` |

`provider_token` is never returned.

---

### Add payment method

| | |
|--|--|
| **Endpoint** | `/payment-methods` |
| **Method** | `POST` |
| **Authentication** | Required |
| **Status codes** | `201`, `401`, `422` |

**Validation**

| Field | Rules |
|-------|--------|
| `type` | required: `card` \| `wallet` |
| `brand` | nullable |
| `last4` | nullable, size 4 |
| `holder_name` | nullable |
| `expiry_month` | nullable, 1–12 |
| `expiry_year` | nullable, ≥ 2024 |
| `provider_token` | required (vault token — never raw PAN) |
| `is_default` | boolean |

---

### Delete payment method

| | |
|--|--|
| **Endpoint** | `/payment-methods/{paymentMethod}` |
| **Method** | `DELETE` |
| **Authentication** | Required |
| **Status codes** | `200`, `401`, `404` |

---

## 16. Checkout & Orders

### Checkout

| | |
|--|--|
| **Endpoint** | `/checkout` |
| **Method** | `POST` |
| **Authentication** | Required |
| **Status codes** | `201`, `401`, `403`, `422` |

Places an order from **selected** cart items, decrements stock, creates tracking events, removes purchased lines.

**Validation**

| Field | Rules |
|-------|--------|
| `address_id` | required, exists:addresses |
| `payment_method_id` | required, exists:payment_methods |
| `shipping_fee` | optional, ≥ 0 |
| `discount` | optional, ≥ 0 |

**Request**

```json
{
  "address_id": 1,
  "payment_method_id": 1,
  "shipping_fee": 5,
  "discount": 0
}
```

**Errors:** `empty_checkout`, `invalid_address`, `invalid_payment_method`, `insufficient_stock`

---

### Active orders

| | |
|--|--|
| **Endpoint** | `/orders` |
| **Method** | `GET` |
| **Authentication** | Required |
| **Pagination** | Yes |
| **Status codes** | `200`, `401` |

Statuses: `pending`, `paid`, `processing`, `shipped`.

---

### Order history

| | |
|--|--|
| **Endpoint** | `/orders/history` |
| **Method** | `GET` |
| **Authentication** | Required |
| **Pagination** | Yes |
| **Status codes** | `200`, `401` |

Statuses: `delivered`, `cancelled`, `refunded`.

---

### Show order

| | |
|--|--|
| **Endpoint** | `/orders/{order}` |
| **Method** | `GET` |
| **Authentication** | Required (owner) |
| **Status codes** | `200`, `401`, `404` |

---

### Track order

| | |
|--|--|
| **Endpoint** | `/orders/{order}/track` |
| **Method** | `GET` |
| **Authentication** | Required (owner) |
| **Status codes** | `200`, `401`, `404` |

Returns order with `tracking_events`.

---

### Cancel order

| | |
|--|--|
| **Endpoint** | `/orders/{order}/cancel` |
| **Method** | `POST` |
| **Authentication** | Required (owner) |
| **Status codes** | `200`, `401`, `404`, `422` |

Cancellable only when status is `pending` or `paid`.  
**Error:** `cannot_cancel`

---

## 17. Messaging

### List conversations

| | |
|--|--|
| **Endpoint** | `/conversations` |
| **Method** | `GET` |
| **Authentication** | Required |
| **Pagination** | Yes |
| **Status codes** | `200`, `401` |

---

### Open / create conversation

| | |
|--|--|
| **Endpoint** | `/conversations` |
| **Method** | `POST` |
| **Authentication** | Required |
| **Status codes** | `201`, `401`, `422` |

**Validation:** `store_id` — required, exists:stores.

Returns existing thread if one already exists for user + store.

---

### List messages

| | |
|--|--|
| **Endpoint** | `/conversations/{conversation}/messages` |
| **Method** | `GET` |
| **Authentication** | Required (participant) |
| **Pagination** | Yes (`per_page` default 30) |
| **Status codes** | `200`, `401`, `404` |

---

### Send message

| | |
|--|--|
| **Endpoint** | `/conversations/{conversation}/messages` |
| **Method** | `POST` |
| **Authentication** | Required (participant) |
| **Status codes** | `201`, `401`, `404`, `422` |

**Validation**

| Field | Rules |
|-------|--------|
| `body` | required, max 5000 |
| `attachment_path` | nullable |

---

### Mark conversation read

| | |
|--|--|
| **Endpoint** | `/conversations/{conversation}/read` |
| **Method** | `POST` |
| **Authentication** | Required (participant) |
| **Status codes** | `200`, `401`, `404` |

---

## 18. Notifications

### List notifications

| | |
|--|--|
| **Endpoint** | `/notifications` |
| **Method** | `GET` |
| **Authentication** | Required |
| **Pagination** | Yes (default 20) |
| **Status codes** | `200`, `401` |

---

### Mark one read

| | |
|--|--|
| **Endpoint** | `/notifications/{notification}/read` |
| **Method** | `POST` |
| **Authentication** | Required (owner) |
| **Status codes** | `200`, `401`, `404` |

---

### Mark all read

| | |
|--|--|
| **Endpoint** | `/notifications/read-all` |
| **Method** | `POST` |
| **Authentication** | Required |
| **Status codes** | `200`, `401` |

---

## 19. RFID

### Verify member / open gate

| | |
|--|--|
| **Endpoint** | `/rfid/verify` |
| **Method** | `POST` |
| **Authentication** | Required |
| **Headers** | `Authorization`, `Content-Type: multipart/form-data` (if uploading image) or `application/json` |
| **Status codes** | `201`, `401`, `404`, `422` |

**Validation**

| Field | Rules |
|-------|--------|
| `member_id` | required — `member_code` or `rfid_uid` |
| `timestamp` | optional, date |
| `captured_image` | optional, image, max 5120 KB |

**JSON request**

```json
{
  "member_id": "MEM-1001",
  "timestamp": "2026-08-08T08:00:00+07:00"
}
```

**Multipart**

```http
POST /api/v1/rfid/verify
Authorization: Bearer {token}
Content-Type: multipart/form-data

member_id=MEM-1001
captured_image=<file>
```

**Response `201`**

```json
{
  "success": true,
  "message": "Verification Successful! Gate Opening. Happy Shopping!",
  "data": {
    "id": 1,
    "member_id": "MEM-1001",
    "gate_opened": true,
    "status": "verified",
    "message": "Verification Successful! Gate Opening. Happy Shopping!",
    "verified_at": "2026-08-08T01:00:00+00:00"
  }
}
```

**Error `404`:** `rfid_member_not_found`

---

### Show verification

| | |
|--|--|
| **Endpoint** | `/rfid/verifications/{id}` |
| **Method** | `GET` |
| **Authentication** | Required (owner) |
| **Status codes** | `200`, `401`, `404` |

---

## 20. Resource Schemas

### User

```json
{
  "id": 1,
  "name": "Demo User",
  "email": "demo@kutuku.test",
  "phone": "+10000000001",
  "avatar_url": null,
  "onboarding_completed_at": "2026-08-08T01:00:00+00:00",
  "member": {
    "id": 1,
    "display_name": "Demo User",
    "membership_tier": "gold",
    "points": 1200,
    "orders_count": 0,
    "favorites_count": 0,
    "followers_count": 0
  },
  "settings": {
    "language_code": "en",
    "language_label": "English",
    "push_notifications_enabled": true,
    "email_notifications_enabled": true,
    "order_updates_enabled": true,
    "promo_notifications_enabled": true,
    "biometric_enabled": false,
    "two_factor_enabled": false,
    "currency_code": "USD"
  },
  "created_at": "2026-08-08T01:00:00+00:00"
}
```

### Product

```json
{
  "id": 1,
  "name": "Demo Product 1",
  "slug": "demo-product-1-xxxx",
  "brand": "Kutuku",
  "description": "...",
  "price": 50.99,
  "discount_price": null,
  "currency": "USD",
  "stock": 50,
  "rating": 4.1,
  "review_count": 1,
  "image_url": "https://...",
  "images": ["https://..."],
  "category_id": 1,
  "store_id": 1,
  "store": { },
  "category": { },
  "colors": [{ "id": 1, "name": "Black", "hex": "#111111" }],
  "sizes": ["S", "M", "L", "XL"],
  "is_favorite": false
}
```

### Cart

```json
{
  "id": 1,
  "currency": "USD",
  "items": [
    {
      "id": 1,
      "product_id": 1,
      "name": "Demo Product 1",
      "unit_price": 50.99,
      "quantity": 2,
      "line_total": 101.98,
      "image_url": "https://...",
      "brand": "Kutuku",
      "color_name": "Black",
      "size": "M",
      "is_selected": true,
      "product": { }
    }
  ],
  "item_count": 2,
  "subtotal": 101.98
}
```

### Order

```json
{
  "id": 1,
  "order_number": "ORD-ABCDEF1234",
  "status": "paid",
  "subtotal": 101.98,
  "shipping_fee": 5,
  "discount": 0,
  "total": 106.98,
  "currency": "USD",
  "courier_name": null,
  "tracking_number": null,
  "placed_at": "2026-08-08T01:00:00+00:00",
  "items": [ ],
  "address": { },
  "payment_method": {
    "id": 1,
    "type": "card",
    "brand": "visa",
    "last4": "4242",
    "holder_name": "Demo User",
    "expiry_month": 12,
    "expiry_year": 2030,
    "is_default": true
  },
  "tracking_events": [
    {
      "id": 1,
      "title": "Order Placed",
      "description": "We have received your order.",
      "occurred_at": "2026-08-08T01:00:00+00:00",
      "is_completed": true,
      "sort_order": 1
    }
  ]
}
```

### Order status values

`pending` · `paid` · `processing` · `shipped` · `delivered` · `cancelled` · `refunded`

### Notification types

`system` · `order` · `promo` · `chat` · `payment`

---

## Endpoint Index

| Method | Endpoint | Auth |
|--------|----------|------|
| POST | `/register` | Public |
| POST | `/login` | Public |
| POST | `/forgot-password` | Public |
| POST | `/reset-password` | Public |
| POST | `/logout` | Sanctum |
| GET | `/user` | Sanctum |
| PUT | `/user/profile` | Sanctum |
| PUT | `/user/password` | Sanctum |
| GET | `/user/settings` | Sanctum |
| PUT | `/user/settings` | Sanctum |
| GET | `/languages` | Public |
| GET | `/home` | Public |
| GET | `/categories` | Public |
| GET | `/categories/{category}` | Public |
| GET | `/categories/{category}/products` | Public |
| GET | `/products` | Public |
| GET | `/products/{product}` | Optional |
| GET | `/products/{product}/reviews` | Public |
| POST | `/reviews` | Sanctum |
| GET | `/stores/{store}` | Public |
| GET | `/stores/{store}/products` | Public |
| GET | `/favorites` | Sanctum |
| POST | `/favorites` | Sanctum |
| DELETE | `/favorites/{product}` | Sanctum |
| DELETE | `/favorites` | Sanctum |
| GET | `/cart` | Sanctum |
| POST | `/cart/items` | Sanctum |
| PUT | `/cart/items/{cartItem}` | Sanctum |
| DELETE | `/cart/items/{cartItem}` | Sanctum |
| POST | `/cart/select-all` | Sanctum |
| GET | `/addresses` | Sanctum |
| POST | `/addresses` | Sanctum |
| PUT | `/addresses/{address}` | Sanctum |
| DELETE | `/addresses/{address}` | Sanctum |
| GET | `/payment-methods` | Sanctum |
| POST | `/payment-methods` | Sanctum |
| DELETE | `/payment-methods/{paymentMethod}` | Sanctum |
| POST | `/checkout` | Sanctum |
| GET | `/orders` | Sanctum |
| GET | `/orders/history` | Sanctum |
| GET | `/orders/{order}` | Sanctum |
| GET | `/orders/{order}/track` | Sanctum |
| POST | `/orders/{order}/cancel` | Sanctum |
| GET | `/conversations` | Sanctum |
| POST | `/conversations` | Sanctum |
| GET | `/conversations/{conversation}/messages` | Sanctum |
| POST | `/conversations/{conversation}/messages` | Sanctum |
| POST | `/conversations/{conversation}/read` | Sanctum |
| GET | `/notifications` | Sanctum |
| POST | `/notifications/{notification}/read` | Sanctum |
| POST | `/notifications/read-all` | Sanctum |
| POST | `/rfid/verify` | Sanctum |
| GET | `/rfid/verifications/{id}` | Sanctum |

---

## Flutter client notes

```sh
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

- Android emulator → host machine: `10.0.2.2`
- Physical device → use LAN IP of the machine running `php artisan serve`
- Always send `Accept: application/json`
- Persist Sanctum token via secure storage; attach as `Authorization: Bearer …`
