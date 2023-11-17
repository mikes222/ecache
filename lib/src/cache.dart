
/// The interace for the cache
abstract class Cache<K, V> {

  /// The maximum capacity of the cache. When more values will be added to the
  /// cache the least "desired" values will be removed. "desired" values are
  /// determined by the type of the cache. For example the lruCache will evict
  /// the item wich was not used for the longest time.
  final int capacity;

  Cache({required this.capacity}) : assert(capacity > 0);

  /// return the element identified by [key] or null if the key is not found.
  V? get(K key);

  /// add [element] in the cache at [key] and eventually deletes an old item
  void set(K key, V element);

  /// return the number of element in the cache. Take this with a grain of salt
  int get length;

  /// Check if the cache contains a specific entry. It is better to use [get] and
  /// check for null-returns
  bool containsKey(K key);

  /// return the value at [key]. Same as [get]
  dynamic operator [](K key) {
    return get(key);
  }

  /// assign [element] for [key]. Same as [set]
  void operator []=(K key, V element) {
    set(key, element);
  }

  /// remove all the entry inside the cache and evicts all entries
  void clear();

  /// Removes an entry from the cache. Returns null if the entry was not found.
  /// Note that the entry which may be returned is already evicted.
  V? remove(K key);
}
