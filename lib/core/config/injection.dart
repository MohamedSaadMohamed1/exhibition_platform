import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/providers/firebase_providers.dart';

// Re-export firebase providers for backward compatibility
export '../../shared/providers/firebase_providers.dart';

/// Initialize all dependencies
Future<List<Override>> initializeDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  return [
    sharedPreferencesProvider.overrideWithValue(sharedPreferences),
  ];
}
