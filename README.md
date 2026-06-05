# Composables IT — Flutter Client App

Client-facing mobile app for iPhone installment customers.

## Screens
- **Login** — Phone number entry + OTP verification via SMS
- **Home** — Balance overview, payment progress, device info
- **Payments** — Full payment history
- **Schedule** — Weekly payment calendar (paid/pending/next)
- **Support** — Call, WhatsApp, SMS, FAQ

---

## Setup

### 1. Install Flutter
```bash
# Check: https://flutter.dev/docs/get-started/install
flutter doctor
```

### 2. Connect to your backend
Open `lib/core/api/api_client.dart` and update:
```dart
static const String baseUrl = 'http://YOUR_BACKEND_URL/api';
```

For local dev: `http://10.0.2.2:4000/api` (Android emulator)
For local dev: `http://localhost:4000/api` (iOS simulator)
For production: `https://your-railway-app.railway.app/api`

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Run the app
```bash
# Android emulator
flutter run

# iOS simulator
flutter run -d ios

# Release build (Android APK)
flutter build apk --release

# Release build (iOS IPA)
flutter build ios --release
```

---

## Key Files
```
lib/
├── main.dart                          ← Entry point
├── core/
│   ├── api/api_client.dart            ← All API calls + token storage
│   ├── models/models.dart             ← Client, Device, Payment models
│   ├── services/auth_service.dart     ← Login/logout logic
│   └── theme/app_theme.dart           ← Colors, fonts, styles
├── features/
│   ├── auth/
│   │   ├── phone_screen.dart          ← Step 1: Enter phone
│   │   └── otp_screen.dart            ← Step 2: Enter OTP
│   ├── home/home_screen.dart          ← Dashboard + bottom nav
│   ├── payments/payments_screen.dart  ← Payment history
│   ├── schedule/schedule_screen.dart  ← Payment calendar
│   └── support/support_screen.dart    ← Contact + FAQ
└── shared/widgets/widgets.dart        ← Reusable UI components
```

---

## Backend endpoints used
- `POST /api/client-auth/request-otp` — Send OTP to phone
- `POST /api/client-auth/verify-otp` — Verify OTP → get JWT
- `GET  /api/client-auth/me` — Get full client profile

---

## How OTP Login Works
1. Client opens app → enters phone number
2. App calls backend → backend sends SMS via Arkesel
3. Client enters 6-digit code
4. Backend verifies → returns 30-day JWT
5. Token stored securely → auto-login on next open

In **development** (NODE_ENV != production), the OTP code is returned
in the API response and shown on screen for easy testing.

---

## Distributing to clients
**Android:** Share the APK file directly via WhatsApp
**iOS:** Use TestFlight (requires Apple Developer account) or enterprise distribution
