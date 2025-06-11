import '../cache_entry.dart';
import '../storage.dart';
import 'abstract_cache.dart';

/// A cache which evicts entries after a certain amount of time
class ExpirationCache<K, V> extends AbstractCache<K, V> {
  final int expiration;

  int lastCleanup;

  ExpirationCache({Storage<K, V>? storage, required Duration expiration, required int capacity})
      : assert(!expiration.isNegative),
        assert(expiration.inMilliseconds > 0),
        lastCleanup = DateTime.now().millisecondsSinceEpoch,
        this.expiration = expiration.inMilliseconds,
        super(storage: storage, capacity: capacity);

  @override
  CacheEntry<K, V> createCacheEntry(K key, V element) {
    return ExpirationCacheEntry(key, element);
  }

  @override
  CacheEntry<K, V>? beforeGet(K key, CacheEntry<K, V> entry) {
    if ((entry as ExpirationCacheEntry).insertTime < DateTime.now().millisecondsSinceEpoch - expiration) {
      // do not call onCapacity because if the entry is expired we do not want to keep it anyway
      storage.removeInternal(key);
      return null;
    }
    return entry;
  }

  @override
  void onCapacity(K key, V element) {
    if (length < capacity) return;
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
}

/////////////////////////////////////////////////////////////////////////////

class ExpirationCacheEntry<K, V> extends CacheEntry<K, V> {
  final int insertTime;

  ExpirationCacheEntry(K key, V? value)
      : insertTime = DateTime.now().millisecondsSinceEpoch,
        super(value);
}
