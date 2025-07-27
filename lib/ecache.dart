/// A simple and flexible caching library for Dart.
///
/// This library provides a set of classes and interfaces to create caches
/// with different storage mechanisms and eviction strategies.
library ecache;

export 'src/cache.dart';
export 'src/cache/expiration_cache.dart';
export 'src/cache/lfu_cache.dart';
export 'src/cache/lru_cache.dart';
export 'src/cache/simple_cache.dart';
export 'src/cache_entry.dart';
export 'src/storage.dart';
export 'src/storage/simple_storage.dart';
export 'src/storage/statistics_storage.dart';
export 'src/storage/weakreference_storage.dart';
