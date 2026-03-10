import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bootstrap.dart';
import 'app.dart';
import 'core/config/environment.dart';

void main() {
  bootstrap(
    (overrides) => ProviderScope(
      overrides: overrides,
      child: const ExhibitionPlatformApp(),
    ),
    environment: EnvironmentConfig.staging,
  );
}
