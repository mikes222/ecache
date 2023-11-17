import 'cache_entry.dart';

///
/// This method will be called if a value is removed from the storage. It can be used to dispose items
///
typedef void OnEvict<K, V>(K k, V v);

/// The abstract interface for a storage class
abstract class Storage<K, V> {
  CacheEntry<K, V>? get(K key);

  Storage set(K key, CacheEntry<K, V> value);

  /// removes the entry at position key. Returns the entry or null. Note that
  /// the entry may be already evicted.
  CacheEntry<K, V>? remove(K key);

  /// removes the entry denoted by [key]. This is called if the capacity is reached.
  CacheEntry<K, V>? onCapacity(K key);

  /// Clears the cache
  void clear();

  int get length;

  CacheEntry<K, V>? operator [](K key);

  void operator []=(K key, CacheEntry<K, V> value);

  bool containsKey(K key);

  List<K> get keys;

  List<CacheEntry<K, V>> get entries;
}
