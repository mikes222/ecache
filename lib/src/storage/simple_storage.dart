import 'dart:collection';

import '../cache_entry.dart';
import '../storage.dart';

/// A simple storage class which is backed by a LinkedHashMap internally
class SimpleStorage<K, V> implements Storage<K, V> {
  final Map<K, CacheEntry<K, V>> _internalMap = LinkedHashMap<K, CacheEntry<K, V>>();

  /// if onEvict is set that method is called whenever an entry is removed from the cache.
  /// At the time the method is called the entry is already removed.
  final OnEvict<K, V>? onEvict;

  SimpleStorage({this.onEvict});

  @override
  void clear() {
    if (onEvict != null) {
      _internalMap.entries.forEach((action) {
        if (action.value.value != null) onEvictInternal(action.key, action.value.value!);
      });
    }
    _internalMap.clear();
  }

  onEvictInternal(K key, V value) {
    onEvict!(key, value!);
  }

  @override
  CacheEntry<K, V>? get(K key) {
    var ce = _internalMap[key];
    return ce;
  }

  @override
  Storage set(K key, CacheEntry<K, V> value) {
    CacheEntry<K, V>? oldEntry = _internalMap[key];
    if (oldEntry != null && oldEntry.value != null && onEvict != null) {
      onEvictInternal(key, oldEntry.value!);
    }
    setInternal(key, value);
    return this;
  }

  void setInternal(K key, CacheEntry<K, V> value) {
    _internalMap[key] = value;
  }

  @override
  CacheEntry<K, V>? remove(K key) {
    CacheEntry<K, V>? oldEntry = _internalMap.remove(key);
    if (oldEntry != null && oldEntry.value != null && onEvict != null) {
      onEvictInternal(key, oldEntry.value!);
    }
    return oldEntry;
  }

  @override
  CacheEntry<K, V>? removeInternal(K key) {
    CacheEntry<K, V>? oldEntry = _internalMap.remove(key);
    if (oldEntry != null && oldEntry.value != null && onEvict != null) {
      onEvictInternal(key, oldEntry.value!);
    }
    return oldEntry;
  }

  @override
  CacheEntry<K, V>? onCapacity(K key) {
    CacheEntry<K, V>? oldEntry = _internalMap.remove(key);
    if (oldEntry != null && oldEntry.value != null && onEvict != null) {
      onEvictInternal(key, oldEntry.value!);
    }
    return oldEntry;
  }

  @override
  int get length => _internalMap.length;

  @override
  bool containsKey(K key) {
    return _internalMap.containsKey(key);
  }

  @override
  List<K> get keys => _internalMap.keys.toList();

  @override
  Map<K, CacheEntry<K, V>> get entries => _internalMap;
}
