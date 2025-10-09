// lib/models/draft_asset.dart
import 'package:flutter/foundation.dart';

enum DraftAssetType { image, video }

class DraftAsset {
  final int? id; // sqlite PK
  final String originalId; // photo_manager asset.id or original identifier
  final String localPath; // path copied to app cache
  final DraftAssetType type;
  final int
  durationMs; // for videos: actual ms; for images: display duration ms
  final int order;

  DraftAsset({
    this.id,
    required this.originalId,
    required this.localPath,
    required this.type,
    required this.durationMs,
    required this.order,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'originalId': originalId,
    'localPath': localPath,
    'type': describeEnum(type),
    'durationMs': durationMs,
    'order': order,
  };

  factory DraftAsset.fromMap(Map<String, dynamic> m) => DraftAsset(
    id: m['id'] as int?,
    originalId: m['originalId'],
    localPath: m['localPath'],
    type: DraftAssetType.values.firstWhere(
      (e) => describeEnum(e) == (m['type'] as String),
    ),
    durationMs: m['durationMs'],
    order: m['order'],
  );
}
