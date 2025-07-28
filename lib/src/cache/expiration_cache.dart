import '../strategy/expiration_strategy.dart';
import 'default_cache.dart';

/// A [Cache] that evicts entries after a specified duration.
///
/// This cache is suitable for data that becomes stale after a certain period.
/// Each entry is associated with a timestamp, and the [ExpirationStrategy]
/// will evict entries whose age exceeds the configured duration.
class ExpirationCache<K, V> extends DefaultCache<K, V> {
  ExpirationCache({super.storage, required Duration expiration, required super.capacity}) : super(strategy: ExpirationStrategy<K, V>(expiration: expiration));
}
