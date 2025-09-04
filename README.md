# Ecache

A simple, flexible, and powerful caching library for Dart and Flutter, designed to be easy to use while providing a robust set of features for managing cached data.

## Features

- **Multiple Caching Strategies**: Choose from several built-in eviction policies:
  - **LRU (Least Recently Used)**: Evicts the least recently accessed items first.
  - **LFU (Least Frequently Used)**: Evicts the least frequently accessed items first.
  - **FIFO (First-In, First-Out)**: A simple strategy that evicts the oldest items first.
  - **Expiration-based**: Evicts items that have passed their expiration time.
- **Pluggable Architecture**: The library is designed with a decoupled architecture, allowing you to mix and match components or create your own.
- **Asynchronous Value Production**: Automatically fetch and cache values that are expensive to compute or retrieve, ensuring the production logic runs only once for a given key.
- **Detailed Statistics**: Monitor cache performance with built-in statistics tracking for hits, misses, and evictions.
- **Extensible Storage**: While a simple `Map`-based storage is provided, you can create your own storage solutions (e.g., for disk-based or database-backed caching).
- **Null-Safe and Well-Documented**: The entire API is null-safe and comes with comprehensive documentation.

## Getting Started

To use this library in your project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  ecache: ^latest
```

Then, run `pub get` or `flutter pub get`.

## Usage

### Creating a Simple Cache (FIFO)

This is the most basic cache, which removes the oldest entry when the capacity is reached.

```dart
import 'package:ecache/ecache.dart';

void main() {
  // Create a cache with a capacity of 10
  final cache = SimpleCache<String, int>(capacity: 10);

  // Set and get values
  cache.set('a', 1);
  final value = cache.get('a'); // returns 1
  print('Value for key "a": $value');
}
```

### Using a Least Recently Used (LRU) Cache

This cache is ideal when you want to keep the most recently accessed items.

```dart
import 'package:ecache/ecache.dart';

void main() {
  final cache = LruCache<String, String>(capacity: 2);

  cache.set('user:1', 'Alice');
  cache.set('user:2', 'Bob');

  // Accessing 'user:1' makes it the most recently used
  cache.get('user:1');

  // Adding a new item will evict the least recently used ('user:2')
  cache.set('user:3', 'Charlie');

  print(cache.containsKey('user:2')); // false
}
```

### Caching with an Expiration Time

Set a default duration for all entries in the cache.

```dart
import 'package:ecache/ecache.dart';

void main() async {
  final cache = ExpirationCache<String, String>(
    capacity: 10,
    duration: const Duration(seconds: 5),
  );

  cache.set('session', 'active');
  print(cache.get('session')); // 'active'

  // Wait for the entry to expire
  await Future.delayed(const Duration(seconds: 6));

  print(cache.get('session')); // null
}
```

### Eviction with Cleanup

```dart
import 'package:ecache/ecache.dart';

void main() {
  final cache = SimpleCache(
    capacity: 20,
    onEvict: (key, value) {
      value.dispose(); // Clean up evicted items
    },
  );

  cache['key'] = 42;
  cache['halfKey'] = 21;
}
```

### Get Statistics

```dart
import 'package:ecache/ecache.dart';

void main() {
  StorageMgr().setEnable(true);
  final cache = SimpleCache(capacity: 20);

  cache.set('key', 42);
  cache.get('key');
  cache.get('unknown_key');
  print(cache.storage); // View hit/miss stats
  
  print(StorageMgr().createReport()); // View all stats
}
```

The cache can be given an optional name to make the report more readable.

### Weak References

```dart
import 'package:ecache/ecache.dart';

void main() {
  final storage = WeakReferenceStorage();
  final cache = SimpleCache(storage: storage, capacity: 20);
}
```

⚠️ Weak references allow garbage collection of older items beyond the guaranteed capacity.

 - Do not use eviction callbacks and weak storage together — callbacks may not fire when GC clears items.
 - WeakReferenceStorage are not able to produce statistics

### Asynchronous Value Production

Use `getOrProduce` to fetch and cache data from a database or a network API while making sure that multiple calls will fetch the data only once and all calls receive the same instance of the produced data.

```dart
import 'package:ecache/ecache.dart';

// A function that simulates fetching data from a network
Future<String> fetchUserData(String userId) async {
  print('Fetching data for $userId...');
  await Future.delayed(const Duration(seconds: 2)); // Simulate network latency
  return 'User data for $userId';
}

void main() async {
  final cache = SimpleCache<String, String>(capacity: 5);

  // The first call will trigger the fetchUserData function
  final data1 = await cache.getOrProduce('user:123', fetchUserData);
  print(data1);

  // The second call will return the cached data instantly
  final data2 = await cache.getOrProduce('user:123', fetchUserData);
  print(data2);
}
```

## Architecture

The library is built on three core components:

- **`Cache`**: The main interface that developers interact with. Concrete implementations like `SimpleCache`, `LruCache`, and `LfuCache` provide the caching logic.
- **`Storage`**: An abstraction for the underlying key-value store. The default is `SimpleStorage`, which uses a `LinkedHashMap`, but custom implementations can be created.
- **`Strategy`**: The logic that governs how and when entries are evicted from the cache. Each cache type uses a corresponding strategy (e.g., `LruStrategy`).

This decoupled design allows for great flexibility in composing caches that fit specific needs.

## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request.

## License

This library is licensed under the MIT License. See the `LICENSE` file for details.


