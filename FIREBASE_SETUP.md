# iOS Bundle + Firebase Push Setup Checklist

**Bundle ID:** `com.composablesit.client`  
**Apple Team ID:** `K89DY42MWX`

Use this checklist after the project bundle ID has been updated in Xcode.

---

## 1. Apple Developer — Register App ID

1. Open [Apple Developer → Identifiers](https://developer.apple.com/account/resources/identifiers/list)
2. Click **+** → **App IDs** → **App**
3. Description: `Composables IT Client`
4. Bundle ID: **Explicit** → `com.composablesit.client`
5. Capabilities: enable **Push Notifications**
6. Register

### APNs Authentication Key (do once per team)

1. [Keys](https://developer.apple.com/account/resources/authkeys/list) → **+**
2. Name: `Composables IT Push`
3. Enable **Apple Push Notifications service (APNs)**
4. Download the `.p8` file (only available once)
5. Note the **Key ID**

You will upload this key to Firebase in step 3.

---

## 2. Firebase — Add iOS app

1. [Firebase Console](https://console.firebase.google.com) → your project
2. **Add app** → iOS
3. **Apple bundle ID:** `com.composablesit.client`
4. Download **`GoogleService-Info.plist`**
5. Copy to:
   ```
   flutter_client/ios/Runner/GoogleService-Info.plist
   ```
6. In Xcode (`ios/Runner.xcworkspace`), confirm the file is in the **Runner** target

Optional CLI setup:
```bash
dart pub global activate flutterfire_cli
cd flutter_client
flutterfire configure
```

---

## 3. Firebase — Connect APNs

1. Firebase → **Project settings** → **Cloud Messaging**
2. Under **Apple app configuration** → Upload **APNs Authentication Key**
3. Upload your `.p8` file
4. Enter **Key ID** and **Team ID** (`K89DY42MWX`)

---

## 4. Backend — Railway env

Set on the backend (Railway):

```
FIREBASE_SERVICE_ACCOUNT={"type":"service_account",...}
```

Use the Firebase service account JSON (Project settings → Service accounts → Generate new private key). Paste as a single-line string.

---

## 5. Build iOS release

```bash
cd flutter_client
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release
```

Output: `build/ios/iphoneos/Runner.app`

### Archive for TestFlight

1. Open `ios/Runner.xcworkspace` in Xcode
2. **Runner** target → **Signing & Capabilities**
   - Team: your team
   - Bundle ID: `com.composablesit.client`
   - Push Notifications capability should be active (via entitlements)
3. **Product → Archive**
4. Distribute to TestFlight or export IPA

---

## 6. Verify push on a physical iPhone

Push does **not** work reliably on the iOS Simulator.

1. Install the app on a real device
2. Log in with a registered client phone + PIN
3. Confirm backend receives FCM token (`POST /client-auth/register-fcm-token`)
4. Record a payment in admin → client should get push + in-app notification

### Troubleshooting

| Issue | Fix |
|-------|-----|
| Firebase init fails | Add `GoogleService-Info.plist` to `ios/Runner/` |
| No push on device | Upload APNs key to Firebase; use physical device |
| Token not saved | Check API URL points to production backend |
| Push sent but not received | Verify `FIREBASE_SERVICE_ACCOUNT` on Railway |

---

## Entitlements (already configured)

| Build | File | APNs environment |
|-------|------|------------------|
| Debug / Profile | `Runner.entitlements` | `development` |
| Release | `Runner-Release.entitlements` | `production` |
