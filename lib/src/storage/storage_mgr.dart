import 'dart:math';

import 'package:ecache/ecache.dart';

class StorageMgr {
  static StorageMgr? _instance;

  final Set<StatisticsStorage> _storages = {};

  bool _enabled = false;

  int _registered = 0;

  int _unregisterd = 0;

  StorageMgr._();

  factory StorageMgr() {
    if (_instance != null) return _instance!;
    _instance = StorageMgr._();
    return _instance!;
  }

  void setEnabled(bool enabled) {
    // assertions are not included in production code so it is impossible to enable profiling in release mode
    assert(() {
      _enabled = enabled;
      return true;
    }());
  }

  bool isEnabled() => _enabled;

  void register(StatisticsStorage storage) {
    if (!_enabled) return;
    _storages.add(storage);
    ++_registered;
  }

  void unregister(StatisticsStorage storage) {
    _storages.remove(storage);
    ++_unregisterd;
  }

  void clear() {
    for (var storage in _storages) {
      storage.storageMetric.clear();
    }
    _registered = 0;
    _unregisterd = 0;
  }

  StorageReport createReport() {
    final report = StorageReport();
    for (var storage in _storages) {
      report._storageMetrics.add(storage.storageMetric.._currentLength = storage.length);
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
  static int _nextId = 0;

  final int id;

  final String name;

  final int capacity;

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

  /// The current length of the cache.
  int _currentLength = 0;

  StorageMetric({required this.name, this.capacity = 0}) : id = _nextId++;

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
    return '$id, $name: capacity: $capacity, maxEntries: $_maxLength, currentEntries: $_currentLength, hits: $_hitCount, misses: $_missCount, evictions: $_evictionCount, sets: $_setCount}';
  }

  void clear() {
    _maxLength = 0;
    _hitCount = 0;
    _missCount = 0;
    _evictionCount = 0;
    _setCount = 0;
    _currentLength = 0;
  }
}

//////////////////////////////////////////////////////////////////////////////

class StorageReport {
  final DateTime timestamp;

  final int registered;

  final int unregistered;

  final bool enabled;

  final List<StorageMetric> _storageMetrics = [];

  StorageReport()
      : registered = StorageMgr()._registered,
        unregistered = StorageMgr()._unregisterd,
        enabled = StorageMgr().isEnabled(),
        timestamp = DateTime.now();

  /// Returns the storage metrics map
  List<StorageMetric> get storageMetrics => _storageMetrics;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Storage Report (${timestamp.toIso8601String()})');
    buffer.writeln('Storages registered: $registered, unregistered: $unregistered');
    if (!enabled) buffer.writeln('Storage reports are disabled');
    for (final entry in storageMetrics) {
      buffer.writeln('  $entry');
    }

    return buffer.toString();
  }
}
