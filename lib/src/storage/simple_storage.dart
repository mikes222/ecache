part of ecache;

///
/// This method will be called if a value is removed from the storage. It can be used to dispose items
///
typedef void OnEvict<K, V>(K k, V v);

class SimpleStorage<K, V> implements Storage<K, V> {
  final Map<K, CacheEntry<K, V>> _internalMap = LinkedHashMap<K, CacheEntry<K, V>>();

  /// if onEvict is set that method is called whenever an entry is removed from the cache.
  /// At the time the method is called the entry is already removed.
  OnEvict<K, V>? onEvict;

  SimpleStorage({this.onEvict});

  @override
  CacheEntry<K, V>? operator [](K key) {
    var ce = _internalMap[key];
    return ce;
  }

  @override
  void operator []=(K key, CacheEntry<K, V> value) {
    CacheEntry<K, V>? oldEntry = _internalMap[key];
    if (oldEntry != null && oldEntry.value != null && onEvict != null) {
      onEvict!(oldEntry.key, oldEntry.value!);
    }
    _internalMap[key] = value;
  }

  @override
  void clear() {
    if (onEvict != null) {
      _internalMap.values.forEach((element) {
        if (element.value != null) onEvict!(element.key, element.value!);
      });
    }
    _internalMap.clear();
  }

  @override
  CacheEntry<K, V>? get(K key) {
    return this[key];
  }

  @override
  Storage set(K key, CacheEntry<K, V> value) {
    CacheEntry<K, V>? oldEntry = _internalMap[key];
    if (oldEntry != null && onEvict != null && oldEntry.value != null) {
      onEvict!(oldEntry.key, oldEntry.value!);
    }
    this[key] = value;
    return this;
  }

  @override
  CacheEntry<K, V>? remove(K key) {
    CacheEntry<K, V>? oldEntry = _internalMap[key];
    if (oldEntry != null && oldEntry.value != null && onEvict != null) {
      onEvict!(oldEntry.key, oldEntry.value!);
    }
    return _internalMap.remove(key);
  }

  @override
  int get length => _internalMap.length;

  @override
  bool containsKey(K key) {
    return _internalMap.containsKey(key);
  }

  @override
  List<K> get keys => _internalMap.keys.toList();

  @override
  List<CacheEntry<K, V>> get values => _internalMap.values.toList();
}
