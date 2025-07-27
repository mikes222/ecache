import 'dart:async';

import 'package:ecache/src/cache.dart';

/// A cache entry. Note that the key type is defined though not used in the default entry. It could be used for more complex entries
class CacheEntry<K, V> {
  final V? value;

  const CacheEntry(this.value);
}

//////////////////////////////////////////////////////////////////////////////

mixin ProducerCacheEntry<K, V> implements CacheEntry<K, V> {
  late final Produce<K, V> produce;

  final Completer<V> completer = Completer();

  Future<void> start(K key) async {
    try {
      V producerValue = await produce(key);
      completer.complete(producerValue);
    } catch (error, stacktrace) {
      completer.completeError(error, stacktrace);
    }
  }
}
