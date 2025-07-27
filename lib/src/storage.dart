import 'cache_entry.dart';

/// A callback function that is invoked when an entry is evicted from the cache.
typedef void OnEvict<K, V>(K k, V v);

/// Defines the interface for a storage mechanism used by a [Cache].
///
/// A storage mechanism is responsible for storing and retrieving cache entries.
/// It provides methods for adding, removing, and checking the existence of entries.
abstract class Storage<K, V> {
  // returns the value denoted by [key] or null
  CacheEntry<K, V>? get(K key);

  // sets the key/value pair and eventually removes an old entry to keep the capacity
  Storage set(K key, CacheEntry<K, V> value);

  /// removes the entry for the given [key] and returns the entry or null. Note that
  /// the entry is already evicted.
  CacheEntry<K, V>? remove(K key);

  /// An internal method for removing an entry, which may be used by cache strategies.
  CacheEntry<K, V>? removeInternal(K key);

  /// Returns the [CacheEntry] for the given [key], or `null` if the key is not found.
  /// This is called if the capacity is reached.
  CacheEntry<K, V>? onCapacity(K key);

  /// Removes all entries from the storage.
  void clear();

  /// Returns the number of entries in the storage.
  int get length;

  /// Returns `true` if the storage contains the given [key].
  bool containsKey(K key);

  /// Returns an iterable of all keys in the storage.
  Iterable<K> get keys;

  /// Returns a map of all key-value pairs in the storage.
  ///
  /// Note: The underlying collection may change, so use with caution.
  Map<K, CacheEntry<K, V>> get entries;
}
