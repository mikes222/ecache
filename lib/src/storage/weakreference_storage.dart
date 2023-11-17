import 'dart:collection';

import '../cache_entry.dart';
import '../storage.dart';

/// A Storage with a fixed number of storable elements and a weak reference to elements
/// which are specified to be evicted. This way the cache can grow until the
/// garbage collector decides to remove the entries.
///
/// Note that we cannot guarantee to call the onEvict()
/// method for all elements so better to NOT use this storage for items which
/// should be evicted.
class WeakReferenceStorage<K, V> implements Storage<K, V> {
  final Map<K, CacheEntry<K, V>> _internalMap =
      LinkedHashMap<K, CacheEntry<K, V>>();

  WeakReference<Map<K, CacheEntry<K, V>>> _weakMap =
      WeakReference(LinkedHashMap<K, CacheEntry<K, V>>());

  /// if onEvict is set that method is called whenever an entry is removed from the cache.
  /// At the time the method is called the entry is already removed.
  final OnEvict<K, V>? onEvict;

  WeakReferenceStorage({this.onEvict});

  @override
  CacheEntry<K, V>? operator [](K key) {
    var ce = _internalMap[key];
    if (ce != null) return ce;
    ce = _weakMap.target?[key];
    return ce;
  }

  @override
  void clear() {
    if (onEvict != null) {
      _internalMap.values.forEach((element) {
        if (element.value != null) onEvict!(element.key, element.value!);
      });
      _weakMap.target?.values.forEach((element) {
        if (element.value != null) onEvict!(element.key, element.value!);
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
    }
    _internalMap[key] = value;
  }

  @override
  Storage set(K key, CacheEntry<K, V> value) {
    this[key] = value;
    return this;
  }

  @override
  CacheEntry<K, V>? remove(K key) {
    CacheEntry<K, V>? oldEntry = _internalMap.remove(key);
    if (oldEntry != null && oldEntry.value != null) {
      if (onEvict != null) onEvict!(oldEntry.key, oldEntry.value!);
      return oldEntry;
    }
    oldEntry = _weakMap.target?.remove(key);
    if (oldEntry != null && oldEntry.value != null) {
      if (onEvict != null) onEvict!(oldEntry.key, oldEntry.value!);
      return oldEntry;
    }
    return oldEntry;
  }

  @override
  CacheEntry<K, V>? removeInternal(K key) {
    CacheEntry<K, V>? oldEntry = _internalMap.remove(key);
    if (oldEntry != null && oldEntry.value != null) {
      if (onEvict != null) onEvict!(oldEntry.key, oldEntry.value!);
      return oldEntry;
    }
    oldEntry = _weakMap.target?.remove(key);
    if (oldEntry != null && oldEntry.value != null) {
      if (onEvict != null) onEvict!(oldEntry.key, oldEntry.value!);
      return oldEntry;
    }
    return oldEntry;
  }

  @override
  CacheEntry<K, V>? onCapacity(K key) {
    CacheEntry<K, V>? oldEntry = _internalMap.remove(key);
    if (oldEntry != null && oldEntry.value != null) {
      if (_weakMap.target == null)
        _weakMap = WeakReference(LinkedHashMap<K, CacheEntry<K, V>>());
      _weakMap.target![key] = oldEntry;
    }
    return oldEntry;
  }

  @override
  int get length => _internalMap.length;

  /// Only returns true if the key is contained in the strong reference list and
  /// as such ensured to be available for most caches (except expirationCache)
  @override
  bool containsKey(K key) {
    return _internalMap.containsKey(key);
  }

  @override
  List<K> get keys => _internalMap.keys.toList();

  @override
  List<CacheEntry<K, V>> get entries => _internalMap.values.toList();
}
