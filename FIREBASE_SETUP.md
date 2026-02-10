# Firebase Setup

Before running the app on a device or emulator, configure Firebase:

## 1. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

## 2. Login to Firebase (if not already)

```bash
firebase login
```

## 3. Configure FlutterFire

From the project root:

```bash
flutterfire configure
```

This will:

- Create or select a Firebase project
- Register Android/iOS/Web apps
- Generate `lib/firebase_options.dart` with your project credentials
- Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

## 4. Enable Firebase Services

In [Firebase Console](https://console.firebase.google.com):

- **Authentication** — Enable Email/Password and Google sign-in
- **Firestore** — Create database (start in test mode for dev)
- **Storage** — Create default bucket
- **Cloud Messaging** — Enabled by default for FCM

After setup, run `flutter run` to start the app.
