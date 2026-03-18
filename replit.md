# Exhibition Platform

## Overview
A production-ready Flutter web application for managing exhibitions, booths, suppliers, and bookings with strict role-based access control.

## Tech Stack
- **Frontend**: Flutter 3.32.0 (web target)
- **Backend/Database**: Firebase (Firestore, Auth, Storage, Messaging)
- **State Management**: Flutter Riverpod
- **Routing**: GoRouter
- **Code Generation**: Freezed, JSON Serializable, Riverpod Generator

## Architecture
Clean Architecture with feature-based modules under `lib/`:
- `core/` - Shared services, theme, utils, widgets
- `features/` - auth, admin, events, booths, bookings, chat, suppliers, jobs, profile
- `shared/` - Shared models, providers, widgets
- `router/` - GoRouter configuration

## User Roles
- **Admin**: Manage all users, system settings
- **Organizer**: Create/manage events and booths
- **Supplier**: Manage supplier profile, apply for jobs

## Firebase Project
- Project ID: `candoo-7ddfc`
- Auth, Firestore, Storage, Messaging all configured
- Firebase options in `lib/firebase_options.dart`

## Running the App
The workflow builds the Flutter web app and serves it on port 5000:
```
flutter build web --release && serve build/web -l 5000 -s
```
(`serve` installed globally via `npm install -g serve`)

## Known Fixes
- **Firestore settings conflict**: On web, `FirebaseFirestore.instance.settings` can only be set once. It is set exclusively in `lib/bootstrap.dart` immediately after `Firebase.initializeApp()` (with `persistenceEnabled: false`). The `firestoreProvider` in `lib/shared/providers/firebase_providers.dart` returns the instance directly without re-applying settings.
- **Auth notifier error handling**: `_checkAuth()` in `splash_screen.dart` has try-catch to ensure navigation to `/login` even if auth state reading throws.

## Deployment
Configured as a static site deployment:
- **Build**: `flutter build web --release`
- **Public Dir**: `build/web`

## Key Files
- `lib/main.dart` - App entry point
- `lib/bootstrap.dart` - Firebase initialization
- `lib/firebase_options.dart` - Firebase configuration
- `lib/app.dart` - Root app widget
- `pubspec.yaml` - Flutter dependencies
- `firebase.json` - Firebase project config
