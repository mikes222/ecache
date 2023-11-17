import 'dart:math';

import '../../ecache.dart';

/// Same as [SimpleStorage] but collects a few statistical data. The statistics
/// can be retrieved by calling [toString]
class StatisticsStorage<K, V> extends SimpleStorage<K, V> {
  int _maxLength = 0;

  int _added = 0;

  int _evicted = 0;

  int _read = 0;

  int _removed = 0;

  int _removedCapacity = 0;

  int _contains = 0;

  StatisticsStorage({OnEvict<K, V>? onEvict}) : super(onEvict: onEvict);

  @override
  CacheEntry<K, V>? get(K key) {
    ++_read;
    return super.get(key);
  }

  @override
  onEvictInternal(K key, V value) {
    ++_evicted;
    return super.onEvictInternal(key, value);
  }

  @override
  void setInternal(K key, CacheEntry<K, V> value) {
    ++_added;
    super.setInternal(key, value);
    _maxLength = max(_maxLength, length);
  }

  @override
  CacheEntry<K, V>? remove(K key) {
    CacheEntry<K, V>? ce = super.remove(key);
    if (ce != null) ++_removed;
    return ce;
  }

  @override
  CacheEntry<K, V>? onCapacity(K key) {
    CacheEntry<K, V>? ce = super.onCapacity(key);
    if (ce != null) {
      --_removed;
      ++_removedCapacity;
    }
    return ce;
  }

  @override
  bool containsKey(K key) {
    ++_contains;
    return super.containsKey(key);
  }

  @override
  String toString() {
    return 'StatisticsStorage{_maxLength: $_maxLength, _added: $_added, _evicted: $_evicted, _read: $_read, _removed: $_removed, _removedCapacity: $_removedCapacity, _contains: $_contains}';
  }
}
