import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopos/src/config/const.dart';

class ConfigService {
  // The permanent URL pointing to your config.json on GitHub
  static const String configUrl =
      'https://raw.githubusercontent.com/GuruPrakashKumar/bharatpos-config/refs/heads/main/config.json';

  static const String _cachedBaseUrlKey = 'cached_base_url';
  static const String _cachedExpiryDateKey = 'cached_expiry_date'; // New key for expiry date

  /// Fetches the config from the GitHub config file.
  /// Returns null if the request fails.
  static Future<Map<String, dynamic>?> _fetchConfigFromGitHub() async {
    try {
      final response = await http.get(Uri.parse(configUrl));
      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonMap;
      } else {
        print('Failed to fetch config: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching config: $e');
      return null;
    }
  }

  /// Gets the base URL. First checks cache, then network.
  /// Returns the hardcoded URL from Const.dart only as a last resort fallback.
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Check SharedPreferences cache first
    final cachedUrl = prefs.getString(_cachedBaseUrlKey);
    if (cachedUrl != null && cachedUrl.isNotEmpty) {
      print('Using cached base URL: $cachedUrl');
      return cachedUrl;
    }

    // 2. If no cache, fetch from GitHub
    print('No cached URL found. Fetching from GitHub...');
    final configMap = await _fetchConfigFromGitHub();
    print('configMap: $configMap');

    if (configMap != null && configMap['base_url'] != null) {
      final fetchedUrl = configMap['base_url'] as String;
      final expiryDate = configMap['expiry_date'] as String?;
      print('expiry date of aws: $expiryDate');

      // Save the new URL to cache for next time
      await prefs.setString(_cachedBaseUrlKey, fetchedUrl);

      // Save expiry date if it exists
      if (expiryDate != null && expiryDate.isNotEmpty) {
        await prefs.setString(_cachedExpiryDateKey, expiryDate);
      }

      print('Saved new base URL to cache: $fetchedUrl');
      if (expiryDate != null) {
        print('Saved expiry date: $expiryDate');
      }

      return fetchedUrl;
    }

    // 3. If everything fails, fall back to the hardcoded URL (original behavior)
    print('WARNING: Using hardcoded fallback base URL. Config fetch failed.');
    const fallbackUrl = Const.apiUrl;
    return fallbackUrl;
  }

  // Call this method if you update the config and want to force a refresh
  static Future<void> clearCachedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedBaseUrlKey);
    await prefs.remove(_cachedExpiryDateKey);
    print('Cleared cached config.');
  }

  static Future<String?> getCurrentBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cachedBaseUrlKey);
  }

  /// Gets the currently cached expiry date
  static Future<String?> getCurrentExpiryDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cachedExpiryDateKey);
  }

  /// Gets the URL used for the configuration file itself.
  static String getConfigSourceUrl() {
    return configUrl;
  }
}