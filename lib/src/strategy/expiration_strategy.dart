import 'package:ecache/ecache.dart';
import 'package:ecache/src/strategy/abstract_strategy.dart';

/// A cache which evicts entries after a certain amount of time
class ExpirationStrategy<K, V> extends AbstractStrategy<K, V> {
  final int expiration;

  int lastCleanup;

  ExpirationStrategy({required Duration expiration})
      : assert(!expiration.isNegative),
        assert(expiration.inMilliseconds > 0),
        lastCleanup = DateTime.now().millisecondsSinceEpoch,
        this.expiration = expiration.inMilliseconds;

  @override
  void onCapacity(K key, V element) {
    if (storage.length < capacity) return;
    int toRemove = DateTime.now().millisecondsSinceEpoch - expiration;
    if (lastCleanup > toRemove) return;
    Iterable<MapEntry<K, CacheEntry<K, V>>> itemsToRemove =
        storage.entries.entries.where((element) => (element.value as ExpirationCacheEntry).insertTime < toRemove);
    // convert to list to avoid concurrent modification exceptions
    itemsToRemove.toList().forEach((element) {
      // do not call onCapacity because if the entry is expired we do not want to keep it anyway
      storage.removeInternal(element.key);
    });
    lastCleanup = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  CacheEntry<K, V> createCacheEntry(K key, V element) {
    return ExpirationCacheEntry(key, element);
  }

  @override
  ProducerCacheEntry<K, V> createProducerCacheEntry(K key, Produce<K, V> produce) {
    return ExpirationProducerCacheEntry(key, produce);
  }

  @override
  CacheEntry<K, V>? get(K key) {
    CacheEntry<K, V>? entry = storage.get(key);
    if (entry == null) return null;
    if ((entry as ExpirationCacheEntry).insertTime < DateTime.now().millisecondsSinceEpoch - expiration) {
      // do not call onCapacity because if the entry is expired we do not want to keep it anyway
      storage.removeInternal(key);
      return null;
    }
    return entry;
  }
}

/////////////////////////////////////////////////////////////////////////////

class ExpirationCacheEntry<K, V> extends CacheEntry<K, V> {
  final int insertTime;

  ExpirationCacheEntry(K key, V? value)
      : insertTime = DateTime.now().millisecondsSinceEpoch,
        super(value);
}

/////////////////////////////////////////////////////////////////////////////

class ExpirationProducerCacheEntry<K, V> extends ExpirationCacheEntry<K, V> with ProducerCacheEntry<K, V> {
  ExpirationProducerCacheEntry(K key, Produce<K, V> produce) : super(key, null) {
    this.produce = produce;
  }

  @override
  set value(V? value) {
    this.value = value;
  }
}
