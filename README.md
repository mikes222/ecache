# Ecache

Ecache is a simple library to implement in-memory caching with support to remove entries.

It is inspired by [gcache](https://github.com/bluele/gcache)

## Feature

* Supports expiration based on Least frequently used item (LFU)
* Supports expiration based on Least recently used items (LRU)
* Supports expiration based on removing the "first" entry in the list
* Supports expiration based on duration (expiration)
* Callback for items to perform cleanup (Optional)

## Installation

Add to pubspec.yaml:
```yaml
dependencies:
  ecache: ^2.0.3
```

### Simple use case

```dart
import 'package:ecache/ecache.dart';

void main() {
  Cache c = new SimpleCache(capacity: 20);

    c.set("key", 42);
    print(c.get("key")); // 42
    print(c.containsKey("unknown_key")); // false
    print(c.get("unknown_key")); // nil
}
```

### Evict items

```dart
import 'package:ecache/ecache.dart';

void main() {
  Cache c = new SimpleCache(capacity: 20, storage: SimpleStorage(onEvict: (key, value) {
    value.dispose();
  }));

  c.set("key", 42);
  print(c.get("key")); // 42
  print(c.containsKey("unknown_key")); // false
  print(c.get("unknown_key")); // nil
}
```

### Get statistics

```dart
import 'package:ecache/ecache.dart';

void main() {
  storage = StatisticsStorage();
  Cache c = new SimpleCache(storage: storage, capacity: 20);

    c.set("key", 42);
    print(c.get("key")); // 42
    print(c.containsKey("unknown_key")); // false
    print(c.get("unknown_key")); // nil
    print(storage.toString());
}
```

## Author

Original Author: 
*Kevin PLATEL*

Author of ecache: Michael Schwartz. 

## License

MIT License, see LICENSE file
