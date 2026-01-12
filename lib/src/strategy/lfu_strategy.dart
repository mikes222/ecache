import 'dart:collection';

import 'package:ecache/ecache.dart';

/// Least frequently used cache. Items which are not used often gets evicted first
class LfuStrategy<K, V> extends AbstractStrategy<K, V> {
  final Map<K, _LfuNode<K>> _nodes = HashMap<K, _LfuNode<K>>();
  final Map<int, _LfuList<K>> _freqLists = HashMap<int, _LfuList<K>>();

  int _minFreq = 0;

  _LfuList<K> _listForFreq(int freq) {
    return _freqLists.putIfAbsent(freq, () => _LfuList<K>());
  }

  void _removeNode(_LfuNode<K> node) {
    final list = _freqLists[node.freq];
    list?.remove(node);

    if (list != null && list.isEmpty) {
      _freqLists.remove(node.freq);
      if (_minFreq == node.freq) {
        _recomputeMinFreq();
      }
    }

    _nodes.remove(node.key);
  }

  void _recomputeMinFreq() {
    int? min;
    for (final entry in _freqLists.entries) {
      if (!entry.value.isEmpty) {
        min = min == null ? entry.key : (entry.key < min ? entry.key : min);
      }
    }
    _minFreq = min ?? 0;
  }

  void _insertNew(K key) {
    final existing = _nodes[key];
    if (existing != null) {
      _removeNode(existing);
    }

    final node = _LfuNode<K>(key, 0);
    _nodes[key] = node;
    _listForFreq(0).addToHead(node);
    _minFreq = 0;
  }

  void _increment(K key) {
    final node = _nodes[key];
    if (node == null) return;

    final oldFreq = node.freq;
    final oldList = _freqLists[oldFreq];
    oldList?.remove(node);

    if (oldList != null && oldList.isEmpty) {
      _freqLists.remove(oldFreq);
      if (_minFreq == oldFreq) {
        _minFreq = oldFreq + 1;
      }
    }

    node.freq = oldFreq + 1;
    _listForFreq(node.freq).addToHead(node);
  }

  void _removeKey(K key) {
    final node = _nodes[key];
    if (node == null) return;
    _removeNode(node);
  }

  @override
  void onCapacity(K key) {
    if (storage.length < capacity) return;
    if (storage.containsKey(key)) return;

    final list = _freqLists[_minFreq];
    final victim = list?.removeTail();
    if (victim == null) return;
    _nodes.remove(victim.key);
    if (list != null && list.isEmpty) {
      _freqLists.remove(_minFreq);
      _recomputeMinFreq();
    }
    storage.onCapacity(victim.key);
  }

  @override
  CacheEntry<K, V> createCacheEntry(K key, V value) {
    _insertNew(key);
    return LfuCacheEntry(ValueEntry(value));
  }

  @override
  CacheEntry<K, V> createAndStartProducerEntry(
      K key, Produce<K, V> produce, int timeout) {
    _insertNew(key);
    return LfuCacheEntry(ProducerEntry(produce)..start(key, timeout));
  }

  @override
  CacheEntry<K, V>? get(K key) {
    CacheEntry<K, V>? entry = storage.get(key);
    if (entry == null) return null;
    _increment(key);
    if (entry is LfuCacheEntry<K, V>) {
      entry.use++;
    }
    return entry;
  }

  @override
  void onRemove(K key) {
    _removeKey(key);
  }

  @override
  void onClear() {
    _nodes.clear();
    _freqLists.clear();
    _minFreq = 0;
  }

  @override
  void onDispose() {
    onClear();
  }
}

/////////////////////////////////////////////////////////////////////////////

class LfuCacheEntry<K, V> extends CacheEntry<K, V> {
  int use = 0;

  LfuCacheEntry(super.entry);
}

class _LfuNode<K> {
  final K key;
  int freq;
  _LfuNode<K>? prev;
  _LfuNode<K>? next;

  _LfuNode(this.key, this.freq);
}

class _LfuList<K> {
  _LfuNode<K>? head;
  _LfuNode<K>? tail;

  bool get isEmpty => head == null;

  void addToHead(_LfuNode<K> node) {
    node.prev = null;
    node.next = head;
    if (head != null) {
      head!.prev = node;
    }
    head = node;
    tail ??= node;
  }

  void remove(_LfuNode<K> node) {
    final prev = node.prev;
    final next = node.next;

    if (prev != null) {
      prev.next = next;
    } else {
      head = next;
    }

    if (next != null) {
      next.prev = prev;
    } else {
      tail = prev;
    }

    node.prev = null;
    node.next = null;
  }

  _LfuNode<K>? removeTail() {
    final node = tail;
    if (node == null) return null;
    remove(node);
    return node;
  }
}
