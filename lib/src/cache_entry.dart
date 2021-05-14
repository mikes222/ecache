part of ecache;

class CacheEntry<K, V> {
  final K key;
  final V? value;

  CacheEntry(this.key, this.value);
}
