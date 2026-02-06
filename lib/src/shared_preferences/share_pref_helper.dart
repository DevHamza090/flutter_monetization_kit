import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  // Singleton pattern
  SharedPrefHelper._internal();
  static final SharedPrefHelper _instance = SharedPrefHelper._internal();
  factory SharedPrefHelper() => _instance;

  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance (call in main before runApp)
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save a string
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  /// Get a string
  String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Save a boolean
  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  /// Get a boolean
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Save an integer
  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  /// Get an integer
  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// Save an long
  Future<void> setLong(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  /// Get an long
  int? getLong(String key) {
    return _prefs?.getInt(key);
  }

  /// Save a double
  Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  /// Get a double
  double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  /// Save a string list
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  /// Get a string list
  List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  /// Remove a specific key
  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  /// Clear all stored data
  Future<void> clear() async {
    await _prefs?.clear();
  }

  /// Check if key exists
  bool contains(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  /// Check if it's user premium
  bool isPremium() {
    return _prefs?.getBool('is_premium') ?? true;
  }

  /// set user premium
  Future<void> setPremium(bool isPremium) async {
    await _prefs?.setBool('is_premium', isPremium);
  }
}
