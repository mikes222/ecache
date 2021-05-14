part of ecache;

/// SimpleCache is a basic cache implementation without any particular logic
/// than appending keys in the storage, and remove first inserted keys when storage is full
class SimpleCache<K, V> extends Cache<K, V> {
  SimpleCache({required Storage<K, V> storage, required int capacity}) : super(storage: storage, capacity: capacity);

  @override
  CacheEntry<K, V> _createCacheEntry(K key, V value) {
    return CacheEntry(key, value);
  }

  @override
  void _onCapacity(K key, V element) {
    _internalStorage.remove(_internalStorage.keys.first);
  }
}
