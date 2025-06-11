/// A cache entry. Note that the key type is defined though not used in the default entry. It could be used for more complex entries
class CacheEntry<K, V> {
  final V? value;

  const CacheEntry(this.value);
}
