import 'default_cache.dart';
import '../strategy/lfu_strategy.dart';

import '../storage.dart';

/// A [Cache] that evicts the least frequently used items first.
///
/// This cache is useful when the access patterns are such that some items are
/// accessed much more frequently than others. It keeps the most popular items
/// in memory by tracking access frequency.
class LfuCache<K, V> extends DefaultCache<K, V> {
    /// Creates a new [LfuCache].
  ///
  /// A [capacity] for the cache must be provided.
  ///
  /// An optional [storage] mechanism can be provided. If not, a [SimpleStorage]
  /// instance is used.
  LfuCache({Storage<K, V>? storage, required int capacity})
      : super(
            storage: storage,
            capacity: capacity,
            strategy: LfuStrategy<K, V>());
}
