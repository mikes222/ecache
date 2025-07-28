import 'storage.dart';

/// A function that produces a value for a given [key].
///
/// This is used for caches that can fetch or compute values asynchronously.
typedef Produce<K, V> = Future<V> Function(K key);

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

  /// Retrieves the value associated with [key] from the cache, or generates it if it is not present.
  ///
  /// If the cache contains an entry for [key], its value is returned.
  /// If the entry is a [ProducerCacheEntry] (meaning a value is already being produced),
  /// this method returns the existing [Future] that will complete with the produced value.
  ///
  /// If the key is not in the cache, the [produce] function is called to generate the value.
  /// The `produce` function is only called once, even if `getOrProduce` is called multiple
  /// times for the same key while the value is being generated.
  ///
  /// The optional [timeoutMilliseconds] parameter specifies the maximum time to wait for the
  /// [produce] function to complete. If the timeout is exceeded, a [TimeoutException] is thrown,
  /// and the key is not cached. The default timeout is 60,000 milliseconds (60 seconds).
  ///
  /// If the [produce] function throws any other error, the key is also not cached, and the
  /// `Future` returned by this method completes with that error.
  ///
  /// Example:
  /// ```dart
  /// final value = await cache.getOrProduce('user:123', (key) async {
  ///   // Fetch user data from a database or API
  ///   return await fetchUserData(key);
  /// });
  /// ```
  Future<V> getOrProduce(K key, Produce<K, V> produce, [int timeoutMilliseconds = 60000]);

  /// Generates the value for the given [key] and stores it in the cache. If the produce method is
  /// already in progress, its completes is returned. If the cache is at capacity, an existing entry may be evicted.
  Future<V> produce(K key, Produce<K, V> produce, [int timeoutMilliseconds = 60000]);

  /// Associates the [key] with the given [element] in the cache.
  /// If the cache is at capacity, an existing entry may be evicted.
  void set(K key, V element);

  /// stores a map of elements in the cache. If the cache is at capacity, existing entries may be evicted.
  /// This is a small performance gain over calling set multiple times because the capacity-verification is done only once before
  /// filling the cache and once after filling the cache. Usually it does not justify the overhead of creating a map just for this purpose.
  void setMap(Map<K, V> elements);

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
