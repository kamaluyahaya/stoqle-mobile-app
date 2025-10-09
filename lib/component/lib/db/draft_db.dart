// lib/services/draft_db.dart
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stoqle/component/lib/models/draft_assets.dart';

class DraftDb {
  static final DraftDb _inst = DraftDb._();
  factory DraftDb() => _inst;
  DraftDb._();

  Database? _db;
  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'drafts.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
        CREATE TABLE draft_assets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          originalId TEXT,
          localPath TEXT,
          type TEXT,
          durationMs INTEGER,
          "order" INTEGER
        )
      ''');
      },
    );
    return _db!;
  }

  Future<int> insertAsset(DraftAsset a) async {
    final database = await db;
    return await database.insert(
      'draft_assets',
      a.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DraftAsset>> getAllAssets() async {
    final database = await db;
    final rows = await database.query('draft_assets', orderBy: '"order" ASC');
    return rows.map((r) => DraftAsset.fromMap(r)).toList();
  }

  Future<void> clearAll() async {
    final database = await db;
    await database.delete('draft_assets');
  }

  Future<void> deleteAsset(int id) async {
    final database = await db;
    await database.delete('draft_assets', where: 'id = ?', whereArgs: [id]);
  }

  /// copy file into app cache and register
  Future<DraftAsset> cacheAndSaveAsset({
    required String originalId,
    required File sourceFile,
    required DraftAssetType type,
    required int durationMs,
    required int order,
  }) async {
    final dir = await getTemporaryDirectory();
    final ext = p.extension(sourceFile.path);
    final target = File(
      p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}_$order$ext'),
    );
    await sourceFile.copy(target.path);
    final draft = DraftAsset(
      originalId: originalId,
      localPath: target.path,
      type: type,
      durationMs: durationMs,
      order: order,
    );
    final id = await insertAsset(draft);
    return DraftAsset(
      id: id,
      originalId: draft.originalId,
      localPath: draft.localPath,
      type: draft.type,
      durationMs: draft.durationMs,
      order: draft.order,
    );
  }
}
