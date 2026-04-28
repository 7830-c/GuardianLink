<div align="center">

# 🛡️ GuardianLink

### *Real-Time Emergency Response & Safety Network*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20FCM-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Private-red)](LICENSE)

> **GuardianLink** is a role-based emergency response ecosystem connecting vulnerable individuals (Loved Ones) with their Guardians, nearby Volunteers, and Police — all in real time.

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Architecture](#-architecture)
- [Roles & Modules](#-roles--modules)
- [Technology Stack](#-technology-stack)
- [Firebase Data Model](#-firebase-data-model)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Running the App](#running-the-app)
- [Project Structure](#-project-structure)
- [Alert Lifecycle](#-alert-lifecycle)
- [Screenshots](#-screenshots)
- [Contributing](#-contributing)

---

## 🌐 Overview

GuardianLink is a Flutter-based personal safety application designed to provide a rapid, multi-layer emergency response network. When a **Loved One** triggers an SOS, a cascade of real-time notifications is dispatched simultaneously to:

1. **Family Guardians** — who can live-track location and coordinate care.
2. **Nearby Volunteers** — crowd-sourced responders within a 5 km radius.
3. **Local Police Station** — the nearest officers are dispatched via a command center.

The system ensures that no alert is ever silently dropped — all parties see incidents persist until they are explicitly **resolved**.

---

## ✨ Key Features

| Feature | Description |
|---|---|
| 🆘 **Hold-to-SOS Button** | Loved Ones press and hold for 3 seconds to trigger a verified SOS, preventing accidental alerts |
| 📍 **Real-Time Location Tracking** | GPS coordinates are written to Firestore every 2 minutes and are instantly visible on guardian/police maps |
| 🗺️ **Live Map Command Center** | Police and Guardians view named, color-coded map markers with one-tap navigation |
| 🔔 **Push Notifications (FCM)** | Foreground, background, and terminated-state notifications for all roles via Firebase Cloud Messaging |
| 👥 **Role-Based Access** | Four distinct user roles (Loved One, Family, Volunteer, Police) with isolated flows and dashboards |
| ⚡ **Persistent Alert Lifecycle** | Alerts remain visible and tracked as `pending → acknowledged → resolved`, never silently disappearing |
| 🙈 **Per-Volunteer Skip** | Volunteers can skip an alert for themselves without affecting other volunteers' feeds |
| 🧭 **Get Directions** | One-tap Google Maps navigation to an incident location from any map view |
| 📞 **Quick Help Actions** | Direct dial to Guardian, Police (100), or Medical (102) from the Loved One home screen |
| 🌙 **Dark Mode Design** | Premium "Vigilant Sentinel" dark theme with glassmorphism and smooth animations |

---

## 🏛️ Architecture

GuardianLink uses a **reactive, stream-based** architecture powered by Firestore real-time listeners.

```
┌─────────────────────────────────────────────────────────┐
│                    GuardianLink App                     │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐  │
│  │ Loved One│  │  Family  │  │Volunteer │  │ Police │  │
│  │  Module  │  │  Module  │  │  Module  │  │ Module │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └───┬────┘  │
│       │              │              │              │      │
│  ┌────▼──────────────▼──────────────▼──────────────▼──┐  │
│  │                  Services Layer                     │  │
│  │  AlertService · FirestoreService · AuthService      │  │
│  │  NotificationService · LocationService              │  │
│  └────────────────────┬────────────────────────────────┘  │
│                       │                                   │
│  ┌────────────────────▼────────────────────────────────┐  │
│  │               Firebase Backend                      │  │
│  │   Firestore (DB) · Auth · FCM (Push Notifications) │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

**Navigation** is handled by `go_router` with role-specific route trees. **State management** relies on Flutter's built-in `setState` combined with Firestore `StreamBuilder` widgets for reactive UI updates.

---

## 👤 Roles & Modules

### 🔴 Loved One
The individual whose safety is being monitored.

- **Home Screen** — Live location card, guardian safety net info, hold-to-SOS button with animated progress ring, and quick-call actions (Guardian / Police / Medical).
- **SOS Progress Screen** — Real-time confirmation that the alert has been dispatched.
- **Alert History** — View and manage past SOS events.
- **Profile** — Manage personal details and linked guardians.

### 🟢 Family (Guardian)
The trusted family member monitoring the Loved One.

- **Dashboard** — Stat overview (members, active alerts), emergency banner with "TRACK LOCATION" button, member card list with live SOS/Safe status.
- **Live Map** — Color-coded named markers (🔴 SOS / 🟢 Safe) with one-tap zoom and Google Maps navigation.
- **Alert History** — Full timeline of the family member's SOS events.
- **Profile Management** — Update family information.

### 🟡 Volunteer
A community first-responder who receives proximity-based alerts.

- **Active Alerts Feed** — Live stream of all `pending`/`acknowledged` alerts with Skip, Details, and Respond actions.
- **Per-Volunteer Skip** — Hides an alert only for that volunteer (persisted in Firestore's `skippedBy` array).
- **Incident Response Detail** — Full incident info with map and acknowledgement workflow.
- **Response History** — Track past responses.
- **Availability Toggle** — Switch between "Available" and "Off Duty" to control location broadcasting.

### 🔵 Police
Law enforcement with a tactical command view.

- **Police Command Center** — Live incident map with custom labeled markers, active incident list with `PENDING`/`EN ROUTE` status badges.
- **Incident Command View** — Full detail per incident with dispatch and resolve actions.
- **Incident Archive** — Historical record of all resolved incidents.
- **Officer Profile** — Manage officer and station information.

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart ≥ 3.0) |
| **Backend / Database** | Firebase Firestore (NoSQL, real-time) |
| **Authentication** | Firebase Auth (email/password) |
| **Push Notifications** | Firebase Cloud Messaging (FCM) + `flutter_local_notifications` |
| **Maps** | Google Maps Flutter (`google_maps_flutter`) |
| **Location** | Geolocator + Geocoding |
| **Navigation** | go_router 14.x |
| **State Management** | setState + StreamBuilder (reactive Firestore streams) |
| **Typography** | Google Fonts (Inter) |
| **UI** | Material 3 with a custom dark "Vigilant Sentinel" theme |

---

## 🗄️ Firebase Data Model

### `alerts` collection
```json
{
  "lovedOneId": "uid_of_loved_one",
  "location": { "latitude": 28.6139, "longitude": 77.2090 },
  "timestamp": "ServerTimestamp",
  "status": "pending | acknowledged | resolved",
  "skippedBy": ["volunteer_uid_1", "volunteer_uid_2"],
  "name": "Loved One Display Name"
}
```

### `lovedOne` collection
```json
{
  "name": "string",
  "phone": "string",
  "guardianIds": ["guardian_uid_1"],
  "location": "GeoPoint",
  "lastLocationUpdate": "ServerTimestamp",
  "isEmergency": false,
  "fcmToken": "string"
}
```

### `guardian` collection
```json
{
  "name": "string",
  "phone": "string",
  "fcmToken": "string"
}
```

### `volunteers` collection
```json
{
  "name": "string",
  "phone": "string",
  "location": "GeoPoint",
  "lastActive": "ServerTimestamp",
  "fcmToken": "string"
}
```

### `police` collection
```json
{
  "name": "string",
  "station": "string",
  "location": "GeoPoint",
  "fcmToken": "string"
}
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0.0
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.0.0
- A [Firebase project](https://console.firebase.google.com/) with Firestore, Auth, and FCM enabled
- A [Google Maps API Key](https://developers.google.com/maps/documentation/android-sdk/get-api-key) (Android & iOS)
- Android SDK or Xcode (for iOS)

### Setup

**1. Clone the repository**
```bash
git clone https://github.com/your-org/GuardianLink.git
cd GuardianLink
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Configure Firebase**

- Run [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) to generate `lib/firebase_options.dart`:
  ```bash
  flutterfire configure
  ```
- Or manually place your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the respective platform directories.

**4. Configure Google Maps**

Add your API key to:
- **Android**: `android/app/src/main/AndroidManifest.xml`
  ```xml
  <meta-data android:name="com.google.android.geo.API_KEY"
             android:value="YOUR_API_KEY"/>
  ```
- **iOS**: `ios/Runner/AppDelegate.swift`
  ```swift
  GMSServices.provideAPIKey("YOUR_API_KEY")
  ```

**5. Firestore Security Rules**

Ensure your Firestore rules allow authenticated reads/writes for each collection. A minimal example:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Running the App

```bash
# Development (hot reload)
flutter run

# Specific device
flutter run -d <device_id>

# Release build (Android APK)
flutter build apk --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point, Firebase & FCM init
├── firebase_options.dart        # Auto-generated Firebase config
│
├── router/
│   └── app_router.dart          # go_router route definitions (all 4 roles)
│
├── theme/
│   ├── app_theme.dart           # MaterialTheme configuration (dark)
│   └── app_colors.dart          # Design tokens (colors, surfaces)
│
├── services/
│   ├── alert_service.dart       # SOS trigger logic + multi-role FCM dispatch
│   ├── auth_service.dart        # Firebase Auth (sign in / sign up / sign out)
│   ├── firestore_service.dart   # Firestore CRUD + Haversine distance util
│   ├── location_service.dart    # Geolocator wrapper
│   ├── notification_service.dart# FCM + local notifications (foreground/background)
│   └── profile_registration_service.dart # New user profile creation
│
├── screens/
│   ├── splash_screen.dart
│   ├── role_selection_screen.dart
│   ├── error_screen.dart
│   │
│   ├── loved_one/
│   │   ├── loved_one_home_screen.dart        # SOS button, location, quick actions
│   │   ├── sos_alert_progress_screen.dart    # SOS dispatch progress
│   │   ├── loved_one_profile_screen.dart
│   │   ├── loved_one_login_screen.dart
│   │   └── loved_one_registration_screen.dart
│   │
│   ├── family/
│   │   ├── family_dashboard_screen.dart      # Member cards, emergency banner, map
│   │   ├── family_tracking_screen.dart
│   │   ├── emergency_alert_view_screen.dart
│   │   ├── alert_history_screen.dart
│   │   ├── family_profile_screen.dart
│   │   ├── family_profile_management_screen.dart
│   │   ├── family_settings_screen.dart
│   │   ├── family_login_screen.dart
│   │   └── family_registration_screen.dart
│   │
│   ├── volunteer/
│   │   ├── active_alerts_screen.dart         # Live alert feed, skip/respond
│   │   ├── incident_response_detail_screen.dart
│   │   ├── incident_acknowledged_screen.dart
│   │   ├── response_confirmed_screen.dart
│   │   ├── response_history_screen.dart
│   │   ├── volunteer_profile_screen.dart
│   │   ├── volunteer_settings_screen.dart
│   │   ├── volunteer_login_screen.dart
│   │   └── volunteer_registration_screen.dart
│   │
│   └── police/
│       ├── police_command_center_screen.dart # Dispatch map + active incident list
│       ├── incident_command_view_screen.dart # Per-incident dispatch/resolve
│       ├── police_incident_archive_screen.dart
│       ├── officer_profile_screen.dart
│       ├── police_settings_screen.dart
│       ├── police_login_screen.dart
│       └── police_registration_screen.dart
│
└── widgets/                     # Shared reusable UI components
```

---

## 🔄 Alert Lifecycle

```
Loved One holds SOS button (3s)
          │
          ▼
  AlertService.triggerSosAlert()
          │
          ├──▶ Firestore: alerts/{id}  {status: "pending"}
          │
          ├──▶ FCM → Family Guardians  ("SOS Alert!")
          ├──▶ FCM → Nearby Volunteers (<5km)  ("Volunteer SOS!")
          └──▶ FCM → Nearest Police Station  ("Police Dispatch SOS!")
                    │
        ┌───────────┴───────────┐
        │                       │
  Volunteer taps           Police taps
  "RESPOND"                "Dispatch"
        │                       │
        ▼                       ▼
  status: "acknowledged"   status: "acknowledged"
  (card stays visible,     (EN ROUTE badge shown)
   EN ROUTE badge shown)
        │                       │
        └───────────┬───────────┘
                    │
              Incident resolved
                    │
                    ▼
            status: "resolved"
      (Loved One / Police mark resolved)
```

---

## 🤝 Contributing

1. **Fork** the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a **Pull Request**

Please follow the existing code style and ensure all screens maintain the "Vigilant Sentinel" design system.

---

## 📄 License

This project is proprietary and not open for public distribution without explicit permission from the GuardianLink team.

---

<div align="center">

Built with ❤️ using Flutter & Firebase · *Because every second counts.*

</div>
