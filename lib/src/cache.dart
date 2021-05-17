part of ecache;

///
/// returns the value for the given key [key] or null. This method will be called if the value for the requested [key] is not
/// available in the cache.
///
typedef V LoaderFunc<K, V>(K key);

abstract class Cache<K, V> {
  final Storage<K, V> _internalStorage;
  final int capacity;

  Cache({required Storage<K, V> storage, required this.capacity})
      : assert(capacity > 0),
        _internalStorage = storage;

  /// return the element identified by [key]
  V? get(K key) {
    CacheEntry<K, V>? entry = _get(key);

    if (entry == null) {
      return null;
    }

    entry = _beforeGet(entry);

    if (entry == null) {
      return null;
    }

    return entry.value;
  }

  @protected
  CacheEntry<K, V>? _beforeGet(CacheEntry<K, V> entry) {
    return entry;
  }

  /// internal [get]
  CacheEntry<K, V>? _get(K key) => _internalStorage[key];

  /// add [element] in the cache at [key]
  void set(K key, V element) {
    if (!containsKey(key) && length >= capacity) {
      _onCapacity(key, element);
    }
    _internalStorage[key] = _createCacheEntry(key, element);
  }

  @protected
  void _onCapacity(K key, V element);

  /// internal [set]
  @protected
  CacheEntry<K, V> _createCacheEntry(K key, V element);

  /// return the number of element in the cache
  int get length => _internalStorage.length;

  // Check if the cache contains a specific entry
  bool containsKey(K key) => _internalStorage.containsKey(key);

  /// return the value at [key]
  dynamic operator [](K key) {
    return get(key);
  }

  /// assign [element] for [key]
  void operator []=(K key, V element) {
    set(key, element);
  }

  /// remove all the entry inside the cache
  void clear() => _internalStorage.clear();

  // set storage(Storage<K, V> storage) {
  //   _internalStorage = storage;
  // }

  // Storage<K, V> get storage => _internalStorage;

  V? remove(K key) {
    return _remove(key);
  }

  V? _remove(K key) {
    return _internalStorage.remove(key)?.value;
  }
}
