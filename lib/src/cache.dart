
/// The interace for the cache
abstract class Cache<K, V> {
  final int capacity;

  Cache({required this.capacity}) : assert(capacity > 0);

  /// return the element identified by [key]
  V? get(K key);

  /// add [element] in the cache at [key]
  void set(K key, V element);

  /// return the number of element in the cache
  int get length;

  // Check if the cache contains a specific entry
  bool containsKey(K key);

  /// return the value at [key]
  dynamic operator [](K key) {
    return get(key);
  }

  /// assign [element] for [key]
  void operator []=(K key, V element) {
    set(key, element);
  }

  /// remove all the entry inside the cache
  void clear();

  /// Removes an entry from the cache. Returns null if the entry was not found.
  /// Note that the entry which may be returned is already evicted.
  V? remove(K key);
}
