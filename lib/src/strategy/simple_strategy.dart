import '../../ecache.dart';

/// A cache strategy that implements a simple First-In, First-Out (FIFO)
/// eviction policy.
///
/// When the cache reaches its capacity, the oldest entry (the first one that was
/// inserted) is removed to make space for a new one.
class SimpleStrategy<K, V> extends AbstractStrategy<K, V> {
  /// Evicts the oldest entry if the cache is at capacity.
  @override
  void onCapacity(K key) {
    if (storage.length < capacity) return;
    storage.onCapacity(storage.keys.first);
  }

  /// Creates a standard [CacheEntry] with the given value.
  @override
  CacheEntry<K, V> createCacheEntry(K key, V value) {
    return CacheEntry(ValueEntry(value));
  }

  /// Creates a [SimpleProducerCacheEntry] for asynchronous value production.
  @override
  CacheEntry<K, V> createAndStartProducerEntry(K key, Produce<K, V> produce, int timeout) {
    return CacheEntry(ProducerEntry(produce)..start(key, timeout));
  }

  /// Retrieves an entry from storage without any additional processing.
  @override
  CacheEntry<K, V>? get(K key) {
    CacheEntry<K, V>? entry = storage.get(key);
    return entry;
  }
}
