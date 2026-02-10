# Setup Guide

## Prerequisites
- Flutter SDK (latest stable)
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

## Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Yaswanth1832K/Nestora-AI.git
   cd Nestora-AI
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Login to Firebase**
   ```bash
   firebase login
   ```

4. **Configure Firebase**
   Run the following command and select the shared Firebase project (`house-rental-ai`):
   ```bash
   flutterfire configure
   ```
   *This will generate `lib/firebase_options.dart`, `android/app/google-services.json`, and `ios/Runner/GoogleService-Info.plist` for you.*

5. **Run the App**
   ```bash
   flutter run
   ```

## Troubleshooting
If you encounter `TargetPlatform.android` errors, ensure `firebase_options.dart` was generated correctly by `flutterfire configure`.
