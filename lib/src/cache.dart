import 'storage.dart';

/// A function that produces a value for a given [key].
///
/// This is used for caches that can fetch or compute values asynchronously.
typedef Future<V> Produce<K, V>(K key);

/// The interface for a cache that stores key-value pairs.
///
/// Defines the core interface for a cache, providing methods for storing,
/// retrieving, and managing cache entries.
abstract class Cache<K, V> {
  /// The underlying [Storage] mechanism used by the cache.
  Storage<K, V> get storage;

  /// Synchronously returns the element for the given [key], or `null` if the key is not found.
  V? get(K key);

  /// Asynchronously returns the element for the given [key], or `null` if the key is not found.
  Future<V?> getAsync(K key);

  /// Returns the requested entry or calls the [produce] function to produce it.
  ///
  /// It is guaranteed that the producer will be executed only once for each [key]
  /// as long as the key is already requested or still in the cache.
  Future<V> getOrProduce(K key, Produce<K, V> produce);

  /// Associates the [key] with the given [element] in the cache.
  /// If the cache is at capacity, an existing entry may be evicted.
  void set(K key, V element);

  /// Returns the number of entries in the cache.
  int get length;

  /// Returns `true` if the cache contains an entry for the given [key].
  bool containsKey(K key);

  /// Returns the value for the given [key]. This is an alias for [get].
  V? operator [](K key) {
    return get(key);
  }

  /// Associates the [key] with the given [element]. This is an alias for [set].
  void operator []=(K key, V element) {
    set(key, element);
  }

  /// Removes all entries from the cache.
  void clear();

  /// Removes the entry for the given [key] and returns its value.
  /// Returns `null` if the key was not found.
  V? remove(K key);
}
