import '../cache_entry.dart';
import '../storage.dart';
import 'abstract_cache.dart';

/// A cache which evicts entries after a certain amount of time
class ExpirationCache<K, V> extends AbstractCache<K, V> {
  final Duration expiration;

  int lastCleanup;

  ExpirationCache(Storage<K, V>? storage, this.expiration, int capacity)
      : assert(!expiration.isNegative),
        assert(expiration.inMilliseconds > 0),
        lastCleanup = DateTime.now().millisecondsSinceEpoch,
        super(storage: storage, capacity: capacity);

  @override
  CacheEntry<K, V> createCacheEntry(K key, V element) {
    return ExpirationCacheEntry(key, element);
  }

  @override
  CacheEntry<K, V>? beforeGet(CacheEntry<K, V> entry) {
    if ((entry as ExpirationCacheEntry).insertTime <
        DateTime.now().millisecondsSinceEpoch - expiration.inMilliseconds) {
      // do not call onCapacity because if the entry is expired we do not want to keep it anyway
      storage.remove(entry.key);
      return null;
    }
    return entry;
  }

  @override
  void onCapacity(K key, V element) {
    int toRemove =
        DateTime.now().millisecondsSinceEpoch - expiration.inMilliseconds;
    if (lastCleanup > toRemove) return;
    Iterable<CacheEntry<K, V>> itemsToRemove = storage.entries.where(
        (element) => (element as ExpirationCacheEntry).insertTime < toRemove);
    itemsToRemove.forEach((element) {
      // do not call onCapacity because if the entry is expired we do not want to keep it anyway
      storage.remove(element.key);
    });
    lastCleanup = DateTime.now().millisecondsSinceEpoch;
  }
}

/////////////////////////////////////////////////////////////////////////////

class ExpirationCacheEntry<K, V> extends CacheEntry<K, V> {
  final int insertTime;

  ExpirationCacheEntry(K key, V? value)
      : insertTime = DateTime.now().millisecondsSinceEpoch,
        super(key, value);
}
