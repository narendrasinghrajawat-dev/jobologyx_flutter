import 'package:hive_flutter/hive_flutter.dart';

/// Lightweight local caching only — last-loaded jobs, cached profile, recent
/// searches, theme preference. Never the JWT (that lives in secure storage)
/// and never a source of truth: the backend always wins on refresh.
class HiveService {
  HiveService._();

  static const String cacheBoxName = "jobologyx_cache";

  static late Box _cacheBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox(cacheBoxName);
  }

  static Box get cacheBox => _cacheBox;

  // Keys
  static const String keyCachedJobs = "cached_jobs";
  static const String keyCachedProfile = "cached_profile";
  static const String keyRecentSearches = "recent_searches";
  static const String keyThemeMode = "theme_mode";

  static Future<void> put(String key, dynamic value) => _cacheBox.put(key, value);

  static T? get<T>(String key) => _cacheBox.get(key) as T?;

  static Future<void> delete(String key) => _cacheBox.delete(key);

  static Future<void> clear() => _cacheBox.clear();
}
