import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Service to clear all app data
class AppDataCleaner {
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  /// Clear all app data including:
  /// - Secure Storage (biometric data, tokens)
  /// - Shared Preferences
  /// - SQLite databases
  /// - Cache files
  /// - Temporary files
  static Future<void> clearAllData() async {
    try {
      // 1. Clear Secure Storage (tokens, biometric data, etc.)
      await _clearSecureStorage();

      // 2. Clear Shared Preferences
      await _clearSharedPreferences();

      // 3. Delete all databases
      await _clearDatabases();

      // 4. Clear cache directory
      await _clearCache();

      // 5. Clear temporary files
      await _clearTemporaryFiles();

      print('✅ All app data cleared successfully');
    } catch (e) {
      print('❌ Error clearing app data: $e');
      rethrow;
    }
  }

  /// Clear secure storage
  static Future<void> _clearSecureStorage() async {
    try {
      await _secureStorage.deleteAll();
      print('✅ Secure storage cleared');
    } catch (e) {
      print('⚠️ Error clearing secure storage: $e');
    }
  }

  /// Clear shared preferences
  static Future<void> _clearSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ Shared preferences cleared');
    } catch (e) {
      print('⚠️ Error clearing shared preferences: $e');
    }
  }

  /// Delete all SQLite databases
  static Future<void> _clearDatabases() async {
    try {
      final databasesPath = await getDatabasesPath();
      final databaseDir = Directory(databasesPath);

      if (await databaseDir.exists()) {
        final files = databaseDir.listSync();
        for (var file in files) {
          if (file is File) {
            await file.delete();
            print('✅ Deleted database: ${file.path}');
          }
        }
      }
    } catch (e) {
      print('⚠️ Error clearing databases: $e');
    }
  }

  /// Clear cache directory
  static Future<void> _clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        await _deleteDirectory(cacheDir);
        print('✅ Cache directory cleared');
      }
    } catch (e) {
      print('⚠️ Error clearing cache: $e');
    }
  }

  /// Clear temporary files
  static Future<void> _clearTemporaryFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await _deleteDirectory(tempDir);
        print('✅ Temporary files cleared');
      }
    } catch (e) {
      print('⚠️ Error clearing temporary files: $e');
    }
  }

  /// Recursively delete directory contents
  static Future<void> _deleteDirectory(Directory directory) async {
    if (await directory.exists()) {
      await for (var entity in directory.list(recursive: false)) {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
        }
      }
    }
  }
}
