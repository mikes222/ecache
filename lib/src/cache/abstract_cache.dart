import 'package:meta/meta.dart';

import '../../ecache.dart';

/// Abstract base class for caches
abstract class AbstractCache<K, V> extends Cache<K, V> {
  final Storage<K, V> storage;

  AbstractCache({Storage<K, V>? storage, required int capacity})
      : this.storage = storage ?? SimpleStorage<K, V>(),
        super(capacity: capacity);

  /// return the element identified by [key]
  @override
  V? get(K key) {
    CacheEntry<K, V>? entry = storage[key];

    if (entry == null) {
      return null;
    }

    entry = beforeGet(entry);

    return entry?.value;
  }

  /// Process the entry found in the storage before returning it. If this method
  /// returns null the entry is considered as expired and will not be returned
  /// to the caller.
  @protected
  CacheEntry<K, V>? beforeGet(CacheEntry<K, V> entry) {
    return entry;
  }

  /// add [element] in the cache at [key]
  @override
  void set(K key, V element) {
    onCapacity(key, element);
    storage[key] = createCacheEntry(key, element);
  }

  /// called if we want to
  /// insert another item denoted by [key] and [element] into the map. This
  /// method checks if the capacity is reached and eventually evicts old items.
  @protected
  void onCapacity(K key, V element);

  /// internal [set]
  @protected
  CacheEntry<K, V> createCacheEntry(K key, V element);

  /// return the number of element in the cache
  @override
  int get length => storage.length;

  // Check if the cache contains a specific entry
  @override
  bool containsKey(K key) => storage.containsKey(key);

  /// remove all the entry inside the cache
  @override
  void clear() => storage.clear();

  @override
  V? remove(K key) {
    return storage.remove(key)?.value;
  }
}
