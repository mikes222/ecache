import '../../ecache.dart';

/// Defines the interface for a cache strategy, which governs entry management
/// and eviction policies within a [Cache].
abstract class AbstractStrategy<K, V> {
  /// The storage mechanism that this strategy will operate on.
  late final Storage<K, V> storage;

  /// The maximum number of entries the cache can hold.
  late final int capacity;

  /// Initializes the strategy with a [storage] mechanism and a [capacity].
  void init(Storage<K, V> storage, int capacity) {
    assert(capacity > 0, "Capacity must be greater than zero");
    this.storage = storage;
    this.capacity = capacity;
  }

  /// A hook that is called before a new entry is added to the cache.
  ///
  /// This method is responsible for checking if the cache is at capacity and
  /// evicting one or more entries if necessary.
  void onCapacity(K key);

  /// Creates a standard [CacheEntry] for the given [key] and [element].
  CacheEntry<K, V> createCacheEntry(K key, V element);

  /// Creates a [ProducerCacheEntry] for a value that will be generated by [produce].
  ProducerCacheEntry<K, V> createProducerCacheEntry(K key, Produce<K, V> produce);

  /// A hook that is called when an entry is retrieved from the cache.
  ///
  /// This allows the strategy to perform actions like updating usage statistics (e.g., for LRU).
  /// If this method returns `null`, the entry is considered expired and will not be returned.
  CacheEntry<K, V>? get(K key);
}
