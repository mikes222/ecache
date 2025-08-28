import 'dart:collection';

import '../cache_entry.dart';
import '../storage.dart';

/// A [Storage] implementation that uses a [LinkedHashMap] to preserve insertion order.
///
/// This class provides a simple cache storage solution that maintains the order of insertion.
/// It uses a [LinkedHashMap] to store cache entries, allowing for efficient retrieval and removal of entries.
class SimpleStorage<K, V> implements Storage<K, V> {
  /// The underlying [LinkedHashMap] that stores the cache entries.
  ///
  /// This map stores cache entries, where each key is associated with a [CacheEntry] object.
  final Map<K, CacheEntry<K, V>> _internalMap = <K, CacheEntry<K, V>>{};

  /// An optional callback that is invoked when an entry is evicted from the cache.
  ///
  /// This callback is called when an entry is removed from the cache, either manually or due to capacity constraints.
  final OnEvict<K, V>? onEvict;

  /// Creates a new [SimpleStorage] with an optional [onEvict] callback.
  ///
  /// The [onEvict] callback is called when an entry is evicted from the cache.
  SimpleStorage({this.onEvict});

  @override

  /// Clears the cache, removing all entries.
  ///
  /// If [onEvict] is set, it is called for each removed entry.
  void clear() {
    if (onEvict != null) {
      for (var oldEntry in _internalMap.entries) {
        onEvictInternal(oldEntry.key, oldEntry.value);
      }
    }
    _internalMap.clear();
  }

  /// A helper method to invoke the [onEvict] callback.
  ///
  /// This method is used internally to call the [onEvict] callback when an entry is evicted from the cache.
  void onEvictInternal(K key, CacheEntry<K, V> cacheEntry) {
    if (onEvict == null) return;
    if (cacheEntry.entry is ValueEntry) {
      V value = cacheEntry.getValue();
      onEvict!(key, value);
      return;
    } else {
      (cacheEntry.entry as ProducerEntry<K, V>).abortProcess();
    }
  }

  /// Retrieves a cache entry by its key.
  ///
  /// Returns the cache entry associated with the given key, or null if no entry exists.
  @override
  CacheEntry<K, V>? get(K key) => _internalMap[key];

  @override

  /// Sets a cache entry for the given key.
  /// If an existing entry is replaced, [onEvict] is called if set.
  Storage set(K key, CacheEntry<K, V> value) {
    CacheEntry<K, V>? oldEntry = _internalMap[key];
    if (oldEntry != null) {
      onEvictInternal(key, oldEntry);
    }
    setInternal(key, value);
    return this;
  }

  /// An internal method to set a value in the map.
  void setInternal(K key, CacheEntry<K, V> value) {
    _internalMap[key] = value;
  }

  @override

  /// Removes a cache entry by its key.
  /// If [onEvict] is set, it is called for the removed entry.
  CacheEntry<K, V>? remove(K key) {
    CacheEntry<K, V>? oldEntry = _internalMap.remove(key);
    if (oldEntry != null) {
      onEvictInternal(key, oldEntry);
    }
    return oldEntry;
  }

  /// Removes a cache entry by its key.
  /// If [onEvict] is set, it is called for the removed entry.
  @override
  CacheEntry<K, V>? removeInternal(K key) {
    CacheEntry<K, V>? oldEntry = _internalMap.remove(key);
    if (oldEntry != null) {
      onEvictInternal(key, oldEntry);
    }
    return oldEntry;
  }

  /// Removes a cache entry by its key when the cache capacity is reached.
  /// If [onEvict] is set, it is called for the removed entry.
  @override
  CacheEntry<K, V>? onCapacity(K key) {
    CacheEntry<K, V>? oldEntry = _internalMap.remove(key);
    if (oldEntry != null) {
      onEvictInternal(key, oldEntry);
    }
    return oldEntry;
  }

  @override

  /// Returns the number of cache entries.
  int get length => _internalMap.length;

  /// Checks if a cache entry exists for the given key.
  @override
  bool containsKey(K key) => _internalMap.containsKey(key);

  @override

  /// Returns an iterable of all cache keys.
  Iterable<K> get keys => _internalMap.keys;

  @override

  /// Returns a map of all cache entries.
  Map<K, CacheEntry<K, V>> get entries => _internalMap;
}
