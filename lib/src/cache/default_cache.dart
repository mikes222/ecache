import 'dart:async';

import '../../ecache.dart';

/// A generic, abstract base class for [Cache] implementations.
///
/// This class provides the core caching logic, delegating entry management and
/// eviction policies to a specified [AbstractStrategy]. It uses a [Storage]
/// mechanism to hold the cache entries.
class DefaultCache<K, V> extends Cache<K, V> {
  @override
  final Storage<K, V> storage;

  /// The strategy used for cache entry management and eviction.
  final AbstractStrategy<K, V> strategy;

  /// Creates a new [DefaultCache].
  ///
  /// A [capacity] for the cache must be provided.
  ///
  /// An optional [storage] mechanism can be provided. If not, a [SimpleStorage]
  /// instance is used.
  ///
  /// An optional [strategy] can be provided. If not, a [SimpleStrategy]
  /// instance is used.
  DefaultCache({Storage<K, V>? storage, required int capacity, AbstractStrategy<K, V>? strategy})
      : storage = storage ?? SimpleStorage<K, V>(),
        strategy = strategy ?? SimpleStrategy<K, V>() {
    this.strategy.init(this.storage, capacity);
  }

  /// Synchronously retrieves the value for the given [key].
  ///
  /// This method delegates to the configured [strategy]. It cannot be used to
  /// retrieve a [ProducerCacheEntry] because its value is a [Future].
  @override
  V? get(K key) {
    CacheEntry<K, V>? entry = strategy.get(key);
    assert(entry is! ProducerCacheEntry<K, V>, "Cannot get a value from a producer since the value is a future and the get() method is synchronously");
    return entry?.value;
  }

  /// Asynchronously retrieves the value for the given [key].
  ///
  /// This method can handle [ProducerCacheEntry] by returning the [Future]
  /// that will complete with the produced value.
  @override
  Future<V?> getAsync(K key) async {
    CacheEntry<K, V>? entry = strategy.get(key);
    if (entry is ProducerCacheEntry<K, V>) {
      return entry.completer.future;
    }
    return entry?.value;
  }

  @override
  Future<V> getOrProduce(K key, Produce<K, V> produce, [int timeoutMilliseconds = 60000]) async {
    CacheEntry<K, V>? entry = storage.get(key);
    if (entry != null) {
      if (entry is ProducerCacheEntry<K, V>) {
        return entry.completer.future;
      }
      return entry.value!;
    }

    strategy.onCapacity(key);
    ProducerCacheEntry<K, V> producer = strategy.createProducerCacheEntry(key, produce);
    storage.set(key, producer);
    unawaited(producer.start(key, timeoutMilliseconds));

    try {
      return await producer.completer.future;
    } catch (e) {
      storage.remove(key);
      rethrow;
    }
  }

  @override
  Future<V> produce(K key, Produce<K, V> produce, [int timeoutMilliseconds = 60000]) async {
    CacheEntry<K, V>? entry = storage.get(key);
    if (entry != null) {
      if (entry is ProducerCacheEntry<K, V>) {
        return entry.completer.future;
      }
    }

    strategy.onCapacity(key);
    ProducerCacheEntry<K, V> producer = strategy.createProducerCacheEntry(key, produce);
    storage.set(key, producer);
    unawaited(producer.start(key, timeoutMilliseconds));

    try {
      return await producer.completer.future;
    } catch (e) {
      storage.remove(key);
      rethrow;
    }
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
