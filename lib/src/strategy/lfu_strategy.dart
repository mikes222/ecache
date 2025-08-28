import 'package:ecache/ecache.dart';

/// Least frequently used cache. Items which are not used often gets evicted first
class LfuStrategy<K, V> extends AbstractStrategy<K, V> {
  @override
  void onCapacity(K key) {
    if (storage.length < capacity) return;
    // Iterate on all keys, so the eviction is O(n) to allow an insertion at O(1)
    MapEntry<K, CacheEntry<K, V>> min = storage.entries.entries
        .reduce((element1, element2) => (element1.value as LfuCacheEntry).use < (element2.value as LfuCacheEntry).use ? element1 : element2);

    storage.onCapacity(min.key);
  }

  @override
  CacheEntry<K, V> createCacheEntry(K key, V value) {
    return LfuCacheEntry(ValueEntry(value));
  }

  @override
  CacheEntry<K, V> createAndStartProducerEntry(K key, Produce<K, V> produce, int timeout) {
    return LfuCacheEntry(ProducerEntry(produce)..start(key, timeout));
  }

  @override
  CacheEntry<K, V>? get(K key) {
    CacheEntry<K, V>? entry = storage.get(key);
    if (entry == null) return null;
    (entry as LfuCacheEntry).use++;
    return entry;
  }
}

/////////////////////////////////////////////////////////////////////////////

class LfuCacheEntry<K, V> extends CacheEntry<K, V> {
  int use = 0;

  LfuCacheEntry(super.entry);
}
