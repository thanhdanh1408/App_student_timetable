// lib/core/data/hive_models/hive_cache_model.dart
/// Base cache model info
class HiveCacheMetadata {
  final String key;
  final String dataType;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final bool isSynced;

  HiveCacheMetadata({
    required this.key,
    required this.dataType,
    required this.createdAt,
    this.lastUpdatedAt,
    this.isSynced = false,
  });

  /// Check if cache is expired (older than 24 hours)
  bool get isExpired {
    final now = DateTime.now();
    final diff = now.difference(lastUpdatedAt ?? createdAt);
    return diff.inHours > 24;
  }

  /// Check if cache is fresh (created within last hour)
  bool get isFresh {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    return diff.inMinutes < 60;
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'dataType': dataType,
        'createdAt': createdAt.toIso8601String(),
        'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
        'isSynced': isSynced,
      };

  factory HiveCacheMetadata.fromJson(Map<String, dynamic> json) =>
      HiveCacheMetadata(
        key: json['key'],
        dataType: json['dataType'],
        createdAt: DateTime.parse(json['createdAt']),
        lastUpdatedAt: json['lastUpdatedAt'] != null
            ? DateTime.parse(json['lastUpdatedAt'])
            : null,
        isSynced: json['isSynced'] ?? false,
      );
}

/// Generic cache entry wrapper
class HiveCacheEntry<T> {
  final String key;
  final T data;
  final HiveCacheMetadata metadata;

  HiveCacheEntry({
    required this.key,
    required this.data,
    required this.metadata,
  });

  /// Returns true if should sync with Firestore
  bool get shouldSync => !metadata.isSynced || metadata.isExpired;
}
