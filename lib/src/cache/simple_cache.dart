import '../strategy/simple_strategy.dart';
import 'default_cache.dart';

/// A basic cache that uses a [SimpleStrategy] for entry management.
///
/// This cache implementation follows a simple First-In, First-Out (FIFO) eviction policy
/// when the cache reaches its capacity. It relies on [DefaultCache] for the core
/// caching logic and injects a [SimpleStrategy] to handle evictions.
class SimpleCache<K, V> extends DefaultCache<K, V> {
  /// Creates a new [SimpleCache] with a specified [capacity].
  ///
  /// An optional [storage] mechanism can be provided. If none is supplied,
  /// a default [SimpleStorage] will be used.
  SimpleCache({super.storage, required super.capacity})
      : super(
          strategy: SimpleStrategy<K, V>(),
        );
}
