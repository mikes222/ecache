import 'package:ecache/ecache.dart';
import 'package:flutter/cupertino.dart';

/// Least recently used cache. Items which are not read for the longest period
/// gets evicted first
class LruStrategy<K, V> extends AbstractStrategy<K, V> {
  int lastUse = 0;

  @override
  void onCapacity(K key) {
    if (storage.length < capacity) return;
    // Iterate on all keys, so the eviction is O(n) to allow an insertion at O(1)
    MapEntry<K, CacheEntry<K, V>> min = storage.entries.entries
        .reduce((element1, element2) => (element1.value as LruCacheEntry).lastUse < (element2.value as LruCacheEntry).lastUse ? element1 : element2);
    storage.onCapacity(min.key);
  }

  @override
  CacheEntry<K, V> createCacheEntry(K key, V element) {
    return LruCacheEntry(key, element, ++lastUse);
  }

  @override
  ProducerCacheEntry<K, V> createProducerCacheEntry(K key, Produce<K, V> produce) {
    return LruProducerCacheEntry(key, produce, ++lastUse);
  }

  @protected
  @override
  CacheEntry<K, V>? get(K key) {
    CacheEntry<K, V>? entry = storage.get(key);
    if (entry == null) return null;
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

/////////////////////////////////////////////////////////////////////////////

class LruProducerCacheEntry<K, V> extends LruCacheEntry<K, V> with ProducerCacheEntry<K, V> {
  LruProducerCacheEntry(K key, Produce<K, V> produce, int lastUse) : super(key, null, lastUse) {
    this.produce = produce;
  }
}
