import 'package:ecache/src/cache/default_cache.dart';
import 'package:ecache/src/strategy/lfu_strategy.dart';

import '../storage.dart';

/// Least frequently used cache. Items which are not used often gets evicted first
class LfuCache<K, V> extends DefaultCache<K, V> {
  LfuCache({required Storage<K, V>? storage, required int capacity}) : super(storage: storage, capacity: capacity, strategy: LfuStrategy());
}
