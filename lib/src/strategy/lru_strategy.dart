import 'package:ecache/ecache.dart';

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
  CacheEntry<K, V> createCacheEntry(K key, V value) {
    return LruCacheEntry(ValueEntry(value), ++lastUse);
  }

  @override
  CacheEntry<K, V> createAndStartProducerEntry(K key, Produce<K, V> produce, int timeout) {
    return LruCacheEntry(ProducerEntry(produce)..start(key, timeout), ++lastUse);
  }

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

  LruCacheEntry(super.entry, this.lastUse);

  void updateLastUse(int lastUse) {
    this.lastUse = lastUse;
  }
}
