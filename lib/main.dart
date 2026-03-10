import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bootstrap.dart';
import 'app.dart';
import 'core/config/environment.dart';

/// Main entry point - defaults to development environment
/// For different environments, use:
/// - main_development.dart
/// - main_staging.dart
/// - main_production.dart
void main() {
  bootstrap(
    (overrides) => ProviderScope(
      overrides: overrides,
      child: const ExhibitionPlatformApp(),
    ),
    environment: EnvironmentConfig.development,
  );
}
