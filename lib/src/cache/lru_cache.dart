import 'package:flutter/foundation.dart';

import '../cache_entry.dart';
import '../storage.dart';
import 'abstract_cache.dart';

/// Least recently used cache. Items which are not read for the longest period
/// gets evicted first
class LruCache<K, V> extends AbstractCache<K, V> {
  int lastUse = 0;

  LruCache({required Storage<K, V>? storage, required int capacity}) : super(storage: storage, capacity: capacity);

  @override
  void onCapacity(K key, V element) {
    if (length < capacity) return;
    // Iterate on all keys, so the eviction is O(n) to allow an insertion at O(1)
    MapEntry<K, CacheEntry<K, V>> min = storage.entries.entries
        .reduce((element1, element2) => (element1.value as LruCacheEntry).lastUse < (element2.value as LruCacheEntry).lastUse ? element1 : element2);
    storage.onCapacity(min.key);
  }

  @override
  CacheEntry<K, V> createCacheEntry(K key, V element) {
    return LruCacheEntry(key, element, ++lastUse);
  }

  @protected
  @override
  CacheEntry<K, V>? beforeGet(K key, CacheEntry<K, V> entry) {
    (entry as LruCacheEntry).updateLastUse(++lastUse);
    return entry;
  }
}

/////////////////////////////////////////////////////////////////////////////

class LruCacheEntry<K, V> extends CacheEntry<K, V> {
  int lastUse;

  LruCacheEntry(K key, V? value, this.lastUse) : super(value);

  void updateLastUse(int lastUse) {
    this.lastUse = lastUse;
  }
}
