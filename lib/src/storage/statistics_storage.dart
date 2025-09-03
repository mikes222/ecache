import 'package:ecache/src/storage/storage_mgr.dart';

import '../../ecache.dart';

/// Same as [SimpleStorage] but collects a few statistical data.
class StatisticsStorage<K, V> extends SimpleStorage<K, V> {
  final StorageMetric storageMetric = StorageMetric();

  StatisticsStorage({super.onEvict}) {
    StorageMgr().register(this);
  }

  @override
  void dispose() {
    StorageMgr().unregister(this);
    clear();
  }

  @override
  CacheEntry<K, V>? get(K key) {
    final entry = super.get(key);
    if (entry != null) {
      storageMetric.incHitCount();
    } else {
      storageMetric.incMissCount();
    }
    return entry;
  }

  @override
  void setInternal(K key, CacheEntry<K, V> value) {
    super.setInternal(key, value);
    storageMetric.checkLength(length);
    storageMetric.incSetCount();
  }

  @override
  CacheEntry<K, V>? onCapacity(K key) {
    final entry = super.onCapacity(key);
    if (entry != null) {
      storageMetric.incEvictionCount();
    }
    return entry;
  }

  @override
  String toString() {
    return 'StatisticsStorage{storageMetric: $storageMetric}';
  }
}
