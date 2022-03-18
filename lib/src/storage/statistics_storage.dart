import 'dart:collection';

import '../cache_entry.dart';
import '../storage.dart';

/// Same as [SimpleStorage] but collects a few statistical data
class StatisticsStorage<K, V> implements Storage<K, V> {
  final Map<K, CacheEntry<K, V>> _internalMap =
      LinkedHashMap<K, CacheEntry<K, V>>();

  int _maxLength = 0;

  int _added = 0;

  int _evicted = 0;

  int _read = 0;

  int _removed = 0;

  int _contains = 0;

  /// if onEvict is set that method is called whenever an entry is removed from the cache.
  /// At the time the method is called the entry is already removed.
  final OnEvict<K, V>? onEvict;

  StatisticsStorage({this.onEvict});

  @override
  CacheEntry<K, V>? operator [](K key) {
    var ce = _internalMap[key];
    ++_read;
    return ce;
  }

  @override
  void clear() {
    if (onEvict != null) {
      _internalMap.values.forEach((element) {
        if (element.value != null) {
          onEvict!(element.key, element.value!);
          ++_evicted;
        }
      });
    }
    _internalMap.clear();
  }

  @override
  CacheEntry<K, V>? get(K key) {
    return this[key];
  }

  @override
  void operator []=(K key, CacheEntry<K, V> value) {
    CacheEntry<K, V>? oldEntry = _internalMap[key];
    if (oldEntry != null && oldEntry.value != null && onEvict != null) {
      onEvict!(oldEntry.key, oldEntry.value!);
      ++_evicted;
    }
    _internalMap[key] = value;
    if (_maxLength < _internalMap.length) _maxLength = _internalMap.length;
    ++_added;
  }

  @override
  Storage set(K key, CacheEntry<K, V> value) {
    this[key] = value;
    return this;
  }

  @override
  CacheEntry<K, V>? remove(K key) {
    CacheEntry<K, V>? oldEntry = _internalMap[key];
    if (oldEntry != null && oldEntry.value != null && onEvict != null) {
      onEvict!(oldEntry.key, oldEntry.value!);
      ++_evicted;
    }
    ++_removed;
    return _internalMap.remove(key);
  }

  @override
  int get length => _internalMap.length;

  @override
  bool containsKey(K key) {
    ++_contains;
    return _internalMap.containsKey(key);
  }

  @override
  List<K> get keys => _internalMap.keys.toList();

  @override
  List<CacheEntry<K, V>> get entries => _internalMap.values.toList();

  @override
  String toString() {
    return 'StatisticsStorage{_maxLength: $_maxLength, _added: $_added, _evicted: $_evicted, _read: $_read, _removed: $_removed, _contains: $_contains}';
  }
}
