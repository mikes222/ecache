import 'cache_entry.dart';

///
/// This method will be called if a value is removed from the storage. It can be used to dispose items
///
typedef void OnEvict<K, V>(K k, V v);

/// The abstract interface for a storage class
abstract class Storage<K, V> {
  // returns the value denoted by [key] or null
  CacheEntry<K, V>? get(K key);

  // sets the key/value pair and eventually removes an old entry to keep the capacity
  Storage set(K key, CacheEntry<K, V> value);

  /// removes the entry at position key. Returns the entry or null. Note that
  /// the entry is already evicted.
  CacheEntry<K, V>? remove(K key);

  CacheEntry<K, V>? removeInternal(K key);

  /// removes the entry denoted by [key]. This is called if the capacity is reached.
  CacheEntry<K, V>? onCapacity(K key);

  /// Clears the cache, evicts all entries
  void clear();

  /// Returns the approx number of items in the cache. Take this with a grain
  /// of salt
  int get length;

  /// Same as [get]
  CacheEntry<K, V>? operator [](K key);

  /// Same as [set]
  void operator []=(K key, CacheEntry<K, V> value);

  /// returns true if the item is available in the cache. Take this with a grain
  /// of salt since the item may be evicted before it will be retrieved. It is
  /// better to use [get] and check for null returns.
  bool containsKey(K key);

  /// Returns the available keys. This violates the enclosing principle. Take
  /// the return values with caution
  List<K> get keys;

  /// Returns the available values. This violates the enclosing principle. Take
  /// the return values with caution
  List<CacheEntry<K, V>> get entries;
}
