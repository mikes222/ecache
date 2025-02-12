import '../../ecache.dart';

typedef Future<V> Produce<K, V>(K key);

/// Abstract base class for caches
abstract class AbstractCache<K, V> extends Cache<K, V> {
  final Storage<K, V> storage;

  final Map<K, _Producer<K, V>> _producers = {};

  AbstractCache({Storage<K, V>? storage, required int capacity})
      : this.storage = storage ?? SimpleStorage<K, V>(),
        super(capacity: capacity);

  /// return the element identified by [key]
  @override
  V? get(K key) {
    CacheEntry<K, V>? entry = storage[key];

    if (entry == null) {
      return null;
    }

    entry = beforeGet(entry);

    return entry?.value;
  }

  /// Returns the requested entry or calls the [produce] function to produce the
  /// requested entry.
  /// It is guaranteed that the producer will be executed only once for each
  /// [key] for as long as the key is already requested or still in the cache.
  Future<V> getOrProduce(K key, Produce<K, V> produce) async {
    CacheEntry<K, V>? entry = storage[key];
    if (entry != null) {
      entry = beforeGet(entry);
      if (entry != null) return entry.value!;
    }
    _Producer<K, V>? producer = _producers[key];
    if (producer != null) {
      return producer.future;
    }

    producer = _Producer(this, produce, key);
    _producers[key] = producer;
    return producer.start();
  }

  /// Process the entry found in the storage before returning it. If this method
  /// returns null the entry is considered as expired and will not be returned
  /// to the caller.
  CacheEntry<K, V>? beforeGet(CacheEntry<K, V> entry) {
    return entry;
  }

  /// add [element] in the cache at [key]
  @override
  void set(K key, V element) {
    onCapacity(key, element);
    storage[key] = createCacheEntry(key, element);
  }

  /// called if we want to
  /// insert another item denoted by [key] and [element] into the map. This
  /// method checks if the capacity is reached and eventually evicts old items.
  void onCapacity(K key, V element);

  /// internal [set]
  CacheEntry<K, V> createCacheEntry(K key, V element);

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

//////////////////////////////////////////////////////////////////////////////

class _Producer<K, V> {
  final AbstractCache<K, V> cache;

  final Produce<K, V> produce;

  final K key;

  late Future<V> future;

  _Producer(this.cache, this.produce, this.key);

  Future<V> start() async {
    future = produce(key);
    await future.then((element) {
      cache.set(key, element);
      cache._producers.remove(key);
    });
    return future;
  }
}
