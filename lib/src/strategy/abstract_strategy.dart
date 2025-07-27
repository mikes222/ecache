import 'package:ecache/ecache.dart';

abstract class AbstractStrategy<K, V> {
  late final Storage<K, V> storage;

  /// The maximum capacity of the cache. When more values will be added to the
  /// cache the least "desired" values will be removed. "desired" values are
  /// determined by the type of the cache. For example the lruCache will evict
  /// the item wich was not used for the longest time.
  late final int capacity;

  void init(Storage<K, V> storage, int capacity) {
    this.storage = storage;
    this.capacity = capacity;
  }

  /// called if we want to
  /// insert another item denoted by [key] and [element] into the map. This
  /// method checks if the capacity is reached and eventually evicts old items.
  void onCapacity(K key, V element);

  CacheEntry<K, V> createCacheEntry(K key, V element);

  ProducerCacheEntry<K, V> createProducerCacheEntry(K key, Produce<K, V> produce);

  /// Process the entry found in the storage before returning it. If this method
  /// returns null the entry is considered as expired and will not be returned
  /// to the caller.
  CacheEntry<K, V>? get(K key);
}
