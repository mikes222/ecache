import 'dart:async';

import 'package:ecache/src/storage/storage_mgr.dart';

import '../../ecache.dart';

/// A generic class for [Cache] implementations.
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
      : storage = storage ?? (StorageMgr().isEnabled() ? StatisticsStorage<K, V>() : SimpleStorage<K, V>()),
        strategy = strategy ?? SimpleStrategy<K, V>() {
    this.strategy.init(this.storage, capacity);
  }

  @override
  void dispose() {
    storage.dispose();
  }

  @override
  V? get(K key) {
    CacheEntry<K, V>? cacheEntry = strategy.get(key);
    if (cacheEntry == null) return null;
    if (cacheEntry.entry is ProducerEntry<K, V>) {
      throw Exception("Cannot get a value from a producer since the value is a future and the get() method is synchronously");
    }
    return cacheEntry.getValue();
  }

  /// Asynchronously retrieves the value for the given [key].
  ///
  /// This method can handle [ProducerCacheEntry] by returning the [Future]
  /// that will complete with the produced value.
  @override
  Future<V?> getAsync(K key) async {
    CacheEntry<K, V>? cacheEntry = strategy.get(key);
    if (cacheEntry == null) return null;
    if (cacheEntry.entry is ProducerEntry<K, V>) {
      return (cacheEntry.entry as ProducerEntry<K, V>).completer.future;
    }
    return cacheEntry.getValue();
  }

  @override
  Future<V> getOrProduce(K key, Produce<K, V> produce, [int timeoutMilliseconds = 60000]) async {
    CacheEntry<K, V>? cacheEntry = storage.get(key);
    if (cacheEntry != null) {
      if (cacheEntry.entry is ProducerEntry<K, V>) {
        return (cacheEntry.entry as ProducerEntry<K, V>).completer.future;
      }
      return cacheEntry.getValue();
    }

    strategy.onCapacity(key);
    CacheEntry<K, V> producer = strategy.createAndStartProducerEntry(key, produce, timeoutMilliseconds);
    storage.set(key, producer);

    try {
      V value = await (producer.entry as ProducerEntry).completer.future;
      // replace this entry with a normal cacheEntry so that get() works
      producer.entry = ValueEntry(value);
      return value;
    } catch (e) {
      // succeeding call will return the same exception until the entry is removed
      //storage.remove(key);
      rethrow;
    }
  }

  @override
  Future<V> produce(K key, Produce<K, V> produce, [int timeoutMilliseconds = 60000]) async {
    CacheEntry<K, V>? cacheEntry = storage.get(key);
    if (cacheEntry != null) {
      if (cacheEntry.entry is ProducerEntry<K, V>) {
        return (cacheEntry.entry as ProducerEntry<K, V>).completer.future;
      }
    }

    strategy.onCapacity(key);
    CacheEntry<K, V> producer = strategy.createAndStartProducerEntry(key, produce, timeoutMilliseconds);
    storage.set(key, producer);

    try {
      V value = await (producer.entry as ProducerEntry).completer.future;
      // replace this entry with a normal cacheEntry so that get() works
      producer.entry = ValueEntry(value);
      return value;
    } catch (e) {
      // succeeding call will return the same exception until the entry is removed
      // storage.remove(key);
      rethrow;
    }
  }

  @override
  V getOrProduceSync(K key, ProduceSync<K, V> produce) {
    CacheEntry<K, V>? cacheEntry = storage.get(key);
    if (cacheEntry != null) {
      if (cacheEntry.entry is ProducerEntry<K, V>) {
        throw Exception("Cannot get a value from a producer since the value is a future and the get() method is synchronously");
      }
      return cacheEntry.getValue();
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
    CacheEntry<K, V>? cacheEntry = strategy.createCacheEntry(key, element);
    storage.set(key, cacheEntry);
  }

  @override
  void setMap(Map<K, V> elements) {
    assert(elements.isNotEmpty, "Cannot set an empty map");
    strategy.onCapacity(elements.keys.first);
    elements.forEach((key, value) {
      CacheEntry<K, V>? cacheEntry = strategy.createCacheEntry(key, value);
      storage.set(key, cacheEntry);
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
    CacheEntry<K, V>? cacheEntry = storage.remove(key);
    if (cacheEntry == null) return null;
    if (cacheEntry.entry is ProducerEntry<K, V>) {
      (cacheEntry.entry as ProducerEntry<K, V>).abortProcess();
      return null;
    }
    return cacheEntry.getValue();
  }
}
