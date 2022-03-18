import 'cache_entry.dart';

///
/// This method will be called if a value is removed from the storage. It can be used to dispose items
///
typedef void OnEvict<K, V>(K k, V v);

abstract class Storage<K, V> {
  CacheEntry<K, V>? get(K key);

  Storage set(K key, CacheEntry<K, V> value);

  /// removes the entry at position key. Returns the entry or null
  CacheEntry<K, V>? remove(K key);

  void clear();

  int get length;

  CacheEntry<K, V>? operator [](K key);

  void operator []=(K key, CacheEntry<K, V> value);

  bool containsKey(K key);

  List<K> get keys;

  List<CacheEntry<K, V>> get entries;
}
