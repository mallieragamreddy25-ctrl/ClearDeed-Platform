import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/property.dart';
import '../utils/app_logger.dart';

/// Local storage service for Hive and SharedPreferences
/// Handles user data, tokens, app settings, and offline caching
class StorageService {
  static late SharedPreferences _prefs;
  static late Box<dynamic> _hiveBox;

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_profile';
  static const String _filtersKey = 'property_filters';
  static const String _favoritesKey = 'favorite_properties';
  static const String _hiveBoxName = 'cleardeed_storage';

  /// Initialize storage service
  /// Call once on app startup
  static Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      _prefs = await SharedPreferences.getInstance();
      _hiveBox = await Hive.openBox<dynamic>(_hiveBoxName);
      AppLogger.info('Storage service initialized');
    } catch (e) {
      AppLogger.error('Storage initialization error: $e', e);
      rethrow;
    }
  }

  // ==================== Authentication ====================

  /// Save authentication token
  static Future<void> saveToken(String token) async {
    try {
      await _prefs.setString(_tokenKey, token);
      await _hiveBox.put(_tokenKey, token);
      AppLogger.debug('Token saved');
    } catch (e) {
      AppLogger.error('Error saving token: $e');
    }
  }

  /// Get stored authentication token
  static String? getToken() {
    try {
      return _prefs.getString(_tokenKey);
    } catch (e) {
      AppLogger.error('Error retrieving token: $e');
      return null;
    }
  }

  /// Check if token exists
  static bool hasToken() {
    return _prefs.containsKey(_tokenKey);
  }

  /// Clear authentication token
  static Future<void> clearToken() async {
    try {
      await _prefs.remove(_tokenKey);
      await _hiveBox.delete(_tokenKey);
      AppLogger.debug('Token cleared');
    } catch (e) {
      AppLogger.error('Error clearing token: $e');
    }
  }

  // ==================== User Data ====================

  /// Save user profile
  static Future<void> saveUser(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _prefs.setString(_userKey, userJson);
      await _hiveBox.put(_userKey, user.toJson());
      AppLogger.debug('User profile saved');
    } catch (e) {
      AppLogger.error('Error saving user: $e');
    }
  }

  /// Get stored user profile
  static User? getUser() {
    try {
      final userJson = _prefs.getString(_userKey);
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      AppLogger.error('Error retrieving user: $e');
    }
    return null;
  }

  /// Check if user exists
  static bool hasUser() {
    return _prefs.containsKey(_userKey);
  }

  /// Clear user profile
  static Future<void> clearUser() async {
    try {
      await _prefs.remove(_userKey);
      await _hiveBox.delete(_userKey);
      AppLogger.debug('User data cleared');
    } catch (e) {
      AppLogger.error('Error clearing user: $e');
    }
  }

  /// Check if session is valid
  static bool isSessionValid() {
    return hasToken() && hasUser();
  }

  // ==================== Property Filters ====================

  /// Save property filters
  static Future<void> savePropertyFilters(Map<String, dynamic> filters) async {
    try {
      final filtersJson = jsonEncode(filters);
      await _prefs.setString(_filtersKey, filtersJson);
      await _hiveBox.put(_filtersKey, filters);
      AppLogger.debug('Property filters saved');
    } catch (e) {
      AppLogger.error('Error saving filters: $e');
    }
  }

  /// Get stored property filters
  static Map<String, dynamic>? getPropertyFilters() {
    try {
      final filtersJson = _prefs.getString(_filtersKey);
      if (filtersJson != null) {
        return Map<String, dynamic>.from(jsonDecode(filtersJson));
      }
    } catch (e) {
      AppLogger.error('Error retrieving filters: $e');
    }
    return null;
  }

  /// Clear property filters
  static Future<void> clearPropertyFilters() async {
    try {
      await _prefs.remove(_filtersKey);
      await _hiveBox.delete(_filtersKey);
      AppLogger.debug('Property filters cleared');
    } catch (e) {
      AppLogger.error('Error clearing filters: $e');
    }
  }

  // ==================== Cached Properties ====================

  /// Cache property list
  static Future<void> cacheProperties(
    List<Property> properties,
    String cacheKey,
  ) async {
    try {
      final propertiesJson = properties.map((p) => p.toJson()).toList();
      await _hiveBox.put('cached_properties_$cacheKey', propertiesJson);
      await _hiveBox.put(
        'cached_properties_${cacheKey}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
      AppLogger.debug('Cached ${properties.length} properties');
    } catch (e) {
      AppLogger.error('Error caching properties: $e');
    }
  }

  /// Get cached properties
  static List<Property>? getCachedProperties(String cacheKey) {
    try {
      final propertiesJson = _hiveBox.get('cached_properties_$cacheKey');
      if (propertiesJson != null && propertiesJson is List) {
        return (propertiesJson as List)
            .map((item) => Property.fromJson(item))
            .toList();
      }
    } catch (e) {
      AppLogger.error('Error retrieving cached properties: $e');
    }
    return null;
  }

  /// Check if cache is valid
  static bool isCacheValid(String cacheKey, {int maxAgeMinutes = 60}) {
    try {
      final timestamp = _hiveBox.get('cached_properties_${cacheKey}_timestamp');
      if (timestamp != null && timestamp is int) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final difference = DateTime.now().difference(cacheTime).inMinutes;
        return difference < maxAgeMinutes;
      }
    } catch (e) {
      AppLogger.error('Error checking cache validity: $e');
    }
    return false;
  }

  /// Clear cached properties
  static Future<void> clearCachedProperties(String cacheKey) async {
    try {
      await _hiveBox.delete('cached_properties_$cacheKey');
      await _hiveBox.delete('cached_properties_${cacheKey}_timestamp');
      AppLogger.debug('Cached properties cleared');
    } catch (e) {
      AppLogger.error('Error clearing cached properties: $e');
    }
  }

  // ==================== Favorite Properties ====================

  /// Add property to favorites
  static Future<void> addFavorite(int propertyId) async {
    try {
      final favorites = getFavorites();
      if (!favorites.contains(propertyId)) {
        favorites.add(propertyId);
        await _prefs.setStringList(
          _favoritesKey,
          favorites.map((id) => id.toString()).toList(),
        );
        AppLogger.debug('Added property $propertyId to favorites');
      }
    } catch (e) {
      AppLogger.error('Error adding favorite: $e');
    }
  }

  /// Remove property from favorites
  static Future<void> removeFavorite(int propertyId) async {
    try {
      final favorites = getFavorites();
      favorites.remove(propertyId);
      await _prefs.setStringList(
        _favoritesKey,
        favorites.map((id) => id.toString()).toList(),
      );
      AppLogger.debug('Removed property $propertyId from favorites');
    } catch (e) {
      AppLogger.error('Error removing favorite: $e');
    }
  }

  /// Get all favorite property IDs
  static List<int> getFavorites() {
    try {
      final favList = _prefs.getStringList(_favoritesKey);
      if (favList != null) {
        return favList.map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toList();
      }
    } catch (e) {
      AppLogger.error('Error retrieving favorites: $e');
    }
    return [];
  }

  /// Check if property is favorited
  static bool isFavorited(int propertyId) {
    return getFavorites().contains(propertyId);
  }

  /// Clear all favorites
  static Future<void> clearFavorites() async {
    try {
      await _prefs.remove(_favoritesKey);
      AppLogger.debug('All favorites cleared');
    } catch (e) {
      AppLogger.error('Error clearing favorites: $e');
    }
  }

  // ==================== App Settings ====================

  /// Save theme mode
  static Future<void> setThemeMode(String themeMode) async {
    try {
      await _prefs.setString('theme_mode', themeMode);
      AppLogger.debug('Theme mode set to: $themeMode');
    } catch (e) {
      AppLogger.error('Error setting theme: $e');
    }
  }

  /// Get theme mode
  static String getThemeMode() {
    return _prefs.getString('theme_mode') ?? 'light';
  }

  /// Save app language
  static Future<void> setLanguage(String language) async {
    try {
      await _prefs.setString('app_language', language);
      AppLogger.debug('Language set to: $language');
    } catch (e) {
      AppLogger.error('Error setting language: $e');
    }
  }

  /// Get app language
  static String getLanguage() {
    return _prefs.getString('app_language') ?? 'en';
  }

  /// Save last viewed property
  static Future<void> setLastViewedProperty(int propertyId) async {
    try {
      await _prefs.setInt('last_viewed_property', propertyId);
    } catch (e) {
      AppLogger.error('Error setting last viewed property: $e');
    }
  }

  /// Get last viewed property
  static int? getLastViewedProperty() {
    final id = _prefs.getInt('last_viewed_property');
    return id != null && id > 0 ? id : null;
  }

  // ==================== Form Drafts ====================

  /// Save form draft
  static Future<void> saveFormDraft(String formKey, Map<String, dynamic> data) async {
    try {
      final draftJson = jsonEncode(data);
      await _prefs.setString('draft_$formKey', draftJson);
      AppLogger.debug('Form draft saved: $formKey');
    } catch (e) {
      AppLogger.error('Error saving form draft: $e');
    }
  }

  /// Get form draft
  static Map<String, dynamic>? getFormDraft(String formKey) {
    try {
      final draftJson = _prefs.getString('draft_$formKey');
      if (draftJson != null) {
        return Map<String, dynamic>.from(jsonDecode(draftJson));
      }
    } catch (e) {
      AppLogger.error('Error retrieving form draft: $e');
    }
    return null;
  }

  /// Clear form draft
  static Future<void> clearFormDraft(String formKey) async {
    try {
      await _prefs.remove('draft_$formKey');
      AppLogger.debug('Form draft cleared: $formKey');
    } catch (e) {
      AppLogger.error('Error clearing form draft: $e');
    }
  }

  /// Clear all form drafts
  static Future<void> clearAllDrafts() async {
    try {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('draft_')) {
          await _prefs.remove(key);
        }
      }
      AppLogger.debug('All form drafts cleared');
    } catch (e) {
      AppLogger.error('Error clearing all drafts: $e');
    }
  }

  // ==================== Session Management ====================

  /// Logout user - clear all sensitive data
  static Future<void> logout() async {
    try {
      await clearToken();
      await clearUser();
      await clearPropertyFilters();
      await clearFavorites();
      await clearAllDrafts();
      AppLogger.info('User logged out');
    } catch (e) {
      AppLogger.error('Error during logout: $e');
    }
  }

  /// Clear all cached data
  static Future<void> clearAllCachedData() async {
    try {
      final keys = _hiveBox.keys.toList();
      for (final key in keys) {
        if (key.toString().startsWith('cached_')) {
          await _hiveBox.delete(key);
        }
      }
      AppLogger.debug('All cached data cleared');
    } catch (e) {
      AppLogger.error('Error clearing cached data: $e');
    }
  }

  /// Clear all storage
  static Future<void> clearAll() async {
    try {
      await _prefs.clear();
      await _hiveBox.clear();
      AppLogger.info('All storage cleared');
    } catch (e) {
      AppLogger.error('Error clearing all storage: $e');
    }
  }

  /// Get storage stats for debugging
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      return {
        'hive_entries': _hiveBox.length,
        'prefs_keys': _prefs.getKeys().length,
        'has_token': hasToken(),
        'has_user': hasUser(),
        'theme': getThemeMode(),
        'language': getLanguage(),
      };
    } catch (e) {
      AppLogger.error('Error getting storage stats: $e');
      return {};
    }
  }

  /// Close storage
  static Future<void> close() async {
    try {
      await _hiveBox.close();
      AppLogger.info('Storage service closed');
    } catch (e) {
      AppLogger.error('Error closing storage: $e');
    }
  }
}
