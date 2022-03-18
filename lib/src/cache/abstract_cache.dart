import 'package:meta/meta.dart';

import '../cache.dart';
import '../cache_entry.dart';
import '../storage.dart';

///
/// returns the value for the given key [key] or null. This method will be called if the value for the requested [key] is not
/// available in the cache.
///
typedef V LoaderFunc<K, V>(K key);

abstract class AbstractCache<K, V> extends Cache<K, V> {
  final Storage<K, V> storage;

  AbstractCache({required this.storage, required int capacity})
      : super(capacity: capacity);

  /// return the element identified by [key]
  @override
  V? get(K key) {
    CacheEntry<K, V>? entry = storage[key];

    if (entry == null) {
      return null;
    }

    entry = beforeGet(entry);

    if (entry == null) {
      return null;
    }

    return entry.value;
  }

  @protected
  CacheEntry<K, V>? beforeGet(CacheEntry<K, V> entry) {
    return entry;
  }

  /// add [element] in the cache at [key]
  @override
  void set(K key, V element) {
    if (!containsKey(key) && length >= capacity) {
      onCapacity(key, element);
    }
    storage[key] = createCacheEntry(key, element);
  }

  /// called if the length of the map reaches the capacity and we want to insert another item into the map
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
