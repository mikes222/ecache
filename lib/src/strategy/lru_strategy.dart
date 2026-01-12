import 'dart:collection';

import 'package:ecache/ecache.dart';

/// Least recently used cache. Items which are not read for the longest period
/// gets evicted first
class LruStrategy<K, V> extends AbstractStrategy<K, V> {
  final Map<K, _LruNode<K>> _nodes = HashMap<K, _LruNode<K>>();

  _LruNode<K>? _head;
  _LruNode<K>? _tail;

  void _removeNode(_LruNode<K> node) {
    final prev = node.prev;
    final next = node.next;

    if (prev != null) {
      prev.next = next;
    } else {
      _head = next;
    }

    if (next != null) {
      next.prev = prev;
    } else {
      _tail = prev;
    }

    node.prev = null;
    node.next = null;
  }

  void _addToHead(_LruNode<K> node) {
    node.prev = null;
    node.next = _head;
    if (_head != null) {
      _head!.prev = node;
    }
    _head = node;
    _tail ??= node;
  }

  void _touchKey(K key) {
    final existing = _nodes[key];
    if (existing != null) {
      if (!identical(existing, _head)) {
        _removeNode(existing);
        _addToHead(existing);
      }
      return;
    }

    final node = _LruNode<K>(key);
    _nodes[key] = node;
    _addToHead(node);
  }

  void _removeKey(K key) {
    final node = _nodes.remove(key);
    if (node == null) return;
    _removeNode(node);
  }

  @override
  void onCapacity(K key) {
    if (storage.length < capacity) return;
    if (storage.containsKey(key)) return;

    final lru = _tail;
    if (lru == null) return;
    _removeKey(lru.key);
    storage.onCapacity(lru.key);
  }

  @override
  CacheEntry<K, V> createCacheEntry(K key, V value) {
    _touchKey(key);
    return LruCacheEntry(ValueEntry(value), 0);
  }

  @override
  CacheEntry<K, V> createAndStartProducerEntry(
      K key, Produce<K, V> produce, int timeout) {
    _touchKey(key);
    return LruCacheEntry(ProducerEntry(produce)..start(key, timeout), 0);
  }

  @override
  CacheEntry<K, V>? get(K key) {
    CacheEntry<K, V>? entry = storage.get(key);
    if (entry == null) return null;
    _touchKey(key);
    return entry;
  }

  @override
  void onRemove(K key) {
    _removeKey(key);
  }

  @override
  void onClear() {
    _nodes.clear();
    _head = null;
    _tail = null;
  }

  @override
  void onDispose() {
    onClear();
  }
}

/////////////////////////////////////////////////////////////////////////////

class LruCacheEntry<K, V> extends CacheEntry<K, V> {
  int lastUse;

  LruCacheEntry(super.entry, this.lastUse);

  void updateLastUse(int lastUse) {
    this.lastUse = lastUse;
  }
}

class _LruNode<K> {
  final K key;
  _LruNode<K>? prev;
  _LruNode<K>? next;

  _LruNode(this.key);
}
