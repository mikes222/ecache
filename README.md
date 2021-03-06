# Ecache

Ecache is a simple library to implement in-memory caching with support to remove entries to prevent memory overflow.

It is inspired by [gcache](https://github.com/bluele/gcache)

Ecache is a fork of dcache with a few breaking changes and now support for dart-null-safety.

## Feature

* Supports expiration based on Least frequently used item (LFU)
* Supports expiration based on Least recently used items (LRU)
* Supports expiration based on removing the "first" entry in the list
* Supports expiration based on duration (expiration)
* Support eviction
* Automatically load cache entries if not existing. (Optional)
* Callback for evicted items to perform cleanup (Optional)

## Installation

Add to pubspec.yaml:
```yaml
dependencies:
  ecache: ^2.0.1
```

### Simple use case

```dart
import 'package:ecache/ecache.dart';

void main() {
  Cache c = new SimpleCache(storage: SimpleStorage(), capacity: 20);

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
  Cache c = new SimpleCache(storage: new SimpleStorage(), capacity: 20, onEvict: (key, value) {value.dispose();});

    c.set("key", 42);
    print(c.get("key")); // 42
    print(c.containsKey("unknown_key")); // false
    print(c.get("unknown_key")); // nil
}
```


### Loading function

```dart
import 'package:ecache/ecache.dart';

void main() {
  Cache c = new SimpleCache<int, int>(storage: new SimpleStorage(), capacity: 20)
    ..loader = (key, oldValue) => key*10
  ;

    print(c.get(4)); // 40
    print(c.get(5)); // 50
    print(c.containsKey(6)); // false
}
```

## Author

Original Author: 
*Kevin PLATEL*

Author of ecache: Michael Schwartz. 

## License

MIT License, see LICENSE file


