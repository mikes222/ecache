import '../../ecache.dart';

/// A cache strategy that implements a simple First-In, First-Out (FIFO)
/// eviction policy.
///
/// When the cache reaches its capacity, the oldest entry (the first one that was
/// inserted) is removed to make space for a new one.
class SimpleStrategy<K, V> extends AbstractStrategy<K, V> {
  @override

  /// Evicts the oldest entry if the cache is at capacity.
  @override
  void onCapacity(K key, V element) {
    if (storage.length < capacity) return;
    storage.onCapacity(storage.keys.first);
  }

  @override

  /// Creates a standard [CacheEntry] with the given value.
  @override
  CacheEntry<K, V> createCacheEntry(K key, V value) {
    return CacheEntry(value);
  }

  @override

  /// Creates a [SimpleProducerCacheEntry] for asynchronous value production.
  @override
  ProducerCacheEntry<K, V> createProducerCacheEntry(K key, Produce<K, V> produce) {
    return SimpleProducerCacheEntry(produce);
  }

  @override

  /// Retrieves an entry from storage without any additional processing.
  @override
  CacheEntry<K, V>? get(K key) {
    CacheEntry<K, V>? entry = storage.get(key);
    return entry;
  }
}

/////////////////////////////////////////////////////////////////////////////

/// A concrete implementation of a [ProducerCacheEntry] for the [SimpleStrategy].
class SimpleProducerCacheEntry<K, V> extends CacheEntry<K, V> with ProducerCacheEntry<K, V> {
  /// Creates a new [SimpleProducerCacheEntry] with the given [produce] function.
  SimpleProducerCacheEntry(Produce<K, V> produce) : super(null) {
    this.produce = produce;
  }
}
