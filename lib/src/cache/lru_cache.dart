import '../strategy/lru_strategy.dart';

import '../storage.dart';
import 'default_cache.dart';

/// A [Cache] that evicts the least recently used items first.
///
/// This cache is ideal for scenarios where you want to keep the most
/// recently accessed items in memory. When the cache reaches its capacity,
/// it removes the item that has not been accessed for the longest time.
class LruCache<K, V> extends DefaultCache<K, V> {
    /// Creates a new [LruCache].
  ///
  /// A [capacity] for the cache must be provided.
  ///
  /// An optional [storage] mechanism can be provided. If not, a [SimpleStorage]
  /// instance is used.
  LruCache({Storage<K, V>? storage, required int capacity})
      : super(
            storage: storage,
            capacity: capacity,
            strategy: LruStrategy<K, V>());
}
