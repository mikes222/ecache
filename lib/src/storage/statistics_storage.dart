import 'dart:math';

import '../../ecache.dart';

/// Same as [SimpleStorage] but collects a few statistical data.
class StatisticsStorage<K, V> extends SimpleStorage<K, V> {
  int _maxLength = 0;
  int _hitCount = 0;
  int _missCount = 0;
  int _evictionCount = 0;

  /// The number of times a requested item was found in the cache.
  int get hitCount => _hitCount;

  /// The number of times a requested item was not found in the cache.
  int get missCount => _missCount;

  /// The number of times an item was evicted from the cache to make space.
  int get evictionCount => _evictionCount;

  StatisticsStorage({OnEvict<K, V>? onEvict}) : super(onEvict: onEvict);

  @override
  CacheEntry<K, V>? get(K key) {
    final entry = super.get(key);
    if (entry != null) {
      _hitCount++;
    } else {
      _missCount++;
    }
    return entry;
  }

  @override
  void setInternal(K key, CacheEntry<K, V> value) {
    super.setInternal(key, value);
    _maxLength = max(_maxLength, length);
  }

  @override
  CacheEntry<K, V>? onCapacity(K key) {
    final entry = super.onCapacity(key);
    if (entry != null) {
      _evictionCount++;
    }
    return entry;
  }

  @override
  String toString() {
    return 'StatisticsStorage{current: $length, max: $_maxLength, hits: $_hitCount, misses: $_missCount, evictions: $_evictionCount}';
  }
}
