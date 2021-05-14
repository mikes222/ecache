import 'package:ecache/ecache.dart';

class ExpirationCache<K, V> extends Cache<K, V> {
  final Duration expiration;

  ExpirationCache(storage, this.expiration, int capacity)
      : assert(!expiration.isNegative),
        assert(expiration.inMilliseconds > 0),
        super(storage: storage, capacity: capacity);

  @override
  CacheEntry<K, V> _createCacheEntry(K key, V element) {
    return ExpirationCacheEntry(key, element);
  }

  @override
  CacheEntry<K, V>? _beforeGet(CacheEntry<K, V> entry) {
    if (entry is ExpirationCacheEntry) {
      if ((entry as ExpirationCacheEntry).insertTime < DateTime.now().millisecondsSinceEpoch - expiration.inMilliseconds) {
        remove(entry.key);
        return null;
      }
    }
    return entry;
  }
}

/////////////////////////////////////////////////////////////////////////////

class ExpirationCacheEntry<K, V> extends CacheEntry<K, V> {
  final int insertTime;

  ExpirationCacheEntry(K key, V? value)
      : insertTime = DateTime.now().millisecondsSinceEpoch,
        super(key, value);
}
