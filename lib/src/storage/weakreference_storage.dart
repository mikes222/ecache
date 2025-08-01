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
  final Map<K, CacheEntry<K, V>> _internalMap = <K, CacheEntry<K, V>>{};

  WeakReference<Map<K, CacheEntry<K, V>>> _weakMap = WeakReference(<K, CacheEntry<K, V>>{});

  /// if onEvict is set that method is called whenever an entry is removed from the cache.
  /// At the time the method is called the entry is already removed.
  final OnEvict<K, V>? onEvict;

  WeakReferenceStorage({this.onEvict});

  @override
  void clear() {
    if (onEvict != null) {
      for (var element in _internalMap.entries) {
        if (element.value.value != null) onEvict!(element.key, element.value.value!);
      }
      _weakMap.target?.entries.forEach((element) {
        if (element.value.value != null) onEvict!(element.key, element.value.value!);
      });
    }
    _internalMap.clear();
    _weakMap.target?.clear();
  }

  @override
  CacheEntry<K, V>? get(K key) {
    var ce = _internalMap[key];
    if (ce != null) return ce;
    ce = _weakMap.target?[key];
    return ce;
  }

  @override
  Storage set(K key, CacheEntry<K, V> value) {
    CacheEntry<K, V>? oldEntry = _internalMap[key];
    if (oldEntry != null && oldEntry.value != null && onEvict != null) {
      onEvict!(key, oldEntry.value!);
    }
    _internalMap[key] = value;
    return this;
  }

  @override
  CacheEntry<K, V>? remove(K key) {
    CacheEntry<K, V>? oldEntry = _internalMap.remove(key);
    if (oldEntry != null && oldEntry.value != null) {
      if (onEvict != null) onEvict!(key, oldEntry.value!);
      return oldEntry;
    }
    oldEntry = _weakMap.target?.remove(key);
    if (oldEntry != null && oldEntry.value != null) {
      if (onEvict != null) onEvict!(key, oldEntry.value!);
      return oldEntry;
    }
    return oldEntry;
  }

  @override
  CacheEntry<K, V>? removeInternal(K key) {
    CacheEntry<K, V>? oldEntry = _internalMap.remove(key);
    if (oldEntry != null && oldEntry.value != null) {
      if (onEvict != null) onEvict!(key, oldEntry.value!);
      return oldEntry;
    }
    oldEntry = _weakMap.target?.remove(key);
    if (oldEntry != null && oldEntry.value != null) {
      if (onEvict != null) onEvict!(key, oldEntry.value!);
      return oldEntry;
    }
    return oldEntry;
  }

  @override
  CacheEntry<K, V>? onCapacity(K key) {
    CacheEntry<K, V>? oldEntry = _internalMap.remove(key);
    if (oldEntry != null && oldEntry.value != null) {
      if (_weakMap.target == null) _weakMap = WeakReference(<K, CacheEntry<K, V>>{});
      // it may be null again if we do not have enough memory, in this case, we do not save the old entry anymore.
      // from time to time even with an if in front of the next clause target may be null. So replaced the if with a question mark
      _weakMap.target?[key] = oldEntry;
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
  Map<K, CacheEntry<K, V>> get entries => _internalMap;
}
