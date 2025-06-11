# Ecache

**Ecache** is a lightweight and flexible in-memory cache library for Dart, supporting multiple eviction strategies and smart item handling.

Inspired by [gcache](https://github.com/bluele/gcache), it provides an intuitive API for caching frequently accessed data with fine-grained control over eviction and memory management.

---

## Features

- 🧠 **Eviction Strategies**:
    - LFU (Least Frequently Used)
    - LRU (Least Recently Used)
    - FIFO (First-In-First-Out)
- 🕐 **Time-based expiration**
- 🧹 **Eviction callbacks** (for cleanups, e.g. `dispose()`)
- 🧪 **Weak reference storage** — keep minimum guaranteed entries while allowing GC-based cleanup
- ⚙️ `getOrProduce()` to auto-generate and cache items on demand
- 📊 Optional statistics tracking

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  ecache: ^2.0.7
```


## Basic Usage

```flutter
import 'package:ecache/ecache.dart';

void main() {
  final cache = SimpleCache(capacity: 20);

  cache.set('key', 42);
  print(cache.get('key')); // 42
  print(cache.containsKey('unknown_key')); // false
  print(cache.get('unknown_key')); // null
}
```

## Eviction with Cleanup

```flutter
import 'package:ecache/ecache.dart';

void main() {
  final cache = SimpleCache(
    capacity: 20,
    storage: SimpleStorage(onEvict: (key, value) {
      value.dispose(); // Clean up evicted items
    }),
  );

  cache['key'] = 42;
  cache['halfKey'] = 21;
}
```

## Get Statistics

```flutter
import 'package:ecache/ecache.dart';

void main() {
  final storage = StatisticsStorage();
  final cache = SimpleCache(storage: storage, capacity: 20);

  cache.set('key', 42);
  cache.get('key');
  cache.get('unknown_key');

  print(storage); // View hit/miss stats
}
```


## Weak References

```flutter
import 'package:ecache/ecache.dart';

void main() {
  final storage = WeakReferenceStorage();
  final cache = SimpleCache(storage: storage, capacity: 20);
}
```

⚠️ Weak references allow garbage collection of older items beyond the guaranteed capacity.
Do not use eviction callbacks and weak storage together — callbacks may not fire when GC clears items.

## Get or Produce Value

```flutter
import 'package:ecache/ecache.dart';

void main() async {
  final cache = SimpleCache(capacity: 20);

  final result = await cache.getOrProduce(4, (key) {
    return Future.delayed(Duration(seconds: 1), () => 40);
  });

  print(result); // 40
}
```

If the key exists, the value is returned immediately.

If not, the producer function is invoked and its result is cached.

While a value is being produced, multiple requests for the same key will receive the same Future.

## Authors

Original concept: Kevin Platel

Dart implementation: Michael Schwartz

## License

MIT – see LICENSE

## ❤️ Contribute

Contributions, bug reports and feature suggestions are welcome on GitHub.
Let’s build smarter caching together!
