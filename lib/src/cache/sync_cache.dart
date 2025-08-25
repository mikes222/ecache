import 'dart:async';

import '../../ecache.dart';

/// A generic, stripped down class for [Cache] implementations if you do not need async calls.
///
/// This class provides the core caching logic, delegating entry management and
/// eviction policies to a specified [AbstractStrategy]. It uses a [Storage]
/// mechanism to hold the cache entries.
class SyncCache<K, V> extends Cache<K, V> {
  @override
  final Storage<K, V> storage;

  /// The strategy used for cache entry management and eviction.
  final AbstractStrategy<K, V> strategy;

  /// Creates a new [SyncCache].
  ///
  /// A [capacity] for the cache must be provided.
  ///
  /// An optional [storage] mechanism can be provided. If not, a [SimpleStorage]
  /// instance is used.
  ///
  /// An optional [strategy] can be provided. If not, a [SimpleStrategy]
  /// instance is used.
  SyncCache({Storage<K, V>? storage, required int capacity, AbstractStrategy<K, V>? strategy})
      : storage = storage ?? SimpleStorage<K, V>(),
        strategy = strategy ?? SimpleStrategy<K, V>() {
    this.strategy.init(this.storage, capacity);
  }

  /// Synchronously returns the element for the given [key], or `null` if the key is not found.
  @override
  V? get(K key) {
    CacheEntry<K, V>? entry = strategy.get(key);
    return entry?.value;
  }

  /// Asynchronously retrieves the value for the given [key].
  ///
  /// This method can handle [ProducerCacheEntry] by returning the [Future]
  /// that will complete with the produced value.
  @override
  Future<V?> getAsync(K key) async {
    throw UnimplementedError();
  }

  @override
  Future<V> getOrProduce(K key, Produce<K, V> produce, [int timeoutMilliseconds = 60000]) async {
    throw UnimplementedError();
  }

  @override
  Future<V> produce(K key, Produce<K, V> produce, [int timeoutMilliseconds = 60000]) async {
    throw UnimplementedError();
  }

  @override
  V getOrProduceSync(K key, ProduceSync<K, V> produce) {
    CacheEntry<K, V>? entry = storage.get(key);
    if (entry != null) {
      return entry.value!;
    }

    V value = produce(key);
    set(key, value);
    return value;
  }

  /// Associates the [key] with the given [element] in the cache.
  ///
  /// The configured [strategy] handles the creation of the [CacheEntry] and
  /// any necessary evictions if the cache is at capacity.
  @override
  void set(K key, V element) {
    strategy.onCapacity(key);
    CacheEntry<K, V>? entry = strategy.createCacheEntry(key, element);
    storage.set(key, entry);
  }

  @override
  void setMap(Map<K, V> elements) {
    assert(elements.isNotEmpty, "Cannot set an empty map");
    strategy.onCapacity(elements.keys.first);
    elements.forEach((key, value) {
      CacheEntry<K, V>? entry = strategy.createCacheEntry(key, value);
      storage.set(key, entry);
    });
    strategy.onCapacity(elements.keys.last);
  }

  /// Returns the number of entries in the cache.
  @override
  int get length => storage.length;

  /// Returns `true` if the cache contains an entry for the given [key].
  @override
  bool containsKey(K key) => storage.containsKey(key);

  /// Removes all entries from the cache.
  @override
  void clear() => storage.clear();

  /// Removes the entry for the given [key] from the cache and returns its value.
  @override
  V? remove(K key) {
    return storage.remove(key)?.value;
  }
}
