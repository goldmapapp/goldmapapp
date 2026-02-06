Below is **the full, structured, modular, file-system-oriented, build-phase action plan**, covering:

* Architecture
* Modules & folders
* Data models
* Services
* Flows
* State management
* Security
* Build order

This *is* the blueprint you hand to a coding AI or dev team and say:
**“Build this.”**

Here it is.

---

# ✅ **GOLDMAP — ENGINEERING ACTION PLAN (MVP-READY, BUILDABLE)**

## 0. TECH STACK (Recommended)

**Flutter (iOS/Android)**
**Firebase** (or Supabase as alternative)

* Auth
* Firestore / PostgreSQL
* Storage
* Cloud Functions
* FCM for notifications

**Google Maps SDK**
**Biometric local auth** (via `local_auth`)

---

# 1. PROJECT ARCHITECTURE (“Modular & Secure”)

## Isolation Strategy (Easy to Weave Out)

Keep the entire user system in a **single top-level module** with a hard
boundary. All integration points go through a small adapter layer, so the
system can be removed without touching the rest of the app.

Key rules:

- No feature outside the user system imports its internals directly.
- Only a small set of shared interfaces live in `core/`.
- Use a single flag to disable/enable the module.

Use **Clean Architecture** with strict domain separation.

```
lib/
  core/
    errors/
    usecases/
    analytics/
    constants/
    theme/
  features/
    user_system/
      auth/
      user/
      verification/
      permissions/
      session/
      onboarding/
    map/
    listings/
    messaging/
    forum/
    events/
    admin/
    pricing/
  integrations/
    user_system/
      user_system_bridge.dart
      user_system_routes.dart
      user_system_guards.dart
  services/
    gps/
    biometrics/
    permissions/
    storage/
    networking/
  common_widgets/
  app/
    router.dart
    app.dart
```

Each feature folder contains:

```
data/
  datasources/
  models/
  repositories/
domain/
  entities/
  repositories/
  usecases/
presentation/
  screens/
  controllers/ (Riverpod or Bloc)
```

This is the **exact structure an AI coder can implement**.

---

# 2. USER SYSTEM MODULE — Specs for Coding

All user-related work lives under:

```
features/user_system/
```

This module contains auth, profile, verification, permissions, and session
logic, keeping the rest of the app untouched.

## 2.1 AUTH MODULE — Specs for Coding

### Requirements:

* Email/Password
* Google
* Apple
* Guest mode (no auth needed)
* Optional biometric unlock
* Device-level secure storage for token/prefs

### Files:

```
features/user_system/auth/
  data/datasources/auth_remote.dart
  data/models/user_model.dart
  data/repositories/auth_repo_impl.dart
  domain/entities/user.dart
  domain/usecases/
    sign_in_email.dart
    sign_in_google.dart
    sign_in_apple.dart
    sign_out.dart
    check_auth_state.dart
  presentation/screens/
    login_screen.dart
    onboarding_guard.dart
```

### User Model Fields:

```
user_id
email
auth_provider
tier
phone_verified
verification_status
account_type
created_at
```

---

# 3. USER TIERS — Full Coding Requirements

### Enum:

```
enum UserTier {
  guest,
  base,
  contact,
  businessApplicant,
  verified,
}
```

### Capability Mapping (in code):

```
class PermissionMatrix {
  static bool canPostForum(UserTier t) => t.index >= 2;
  static bool canDM(UserTier t) => t.index >= 2;
  static bool canCreateListing(UserTier t) => t.index >= 2;
  static bool canAppearOnMap(UserTier t) => t == UserTier.verified;
  static bool canCreateEvent(UserTier t) => t == UserTier.verified;
}
```

Simple, clean, enforceable.

---

# 4. VERIFICATION MODULE — Build Specs

### User uploads:

* ID image
* Selfie 1
* Selfie 2
* Optional business docs

### Structure:

```
features/user_system/verification/
  data/
    datasources/
      verification_remote.dart
    models/
      verification_request_model.dart
    repositories/
      verification_repo_impl.dart
  domain/
    entities/
    usecases/
      submit_verification.dart
      get_verification_status.dart
  presentation/
    screens/
      upload_id_screen.dart
      selfie_capture_screen.dart
      submission_success.dart
```

### Admin Panel API Route:

Cloud Function:

```
approveVerification(userId)
rejectVerification(userId)
```

---

# 5. MAP MODULE — Build Specs

### Uses:

* Google Maps SDK
* Firestore/DB for pins
* GPS for location center

### Files:

```
features/map/
  data/models/map_pin_model.dart
  data/datasources/map_remote.dart
  presentation/screens/map_screen.dart
  presentation/controllers/map_controller.dart
```

### Pin Model:

```
pin_id
user_id
lat
lng
category
verification_status
profile_summary
```

---

# 6. LISTINGS MODULE — Build Specs

### Features:

* View all listings (guest)
* Create listings (Tier 1+)
* Filter by local/online
* Price vs spot calculation

### Files:

```
features/listings/
  data/
    models/listing_model.dart
    datasources/listings_remote.dart
  domain/entities/listing.dart
  presentation/
    screens/listings_feed.dart
    screens/create_listing.dart
```

---

# 7. FORUM MODULE — Build Specs

### Guest:

* View only

### Tier 1+:

* Post/Comment

### Files:

```
features/forum/
  data/
  domain/
  presentation/
    screens/forum_feed.dart
    screens/create_post.dart
```

---

# 8. MESSAGING MODULE — Build Specs

### Tier 1+ only.

### Files:

```
features/messaging/
  data/models/message_model.dart
  data/datasources/messaging_remote.dart
  presentation/screens/chat_list.dart
  presentation/screens/chat_thread.dart
```

### Backend:

* Firestore subcollections
* FCM for DM notifications

---

# 9. EVENTS MODULE — Build Specs

### Everyone can view

### Only Tier 3 can create

### Files:

```
features/events/
  data/models/event_model.dart
  datasources/events_remote.dart
  presentation/screens/events_feed.dart
  presentation/screens/create_event.dart
```

---

# 10. BIOMETRIC MODULE — Build Specs

### Purpose:

Optional: lock app with FaceID/TouchID.

### Files:

```
services/biometrics/
  biometrics_service.dart
```

Uses plugin:
`local_auth`

---

# 11. GPS MODULE — Build Specs

### Purpose:

* Center map on user location
* Sort listings by distance
* Show events near you

### Files:

```
services/gps/gps_service.dart
```

Uses:
`geolocator`

---

# 12. ADMIN PANEL — Build Specs

Hosted separately (Flutter Web or React Web).

### Must include:

* Verification dashboard
* Show uploaded docs
* Approve / reject
* View user list
* Suspend / flag accounts
* Delete listings/events/posts

### API:

Cloud Functions:

```
approveVerification()
rejectVerification()
adminSuspendUser()
adminRemoveListing()
adminRemoveEvent()
```

---

# 13. SECURITY BASICS (Coding Requirements)

## App Store / Play Store Compliance (Fast Approval)

- Use a proven auth backend (Firebase Auth or Supabase)
- Store tokens in secure storage (Keychain/Keystore)
- Do not store plaintext credentials
- Request only permissions you actually use
- Provide Privacy Policy + Terms links in app and store listing
- Include account deletion path (self-serve or support request)
- Provide data export path or policy statement
- Clearly explain any ID/selfie collection and its purpose

These items are explicitly to meet app store compliance expectations and
reduce review risk.

### 1. App-side

* Do NOT store tokens unencrypted
* Use SecureStorage for sensitive local data
* Biometrics optional wrapper

### 2. Server-side rules

**Role-based access with custom claims**

```
role: "user" | "admin"
tier: 0, 1, 2, 3
```

### 3. Storage rules

Images (ID, selfies) stored in:

```
/verification/userID/*
```

with strict access:

* Only admin & user owner can read

---

# 14. BUILD ORDER (How the coding AI should execute)

This is the step-by-step order for coding:

### **PHASE 1 – App Shell + Guest Mode**

* Routing
* Tabs: Map, Prices, Listings, Events
* Guest read-only version

### **PHASE 2 – User System Bootstrap**

* Create `features/user_system/` and `integrations/user_system/`
* Add bridges/guards and minimal shared interfaces in `core/`

### **PHASE 3 – Auth**

* Email/Google/Apple
* User model + tier enum
* Auth state listener

### **PHASE 4 – Tiers & Permissions**

* Implement PermissionMatrix
* Lock interactive actions behind tier checks

### **PHASE 5 – Listings**

* Feed + filtering
* Create listing (Tier 1+)

### **PHASE 6 – Forum + Messaging**

* Forum read/write
* DM via Firestore

### **PHASE 7 – Verification System**

* Upload ID/selfies
* Admin review path
* Tier promotion to verified

### **PHASE 8 – Map Listings (Verified Only)**

* Pin creation
* Pin visibility rules
* Map filters

### **PHASE 9 – Events**

* Public feed (everyone)
* Event creation (verified)

### **PHASE 10 – Biometric Lock**

* Optional FaceID/TouchID lock screen

### **PHASE 11 – Admin Panel**

* Verification queue
* Approve/reject
* Moderation tools
