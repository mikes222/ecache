import 'package:ecache/src/strategy/lru_strategy.dart';

import '../storage.dart';
import 'default_cache.dart';

/// Least recently used cache. Items which are not read for the longest period
/// gets evicted first.
class LruCache<K, V> extends DefaultCache<K, V> {
  LruCache({required Storage<K, V>? storage, required int capacity}) : super(storage: storage, capacity: capacity, strategy: LruStrategy());
}
