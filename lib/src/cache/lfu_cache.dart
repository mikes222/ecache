import 'package:ecache/src/cache/abstract_cache.dart';

import '../cache_entry.dart';
import '../storage.dart';

/// Least frequently used cache. Items which are not used often gets evicted first
class LfuCache<K, V> extends AbstractCache<K, V> {
  LfuCache({required Storage<K, V>? storage, required int capacity})
      : super(storage: storage, capacity: capacity);

  @override
  void onCapacity(K key, V element) {
    // Iterate on all keys, so the eviction is O(n) to allow an insertion at O(1)
    LfuCacheEntry<K, V> min = storage.entries
        .map((e) => e as LfuCacheEntry<K, V>)
        .reduce((element1, element2) =>
            element1.use < element2.use ? element1 : element2);

    storage.onCapacity(min.key);
  }

  @override
  CacheEntry<K, V> createCacheEntry(K key, V value) {
    return LfuCacheEntry(key, value);
  }

  @override
  CacheEntry<K, V>? beforeGet(CacheEntry<K, V> entry) {
    (entry as LfuCacheEntry).use++;
    return entry;
  }
}

/////////////////////////////////////////////////////////////////////////////

class LfuCacheEntry<K, V> extends CacheEntry<K, V> {
  int use = 0;

  LfuCacheEntry(K key, V? value) : super(key, value);
}
