part of ecache;

class LfuCache<K, V> extends Cache<K, V> {
  LfuCache({required Storage<K, V> storage, required int capacity}) : super(storage: storage, capacity: capacity);

  @override
  void _onCapacity(K key, V element) {
    var values = _internalStorage.values;
    // Iterate on all keys, so the eviction is O(n) to allow an insertion at O(1)
    LfuCacheEntry<K, V> min =
        values.map((e) => e as LfuCacheEntry<K, V>).reduce((element1, element2) => element1.use < element2.use ? element1 : element2);

    _internalStorage.remove(min.key);
  }

  @override
  CacheEntry<K, V> _createCacheEntry(K key, V value) {
    return LfuCacheEntry(key, value);
  }

  @override
  CacheEntry<K, V>? _beforeGet(CacheEntry<K, V> entry) {
    (entry as LfuCacheEntry).use++;
    return entry;
  }
}

/////////////////////////////////////////////////////////////////////////////

class LfuCacheEntry<K, V> extends CacheEntry<K, V> {
  int use = 0;
  LfuCacheEntry(K key, V? value) : super(key, value);
}
