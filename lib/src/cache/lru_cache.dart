part of ecache;

class LruCache<K, V> extends Cache<K, V> {
  int lastUse = 0;
  LruCache({required Storage<K, V> storage, required int capacity}) : super(storage: storage, capacity: capacity);

  @override
  void _onCapacity(K key, V element) {
    var values = _internalStorage.values;
    // Iterate on all keys, so the eviction is O(n) to allow an insertion at O(1)
    LruCacheEntry<K, V> min = values
        .map((e) => e as LruCacheEntry<K, V>)
        .reduce((element1, element2) => element1.lastUse < element2.lastUse ? element1 : element2);

    _internalStorage.remove(min.key);
  }

  @override
  CacheEntry<K, V> _createCacheEntry(K key, V element) {
    return LruCacheEntry(key, element, ++lastUse);
  }

  @protected
  CacheEntry<K, V>? _beforeGet(CacheEntry<K, V> entry) {
    (entry as LruCacheEntry).updateLastUse(++lastUse);
    return entry;
  }
}

/////////////////////////////////////////////////////////////////////////////

class LruCacheEntry<K, V> extends CacheEntry<K, V> {
  int lastUse;

  LruCacheEntry(K key, V? value, this.lastUse) : super(key, value);

  void updateLastUse(int lastUse) {
    this.lastUse = lastUse;
  }
}
