import 'package:ecache/src/strategy/expiration_strategy.dart';

import '../storage.dart';
import 'default_cache.dart';

/// A cache which evicts entries after a certain amount of time
class ExpirationCache<K, V> extends DefaultCache<K, V> {
  ExpirationCache({Storage<K, V>? storage, required Duration expiration, required int capacity})
      : super(storage: storage, capacity: capacity, strategy: ExpirationStrategy(expiration: expiration));
}
