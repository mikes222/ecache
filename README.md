# Ecache

Ecache is a simple library to implement in-memory caching with support to remove entries.

It is inspired by [gcache](https://github.com/bluele/gcache)

## Feature

* Supports expiration based on Least frequently used item (LFU)
* Supports expiration based on Least recently used items (LRU)
* Supports expiration based on removing the "first" entry in the list
* Supports for weakreference storages (minimum capacity is guaranteed, additional items may be removed by garbage collection when not needed)
* Supports expiration based on duration (expiration)
* Callback for items to perform cleanup (Optional)
* getOrProduce() method to return item from cache or produce the requested item.

## Installation

Add to pubspec.yaml:
```yaml
dependencies:
  ecache: ^2.0.4
```

### Simple use case

```dart
import 'package:ecache/ecache.dart';

void main() {
  Cache c = SimpleCache(capacity: 20);

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
  Cache c = SimpleCache(capacity: 20, storage: SimpleStorage(onEvict: (key, value) {
    value.dispose();
  }));

  c.set("key", 42);
  print(c.get("key")); // 42
  print(c.containsKey("unknown_key")); // false
  print(c.get("unknown_key")); // nil
  print(c["key"]); // 42
  
  c["halfKey"] = 21;
}
```

### Get statistics

```dart
import 'package:ecache/ecache.dart';

void main() {
  storage = StatisticsStorage();
  Cache c = SimpleCache(storage: storage, capacity: 20);

    c.set("key", 42);
    print(c.get("key")); // 42
    print(c.containsKey("unknown_key")); // false
    print(c.get("unknown_key")); // nil
    print(storage.toString());
}
```

### Weak references


```dart
import 'package:ecache/ecache.dart';

void main() {
  storage = WeakReferenceStorage();
  Cache c = SimpleCache(storage: storage, capacity: 20);
}
```

In this example 20 items are guaranteed to remain in the cache. When adding more items the older
ones will be moved to a weak reference cache. This cache can be removed by the garbage collection
at any time. 

So when retrieving such an item from cache it may or may not be returned from weakreference cache 
depending if the garbage collection had been run and evicted the items.

Note that we cannot guarantee to always call the evict-callback so do not use both eviction and 
weak reference at the same cache.

### get or produce item

```dart
import 'package:ecache/ecache.dart';

void main() async {
  Cache c = SimpleCache(storage: storage, capacity: 20);

  int a1 = await c.getOrProduce(4, (int key) {
    return Future.delayed(const Duration(seconds: 1), () {
      return 40;
    });
  });

}
```

If the item with the requested key (4) is already in cache it will be returned immediately. 
Otherwise the produce() method is called with the requested key and a future is returned. 

If another call is made with the same key where the future is not yet done the future of the 
produce() method is returned again without calling the produce() method again.

Note that you do not need to explicitly add the new item to the cache when producing a new item. 
This will be done automatically.

## Author

Original Author: 
*Kevin PLATEL*

Author of ecache: Michael Schwartz. 

## License

MIT License, see LICENSE file
