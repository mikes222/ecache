import 'dart:async';

import 'package:ecache/src/strategy/abstract_strategy.dart';
import 'package:ecache/src/strategy/simple_strategy.dart';

import '../../ecache.dart';

/// Abstract base class for caches
class DefaultCache<K, V> extends Cache<K, V> {
  @override
  final Storage<K, V> storage;

  final AbstractStrategy<K, V> strategy;

  DefaultCache({Storage<K, V>? storage, required int capacity, AbstractStrategy<K, V>? strategy})
      : this.storage = storage ?? SimpleStorage<K, V>(),
        this.strategy = strategy ?? SimpleStrategy<K, V>() {
    this.strategy.init(this.storage, capacity);
  }

  /// return the element identified by [key]
  @override
  V? get(K key) {
    CacheEntry<K, V>? entry = strategy.get(key);
    assert(entry is! ProducerCacheEntry<K, V>, "Cannot get a value from a producer since the value is a future and the get() method is synchronously");
    return entry?.value;
  }

  Future<V?> getAsync(K key) async {
    CacheEntry<K, V>? entry = strategy.get(key);
    if (entry is ProducerCacheEntry<K, V>) {
      return entry.completer.future;
    }
    return entry?.value;
  }

  @override
  Future<V> getOrProduce(K key, Produce<K, V> produce) async {
    CacheEntry<K, V>? entry = storage.get(key);
    if (entry != null) {
      if (entry is ProducerCacheEntry<K, V>) {
        return entry.completer.future;
      }
      return entry.value!;
    }
    ProducerCacheEntry<K, V> producer = strategy.createProducerCacheEntry(key, produce);
    storage.set(key, producer);
    unawaited(producer.start(key));
    return producer.completer.future;
  }

  /// add [element] in the cache at [key]
  @override
  void set(K key, V element) {
    strategy.onCapacity(key, element);
    CacheEntry<K, V>? entry = strategy.createCacheEntry(key, element);
    storage.set(key, entry);
  }

  /// return the number of element in the cache
  @override
  int get length => storage.length;

  // Check if the cache contains a specific entry
  @override
  bool containsKey(K key) => storage.containsKey(key);

  /// remove all the entry inside the cache
  @override
  void clear() => storage.clear();

  @override
  V? remove(K key) {
    return storage.remove(key)?.value;
  }
}
