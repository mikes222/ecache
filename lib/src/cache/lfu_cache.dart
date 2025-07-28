import '../strategy/lfu_strategy.dart';
import 'default_cache.dart';

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
  LfuCache({super.storage, required super.capacity}) : super(strategy: LfuStrategy<K, V>());
}
