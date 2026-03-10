import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/error/exceptions.dart';

/// Local data source interface for SharedPreferences
abstract class LocalDataSource {
  /// Save string value
  Future<bool> setString(String key, String value);

  /// Get string value
  String? getString(String key);

  /// Save int value
  Future<bool> setInt(String key, int value);

  /// Get int value
  int? getInt(String key);

  /// Save bool value
  Future<bool> setBool(String key, bool value);

  /// Get bool value
  bool? getBool(String key);

  /// Save double value
  Future<bool> setDouble(String key, double value);

  /// Get double value
  double? getDouble(String key);

  /// Save string list
  Future<bool> setStringList(String key, List<String> value);

  /// Get string list
  List<String>? getStringList(String key);

  /// Save JSON object
  Future<bool> setJson(String key, Map<String, dynamic> value);

  /// Get JSON object
  Map<String, dynamic>? getJson(String key);

  /// Remove a key
  Future<bool> remove(String key);

  /// Clear all data
  Future<bool> clear();

  /// Check if key exists
  bool containsKey(String key);

  /// Get all keys
  Set<String> getKeys();
}

/// SharedPreferences implementation of LocalDataSource
class SharedPreferencesDataSource implements LocalDataSource {
  final SharedPreferences _prefs;

  SharedPreferencesDataSource(this._prefs);

  @override
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save string: $e',
        originalException: e,
      );
    }
  }

  @override
  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save int: $e',
        originalException: e,
      );
    }
  }

  @override
  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save bool: $e',
        originalException: e,
      );
    }
  }

  @override
  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save double: $e',
        originalException: e,
      );
    }
  }

  @override
  double? getDouble(String key) {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save string list: $e',
        originalException: e,
      );
    }
  }

  @override
  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await _prefs.setString(key, jsonString);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save JSON: $e',
        originalException: e,
      );
    }
  }

  @override
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to remove key: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear storage: $e',
        originalException: e,
      );
    }
  }

  @override
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  @override
  Set<String> getKeys() {
    return _prefs.getKeys();
  }
}

/// User preferences helper
class UserPreferences {
  final LocalDataSource _dataSource;

  UserPreferences(this._dataSource);

  /// Theme mode
  String? get themeMode => _dataSource.getString(StorageKeys.themeMode);
  Future<bool> setThemeMode(String mode) =>
      _dataSource.setString(StorageKeys.themeMode, mode);

  /// Locale
  String? get locale => _dataSource.getString(StorageKeys.locale);
  Future<bool> setLocale(String locale) =>
      _dataSource.setString(StorageKeys.locale, locale);

  /// Notifications enabled
  bool get notificationsEnabled =>
      _dataSource.getBool(StorageKeys.notificationsEnabled) ?? true;
  Future<bool> setNotificationsEnabled(bool enabled) =>
      _dataSource.setBool(StorageKeys.notificationsEnabled, enabled);

  /// Onboarding completed
  bool get hasCompletedOnboarding =>
      _dataSource.getBool(StorageKeys.hasCompletedOnboarding) ?? false;
  Future<bool> setOnboardingCompleted(bool completed) =>
      _dataSource.setBool(StorageKeys.hasCompletedOnboarding, completed);

  /// FCM token
  String? get fcmToken => _dataSource.getString(StorageKeys.fcmToken);
  Future<bool> setFcmToken(String token) =>
      _dataSource.setString(StorageKeys.fcmToken, token);

  /// Search history
  List<String> get searchHistory =>
      _dataSource.getStringList(StorageKeys.searchHistory) ?? [];
  Future<bool> setSearchHistory(List<String> history) =>
      _dataSource.setStringList(StorageKeys.searchHistory, history);
  Future<bool> addToSearchHistory(String query) async {
    final history = searchHistory;
    history.remove(query); // Remove if exists
    history.insert(0, query); // Add to front
    if (history.length > 10) {
      history.removeLast(); // Keep only last 10
    }
    return setSearchHistory(history);
  }
  Future<bool> clearSearchHistory() =>
      _dataSource.remove(StorageKeys.searchHistory);

  /// Clear all user preferences
  Future<bool> clearAll() => _dataSource.clear();
}
