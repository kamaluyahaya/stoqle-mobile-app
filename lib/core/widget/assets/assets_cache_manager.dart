import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sqflite/sqflite.dart';

class AssetCacheManager {
  static const _dbName = 'asset_cache.db';
  static const _tableName = 'cached_assets';
  static Database? _database;

  // Private constructor
  AssetCacheManager._internal();

  // Singleton instance
  static final AssetCacheManager instance = AssetCacheManager._internal();

  // Database initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName(
            assetId TEXT PRIMARY KEY,
            localPath TEXT,
            lastAccessed INTEGER
          )
        ''');
      },
    );
  }

  /// Finds or creates a local file copy of the asset.
  /// Returns the local path for the file.
  Future<String?> getCachedAssetPath(AssetEntity asset) async {
    final db = await database;

    // 1. Check if asset is already cached
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'assetId = ?',
      whereArgs: [asset.id],
    );

    if (maps.isNotEmpty) {
      final cachedPath = maps.first['localPath'] as String;
      // Check if file still exists on device
      if (await File(cachedPath).exists()) {
        debugPrint('Cache hit for ${asset.id}: $cachedPath');
        // Update last accessed time
        await db.update(
          _tableName,
          {'lastAccessed': DateTime.now().millisecondsSinceEpoch},
          where: 'assetId = ?',
          whereArgs: [asset.id],
        );
        return cachedPath;
      } else {
        // File is missing, delete cache entry
        await db.delete(
          _tableName,
          where: 'assetId = ?',
          whereArgs: [asset.id],
        );
      }
    }

    // 2. Cache miss or file missing: Load the asset file
    final File? file = await asset.file;
    if (file == null) {
      debugPrint('Error: Could not get AssetEntity file for ${asset.id}');
      return null;
    }

    // 3. Save a copy locally
    try {
      final appDir = await getTemporaryDirectory();
      final String extension = extensionFromAssetType(asset.type);
      final String localFileName =
          '${asset.id}_${DateTime.now().microsecondsSinceEpoch}$extension';
      final String localPath = join(appDir.path, localFileName);

      final File localFile = await file.copy(localPath);
      debugPrint('Cache stored for ${asset.id}: $localPath');

      // 4. Save to DB
      await db.insert(_tableName, {
        'assetId': asset.id,
        'localPath': localPath,
        'lastAccessed': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return localPath;
    } catch (e) {
      debugPrint('Error copying asset file: $e');
      return null;
    }
  }

  /// Helper to determine file extension
  String extensionFromAssetType(AssetType type) {
    switch (type) {
      case AssetType.image:
        return '.jpg';
      case AssetType.video:
        return '.mp4';
      default:
        return '';
    }
  }

  /// Optional: Clear old/unused cache entries (e.g., more than 7 days old)
  Future<void> cleanCache({Duration maxAge = const Duration(days: 7)}) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(maxAge).millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'lastAccessed < ?',
      whereArgs: [cutoff],
    );

    for (final map in maps) {
      final path = map['localPath'] as String;
      try {
        await File(path).delete();
      } catch (_) {}
      await db.delete(
        _tableName,
        where: 'assetId = ?',
        whereArgs: [map['assetId']],
      );
    }

    debugPrint('Cache cleaned. Removed ${maps.length} old entries.');
  }
}
