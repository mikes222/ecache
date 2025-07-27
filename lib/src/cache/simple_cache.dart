import 'package:ecache/ecache.dart';
import 'package:ecache/src/strategy/simple_strategy.dart';

import 'default_cache.dart';

/// SimpleCache is a basic cache implementation without any particular logic
/// than appending keys in the storage, and remove first inserted keys when
/// storage is full
class SimpleCache<K, V> extends DefaultCache<K, V> {
  SimpleCache({Storage<K, V>? storage, required int capacity}) : super(storage: storage, capacity: capacity, strategy: SimpleStrategy());
}
