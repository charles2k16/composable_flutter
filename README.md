# Composables IT — Flutter Client App

Client-facing mobile app for iPhone installment customers.

**iOS Bundle ID:** `com.composablesit.client`

## Screens
- **Login** — Phone number → 5-digit PIN (setup on first login, enter PIN after)
- **Home** — Balance overview, payment reference, next due date, how to pay
- **Payments** — Full payment history
- **Schedule** — Weekly payment calendar (paid / partial / overdue / next)
- **Notifications** — In-app inbox (SMS + push history)
- **Support** — Call, WhatsApp, SMS, FAQ

---

## Setup

### 1. Install Flutter
```bash
flutter doctor
```

### 2. Connect to your backend
The app defaults to production:
`https://installmngbackend-production.up.railway.app/api`

For local dev:
```bash
flutter run --dart-define=API_HOST=localhost
```

Or set a full URL:
```bash
flutter run --dart-define=API_BASE=http://10.0.2.2:4000/api
```

### 3. Install dependencies
```bash
flutter pub get
cd ios && pod install && cd ..
```

### 4. Firebase push notifications

See **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** for the full checklist.

Summary:
1. Register App ID `com.composablesit.client` in Apple Developer (enable Push Notifications)
2. Add iOS app in Firebase with the same bundle ID
3. Download `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`
4. Upload APNs auth key (.p8) in Firebase → Cloud Messaging
5. Set `FIREBASE_SERVICE_ACCOUNT` on Railway backend

The app runs without Firebase — push is skipped gracefully if not configured.

### 5. Build release
```bash
flutter build ios --release
```

Archive for TestFlight: open `ios/Runner.xcworkspace` in Xcode → Product → Archive.

### 6. Run the app
```bash
flutter run
```

Use a **physical iPhone** to test push notifications.

---

## Backend endpoints used
- `POST /api/client-auth/check-phone` — Verify phone is registered, returns `hasPin`
- `POST /api/client-auth/setup-pin` — First-time 5-digit PIN setup → JWT
- `POST /api/client-auth/login` — Verify PIN → JWT
- `GET  /api/client-auth/me` — Get full client profile (reference, next due date, schedule)
- `POST /api/client-auth/register-fcm-token` — Save device push token
- `GET  /api/client-auth/notifications` — In-app notification inbox

---

## How PIN Login Works
1. Client enters phone number registered in admin
2. Backend checks if PIN exists (`hasPin`)
3. **First time:** client sets a 5-digit PIN (entered twice to confirm) → logged in
4. **Returning:** client enters their 5-digit PIN → logged in
5. JWT stored securely → auto-login on next open

PIN is hashed on the server. After 5 failed attempts, login is locked for 15 minutes.

---

## Push notification events
Clients receive push (and SMS where configured) for:
- Payment confirmation
- Payment due reminders (day before and day of)
- Device locked / unlocked
- Installment fully paid

---

## Distributing to clients
**iOS:** Use TestFlight or enterprise distribution (bundle ID: `com.composablesit.client`)
