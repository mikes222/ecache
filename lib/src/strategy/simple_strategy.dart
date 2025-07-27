import 'package:ecache/ecache.dart';
import 'package:ecache/src/strategy/abstract_strategy.dart';

/// SimpleCache is a basic cache implementation without any particular logic
/// than appending keys in the storage, and remove first inserted keys when
/// storage is full
class SimpleStrategy<K, V> extends AbstractStrategy<K, V> {
  @override
  void onCapacity(K key, V element) {
    if (storage.length < capacity) return;
    storage.onCapacity(storage.keys.first);
  }

  @override
  CacheEntry<K, V> createCacheEntry(K key, V value) {
    return CacheEntry(value);
  }

  @override
  ProducerCacheEntry<K, V> createProducerCacheEntry(K key, Produce<K, V> produce) {
    return SimpleProducerCacheEntry(produce);
  }

  @override
  CacheEntry<K, V>? get(K key) {
    CacheEntry<K, V>? entry = storage.get(key);
    return entry;
  }
}

/////////////////////////////////////////////////////////////////////////////

class SimpleProducerCacheEntry<K, V> extends CacheEntry<K, V> with ProducerCacheEntry<K, V> {
  SimpleProducerCacheEntry(Produce<K, V> produce) : super(null) {
    this.produce = produce;
  }
}
