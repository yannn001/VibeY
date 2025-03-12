import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateChecker {
  static const String UPDATE_URL =
      'https://yannn001.github.io/VibeYupdates/vibey_version.json';
  static const String LAST_CHECK_KEY = 'last_update_check';

  /// Checks for updates. Returns true if a new version is available.
  static Future<bool> checkForUpdates({bool forceCheck = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(LAST_CHECK_KEY) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Check if we've already checked for updates in the last 24 hours
      if (!forceCheck && now - lastCheck < 24 * 60 * 60 * 1000) {
        return false; // Don't check if less than 24 hours have passed
      }

      // Fetch the latest version info
      final response = await http.get(Uri.parse(UPDATE_URL));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['version'];

        // Get current app version
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        // Compare versions
        if (isNewerVersion(currentVersion, latestVersion)) {
          // Update last check time
          await prefs.setInt(LAST_CHECK_KEY, now);
          return true; // New version available
        }
      } else {
        print('Failed to fetch update info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }
    return false;
  }

  /// Compares the current version with the latest version.
  static bool isNewerVersion(String currentVersion, String latestVersion) {
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    List<int> latest = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (latest[i] > current[i]) return true;
      if (latest[i] < current[i]) return false;
    }
    return false;
  }

  /// Resets the last update check time.
  static Future<void> resetLastCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(LAST_CHECK_KEY);
  }

  /// Gets the latest version from the update URL.
  static Future<String?> getLatestVersion() async {
    try {
      final response = await http.get(Uri.parse(UPDATE_URL));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['version'];
      } else {
        print('Failed to fetch update info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching latest version: $e');
    }
    return null;
  }
}
