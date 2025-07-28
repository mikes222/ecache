import 'dart:async';

import 'package:ecache/src/cache.dart';

/// Represents a basic entry in the cache, holding a value of type [V].
class CacheEntry<K, V> {
  final V? value;

  const CacheEntry(this.value);
}

//////////////////////////////////////////////////////////////////////////////

/// A mixin for a [CacheEntry] that produces its value asynchronously.
mixin ProducerCacheEntry<K, V> implements CacheEntry<K, V> {
  /// The function that produces the value for this entry.
  late final Produce<K, V> produce;

  /// A [Completer] that completes with the value when it has been produced.
  final Completer<V> completer = Completer();

  /// Starts the asynchronous production of the value.
  Future<void> start(K key, int timeoutMilliseconds) async {
    try {
      Future future = produce(key);
      future = future.timeout(Duration(milliseconds: timeoutMilliseconds));
      V producerValue = await future;
      completer.complete(producerValue);
    } catch (error, stacktrace) {
      completer.completeError(error, stacktrace);
    }
  }
}
