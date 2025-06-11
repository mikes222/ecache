import 'package:ecache/src/cache/abstract_cache.dart';

import '../cache_entry.dart';
import '../storage.dart';

/// Least frequently used cache. Items which are not used often gets evicted first
class LfuCache<K, V> extends AbstractCache<K, V> {
  LfuCache({required Storage<K, V>? storage, required int capacity}) : super(storage: storage, capacity: capacity);

  @override
  void onCapacity(K key, V element) {
    if (length < capacity) return;
    // Iterate on all keys, so the eviction is O(n) to allow an insertion at O(1)
    MapEntry<K, CacheEntry<K, V>> min = storage.entries.entries
        .reduce((element1, element2) => (element1.value as LfuCacheEntry).use < (element2.value as LfuCacheEntry).use ? element1 : element2);

    storage.onCapacity(min.key);
  }

  @override
  CacheEntry<K, V> createCacheEntry(K key, V value) {
    return LfuCacheEntry(key, value);
  }

  @override
  CacheEntry<K, V>? beforeGet(K key, CacheEntry<K, V> entry) {
    (entry as LfuCacheEntry).use++;
    return entry;
  }
}

/////////////////////////////////////////////////////////////////////////////

class LfuCacheEntry<K, V> extends CacheEntry<K, V> {
  int use = 0;

  LfuCacheEntry(K key, V? value) : super(value);
}
