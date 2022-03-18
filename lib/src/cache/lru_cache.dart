import 'package:flutter/foundation.dart';

import '../cache_entry.dart';
import '../storage.dart';
import 'abstract_cache.dart';

class LruCache<K, V> extends AbstractCache<K, V> {
  int lastUse = 0;

  LruCache({required Storage<K, V> storage, required int capacity})
      : super(storage: storage, capacity: capacity);

  @override
  void onCapacity(K key, V element) {
//    storage.entries.sort((a, b) => (a as LruCacheEntry).lastUse - (b as LruCacheEntry).lastUse);
    // Iterate on all keys, so the eviction is O(n) to allow an insertion at O(1)
    LruCacheEntry<K, V> min = storage.entries
        .map((e) => e as LruCacheEntry<K, V>)
        .reduce((element1, element2) =>
            element1.lastUse < element2.lastUse ? element1 : element2);

    storage.remove(min.key);
  }

  @override
  CacheEntry<K, V> createCacheEntry(K key, V element) {
    return LruCacheEntry(key, element, ++lastUse);
  }

  @protected
  @override
  CacheEntry<K, V>? beforeGet(CacheEntry<K, V> entry) {
    (entry as LruCacheEntry).updateLastUse(++lastUse);
    return entry;
  }
}

/////////////////////////////////////////////////////////////////////////////

class LruCacheEntry<K, V> extends CacheEntry<K, V> {
  int lastUse;

  LruCacheEntry(K key, V? value, this.lastUse) : super(key, value);

  void updateLastUse(int lastUse) {
    this.lastUse = lastUse;
  }
}
