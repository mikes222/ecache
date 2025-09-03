import 'dart:math';

import 'package:ecache/ecache.dart';

class StorageMgr {
  static StorageMgr? _instance;

  final Set<StatisticsStorage> _storages = {};

  bool _enable = false;

  StorageMgr._();

  factory StorageMgr() {
    if (_instance != null) return _instance!;
    _instance = StorageMgr._();
    return _instance!;
  }

  void setEnable(bool enable) {
    _enable = enable;
  }

  bool isEnabled() => _enable;

  void register(StatisticsStorage storage) {
    _storages.add(storage);
  }

  void unregister(StatisticsStorage storage) {
    _storages.remove(storage);
  }

  StorageReport createReport() {
    final report = StorageReport();
    for (var storage in _storages) {
      report._storageMetrics[storage.runtimeType.toString()] = storage.storageMetric;
    }
    return report;
  }

  /// Reset the singleton instance (for testing purposes only)
  // @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }
}

//////////////////////////////////////////////////////////////////////////////

class StorageMetric {
  /// Maximum length of the cache
  int _maxLength = 0;

  /// number of cache hits
  int _hitCount = 0;

  /// number of cache misses
  int _missCount = 0;

  /// number of evictions
  int _evictionCount = 0;

  /// number of times an entry has been stored to the cache
  int _setCount = 0;

  /// The number of times a requested item was found in the cache.
  int get hitCount => _hitCount;

  /// The number of times a requested item was not found in the cache.
  int get missCount => _missCount;

  /// The number of times an item was evicted from the cache to make space.
  int get evictionCount => _evictionCount;

  void incHitCount() => ++_hitCount;

  void incMissCount() => ++_missCount;

  void incEvictionCount() => ++_evictionCount;

  void incSetCount() => ++_setCount;

  void checkLength(int length) {
    _maxLength = max(_maxLength, length);
  }

  int get maxLength => _maxLength;

  int get setCount => _setCount;

  @override
  String toString() {
    return 'StorageMetric{_maxLength: $_maxLength, _hitCount: $_hitCount, _missCount: $_missCount, _evictionCount: $_evictionCount, _setCount: $_setCount}';
  }
}

//////////////////////////////////////////////////////////////////////////////

class StorageReport {
  final Map<String, StorageMetric> _storageMetrics = {};

  /// Returns the storage metrics map
  Map<String, StorageMetric> get storageMetrics => _storageMetrics;

  @override
  String toString() {
    final buffer = StringBuffer();
    for (final entry in storageMetrics.entries) {
      buffer.writeln('  ${entry.key}: ${entry.value}');
    }

    return buffer.toString();
  }
}
