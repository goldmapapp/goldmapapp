# Auth Implementation Notes

Living log of decisions, milestones, and setup steps for the user system.
Update after each major step so another agent can continue easily.

## Current Direction

- Auth backend: Firebase (FlutterFire)
- Platforms: Web + Mobile (Windows desktop is dev-only)
- Goal: Store-compliant auth, fast approvals

## Milestones

### Milestone 1: Firebase scaffolding (done)

- Add FlutterFire deps
- Initialize Firebase in `main.dart`
- Add web config via env vars

### Milestone 2: Auth module scaffolding (done)

- Add Clean Architecture auth folders
- Add Firebase Auth remote + repo placeholders
- Add basic auth screens (login/signup/reset)
- Add AuthGate with TODO routing

### Milestone 3: FlutterFire config (done)

- Generated `lib/firebase_options.dart`
- Registered Android, iOS, and Web apps
- Added `android/app/google-services.json`

## Setup Checklist (to be filled by user)

- [ ] Firebase project created
- [ ] Web app added in Firebase
- [ ] `FIREBASE_API_KEY` (web)
- [ ] `FIREBASE_APP_ID` (web)
- [ ] `FIREBASE_MESSAGING_SENDER_ID` (web)
- [ ] `FIREBASE_PROJECT_ID` (web)
- [ ] `FIREBASE_AUTH_DOMAIN` (web)
- [ ] `FIREBASE_STORAGE_BUCKET` (web)
- [ ] Android `google-services.json`
- [ ] iOS `GoogleService-Info.plist`
- [ ] OAuth providers enabled (Google/Apple/Email)

## Notes / Decisions

- Firebase config comes from `lib/firebase_options.dart`.
- iOS plist may still need to be added to `ios/Runner/`.
- Windows builds skip Firebase init and use a no-op auth repo.
- Windows CMake disables Firebase plugins via `DISABLE_FIREBASE_WINDOWS`.
- Windows uses `generated_plugins_no_firebase.cmake` and
  `generated_plugin_registrant_no_firebase.cc` to avoid Firebase linkage.

