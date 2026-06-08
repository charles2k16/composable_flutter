# Composables IT — Flutter Client App

Client-facing mobile app for iPhone installment customers.

## Screens
- **Login** — Phone number → 5-digit PIN (setup on first login, enter PIN after)
- **Home** — Balance overview, payment progress, device info
- **Payments** — Full payment history
- **Schedule** — Weekly payment calendar (paid/pending/next)
- **Support** — Call, WhatsApp, SMS, FAQ

---

## Setup

### 1. Install Flutter
```bash
flutter doctor
```

### 2. Connect to your backend
Open `lib/core/api/api_client.dart` and update:
```dart
static const String baseUrl = 'http://YOUR_BACKEND_URL/api';
```

For local dev: `http://10.0.2.2:4000/api` (Android emulator)
For local dev: `http://localhost:4000/api` (iOS simulator)

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Run the app
```bash
flutter run
```

---

## Backend endpoints used
- `POST /api/client-auth/check-phone` — Verify phone is registered, returns `hasPin`
- `POST /api/client-auth/setup-pin` — First-time 5-digit PIN setup → JWT
- `POST /api/client-auth/login` — Verify PIN → JWT
- `GET  /api/client-auth/me` — Get full client profile

---

## How PIN Login Works
1. Client enters phone number registered in admin
2. Backend checks if PIN exists (`hasPin`)
3. **First time:** client sets a 5-digit PIN (entered twice to confirm) → logged in
4. **Returning:** client enters their 5-digit PIN → logged in
5. JWT stored securely → auto-login on next open

PIN is hashed on the server. After 5 failed attempts, login is locked for 15 minutes.

---

## Distributing to clients
**Android:** Share the APK file directly via WhatsApp
**iOS:** Use TestFlight or enterprise distribution
