import 'package:ecache/ecache.dart';

import 'abstract_cache.dart';

/// SimpleCache is a basic cache implementation without any particular logic
/// than appending keys in the storage, and remove first inserted keys when
/// storage is full
class SimpleCache<K, V> extends AbstractCache<K, V> {
  SimpleCache({Storage<K, V>? storage, required int capacity}) : super(storage: storage, capacity: capacity);

  @override
  CacheEntry<K, V> createCacheEntry(K key, V value) {
    return CacheEntry(value);
  }

  @override
  void onCapacity(K key, V element) {
    if (length < capacity) return;
    storage.onCapacity(storage.keys.first);
  }
}
