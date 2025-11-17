# Play5

Play5 is a Flutter mobile app for creating and joining 5-a-side football matches inside a single residential compound. It ships with a clean architecture layout, Arabic/English localization, RTL support, Firebase-ready repositories, and a simple team balancer.

## Getting started

### Prerequisites
- Flutter (latest stable). Run `flutter doctor` to confirm toolchains for Android/iOS.
- Dart >= 3.3.0.

### Install dependencies
```bash
flutter pub get
```

### Run the app
```bash
flutter run
```

### Firebase configuration
The app uses Firebase by default (toggle `AppConfig.useMockData` if you need offline mocks).

1) Create a Firebase project and enable **Phone Authentication**, **Cloud Firestore**, and **FCM**.
2) Add Android/iOS apps with your package IDs (e.g., `com.play5.app`).
3) Run `flutterfire configure` to generate `lib/firebase_options.dart` (replace the placeholder file).
4) Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to their platform folders.
5) Ensure `main()` calls Firebase initialization (already wired through `initFirebase`).
6) Deploy or set Firestore security rules (see below).

### Suggested Firestore security rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /pitches/{pitchId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }

    match /matches/{matchId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && (
        request.resource.data.creatorId == request.auth.uid ||
        request.auth.token.admin == true
      );
    }

    match /notifications/{noteId} {
      allow read, write: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

### Building
- Android APK: `flutter build apk`
- Android App Bundle: `flutter build appbundle`
- iOS (simulator): `flutter build ios --simulator`
- iOS (release/TestFlight): `flutter build ipa` (requires Xcode, signing, and a macOS host).
- CI/CD: The project structure is compatible with Codemagic workflows for Android/iOS publishing.

### Data model (Firestore collections)
- `users/{userId}`: phone, name, age, preferredFoot, positions, skillLevel, preferredDays, preferredTimeWindows, role, isApproved, timestamps.
- `pitches/{pitchId}`: name, description, locationDescription, isActive, timestamps.
- `matches/{matchId}`: creatorId, pitchId, dateTimeStart, durationMinutes, maxPlayers, visibility, status, playersJoined, teamA, teamB, timestamps.
- `notifications/{notificationId}` (optional per user): userId, title, body, type, matchId, isRead, createdAt.

## Architecture
- **State management:** `flutter_bloc`.
- **Navigation:** simple imperative navigation with ready-to-adapt structure.
- **Layers:**
  - `core/`: theme, localization, shared widgets, utilities.
  - `features/`: `auth`, `profile`, `matches`, `pitches`, `admin`, `notifications` (placeholder).
  - `config/`: toggles and environment hints.

### Key components
- `MockAuthRepository`, `MockProfileRepository`, `MockMatchRepository`, `MockPitchRepository`: in-memory repositories that mimic Firebase APIs and enable offline demos.
- `TeamBalancer`: deterministic team splitting based on skill and positions when a match fills.
- `LanguageCubit` + `AppLocalizations`: JSON-driven localization without code generation.

### Adding features
- Create domain entities and repository contracts under `features/<feature>/domain`.
- Implement data sources (Firebase or REST) under `features/<feature>/data`.
- Add blocs/cubits under `presentation/bloc` and UI under `presentation/views`.
- Register repositories and blocs in `main.dart` via `MultiRepositoryProvider` / `MultiBlocProvider`.

### Testing the team balancer
Add unit tests under `test/` using `flutter test` to validate balancing logic for various skill/position combinations.

## RTL and localization
- JSON translations live in `assets/l10n/en.json` and `assets/l10n/ar.json`.
- The app enforces RTL when Arabic is selected and persists language via `shared_preferences`.

## Notes
- OTP is mocked client-side. Swap `MockAuthRepository` with Firebase Auth for production.
- Admin tab exposes pitch management and can be extended to user approvals and match moderation.
- UI uses Material 3 with the Play5 gold/charcoal palette and is ready for further theming.
