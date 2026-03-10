# ExhibitConnect Deployment Guide

## Pre-Deployment Checklist

### Code Quality
- [ ] All tests passing (`flutter test`)
- [ ] No analyzer warnings (`flutter analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] Generated code up to date (`flutter pub run build_runner build`)

### Configuration
- [ ] Update version in `pubspec.yaml`
- [ ] Set correct environment (production)
- [ ] Firebase production project configured
- [ ] API keys and secrets secured
- [ ] Analytics enabled
- [ ] Crashlytics enabled

### Security
- [ ] No hardcoded secrets in code
- [ ] ProGuard/R8 rules configured (Android)
- [ ] Network security config set (Android)
- [ ] App Transport Security configured (iOS)
- [ ] Certificate pinning implemented (if required)

### Assets
- [ ] App icons generated for all sizes
- [ ] Splash screens configured
- [ ] Store screenshots prepared
- [ ] Feature graphics ready
- [ ] Privacy policy URL accessible
- [ ] Terms of service URL accessible

## Build Commands

### Development
```bash
flutter run -t lib/main.dart
```

### Staging
```bash
flutter run -t lib/main_staging.dart
```

### Production APK
```bash
flutter build apk --release -t lib/main_production.dart
```

### Production App Bundle (for Play Store)
```bash
flutter build appbundle --release -t lib/main_production.dart
```

### iOS Build
```bash
flutter build ios --release -t lib/main_production.dart
flutter build ipa --release -t lib/main_production.dart
```

### Web Build
```bash
flutter build web --release -t lib/main_production.dart
```

## Android Release

### 1. Generate Keystore (first time only)
```bash
keytool -genkey -v -keystore exhibition-platform.jks -keyalg RSA -keysize 2048 -validity 10000 -alias exhibition-platform
```

### 2. Configure key.properties
Create `android/key.properties`:
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=exhibition-platform
storeFile=<path-to-keystore>/exhibition-platform.jks
```

### 3. Build for Play Store
```bash
flutter build appbundle --release -t lib/main_production.dart
```

### 4. Upload to Play Console
- Upload AAB to Google Play Console
- Fill in store listing details
- Submit for review

## iOS Release

### 1. Configure Xcode
- Open `ios/Runner.xcworkspace` in Xcode
- Set Bundle Identifier
- Configure signing certificates
- Set deployment target

### 2. Archive and Upload
```bash
flutter build ipa --release -t lib/main_production.dart
```

Or use Xcode:
- Product > Archive
- Distribute App > App Store Connect

### 3. App Store Connect
- Create app in App Store Connect
- Upload build
- Fill in app information
- Submit for review

## Firebase Setup

### Development
```bash
flutterfire configure --project=exhibition-platform-dev
```

### Staging
```bash
flutterfire configure --project=exhibition-platform-staging
```

### Production
```bash
flutterfire configure --project=exhibition-platform-prod
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| FLAVOR | Build flavor (dev/staging/prod) | Yes |
| FIREBASE_PROJECT_ID | Firebase project ID | Yes |
| SENTRY_DSN | Sentry error tracking DSN | Production |

## Post-Deployment

### Monitoring
- [ ] Crashlytics receiving reports
- [ ] Analytics tracking events
- [ ] Performance monitoring active
- [ ] Server logs accessible

### Communication
- [ ] Notify stakeholders of release
- [ ] Update changelog
- [ ] Social media announcement (if applicable)

## Rollback Procedure

### Android
1. In Play Console, go to Release management
2. Select the previous release
3. Click "Promote to Production"

### iOS
1. In App Store Connect, select the app
2. Go to App Store > App Version
3. Remove current version from sale
4. Re-submit previous version

## Support Contacts

- **Technical Support**: tech@exhibitconnect.com
- **App Store Issues**: appstore@exhibitconnect.com
- **Emergency**: +1-XXX-XXX-XXXX
