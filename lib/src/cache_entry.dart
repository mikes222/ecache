import 'dart:async';

import 'package:ecache/src/cache.dart';

/// Represents a basic entry in the cache, holding a value of type [V].
class CacheEntry<K, V> {
  Entry<K, V> entry;

  CacheEntry(this.entry);

  V getValue() {
    return (entry as ValueEntry<K, V>).value;
  }
}

//////////////////////////////////////////////////////////////////////////////

// Base class for the cache entries
class Entry<K, V> {}

//////////////////////////////////////////////////////////////////////////////

/// Represents a cache entry holding a value of type [V].
class ValueEntry<K, V> extends Entry<K, V> {
  final V value;

  ValueEntry(this.value);
}

//////////////////////////////////////////////////////////////////////////////

/// Represents a cache entry that is producing a value of type [V].
class ProducerEntry<K, V> extends Entry<K, V> {
  /// The function that produces the value for this entry.
  final Produce<K, V> produce;

  /// A [Completer] that completes with the value when it has been produced.
  final Completer<V> completer = Completer();

  Future? future;

  ProducerEntry(this.produce);

  void abortProcess() {
    future?.ignore();
    completer.completeError(TimeoutException("Producer $produce aborted"));
  }

  /// Starts the asynchronous production of the value.
  Future<void> start(K key, int timeoutMilliseconds) async {
    try {
      future = produce(key).timeout(Duration(milliseconds: timeoutMilliseconds));
      V producerValue = await future;
      completer.complete(producerValue);
    } catch (error, stacktrace) {
      completer.completeError(error, stacktrace);
    }
  }
}
