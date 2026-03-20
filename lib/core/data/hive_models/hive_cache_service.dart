// lib/core/data/hive_models/hive_cache_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'hive_cache_model.dart';

/// Simple Hive caching service for offline support
class HiveCacheService {
  static const String _cacheBoxName = 'timetable_cache';
  late Box<dynamic> _cacheBox;

  /// Initialize Hive and open cache box
  Future<void> initialize() async {
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox(_cacheBoxName);
    print('✅ Hive cache initialized');
  }

  /// Save data with metadata (overwrite if exists)
  Future<void> save<T>(
    String key,
    T data,
    String dataType, {
    bool markSynced = false,
  }) async {
    try {
      final metadata = HiveCacheMetadata(
        key: key,
        dataType: dataType,
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        isSynced: markSynced,
      );

      final cacheData = {
        'data': _serializeData(data),
        'metadata': metadata.toJson(),
      };

      await _cacheBox.put(key, cacheData);
      print('✅ Cached: $key (type: $dataType)');
    } catch (e) {
      print('❌ Cache error for $key: $e');
    }
  }

  /// Retrieve cached data
  Future<T?> get<T>(String key) async {
    try {
      final cached = _cacheBox.get(key);
      if (cached == null) return null;

      final data = cached['data'] as Map;
      return _deserializeData<T>(data);
    } catch (e) {
      print('❌ Cache retrieval error for $key: $e');
      return null;
    }
  }

  /// Check if cache exists and is fresh
  Future<bool> isFresh(String key) async {
    try {
      final cached = _cacheBox.get(key);
      if (cached == null) return false;

      final metaJson = cached['metadata'] as Map;
      final metadata = HiveCacheMetadata.fromJson(metaJson.cast());
      return metadata.isFresh;
    } catch (e) {
      return false;
    }
  }

  /// Check if cache exists (regardless of age)
  bool exists(String key) => _cacheBox.containsKey(key);

  /// Delete specific cache entry
  Future<void> delete(String key) async {
    await _cacheBox.delete(key);
    print('🗑️  Deleted cache: $key');
  }

  /// Clear all cache
  Future<void> clearAll() async {
    await _cacheBox.clear();
    print('🗑️  Cache cleared');
  }

  /// Get cache count
  int getCacheCount() => _cacheBox.length;

  /// Get all cache keys
  List<String> getAllKeys() => _cacheBox.keys.cast<String>().toList();

  // Helper serializer (basic JSON-like)
  dynamic _serializeData<T>(T data) {
    if (data is List) {
      return data.map((item) {
        if (item is Map) return Map.from(item);
        return item;
      }).toList();
    }
    if (data is Map) return Map.from(data);
    return data;
  }

  // Helper deserializer
  T? _deserializeData<T>(dynamic data) {
    try {
      return data as T;
    } catch (e) {
      return null;
    }
  }
}
