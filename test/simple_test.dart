import 'package:test/test.dart';
import 'dart:io';

import 'package:ecache/ecache.dart';

void main() {
  test('Test cache initialization', () {
    Cache cache = SimpleCache<int, int>(storage: SimpleStorage(), capacity: 20);
    expect(cache, isNotNull);
  });
  //
  test('Test simple insert/get', () {
    Cache c = SimpleCache<String, int>(storage: SimpleStorage(), capacity: 20);

    c.set('key', 42);
    expect(c.get('key'), equals(42));
  });
  test('Test simple Cache', () {
    Cache<int, int> c = SimpleCache<int, int>(storage: SimpleStorage(), capacity: 20);
    c[4] = 40;
    c[5] = 50;
    expect(c.get(4), equals(40));
    expect(c.get(5), equals(50));
  });
  test('Test simple eviction', () {
    Cache<int, int> c = SimpleCache<int, int>(storage: SimpleStorage(), capacity: 3);
    c[4] = 40;
    c[5] = 50;
    c[6] = 60;

    expect(c.get(4), equals(40));
    expect(c.get(5), equals(50));
    expect(c.get(6), equals(60));
    c[7] = 70;
    c[8] = 80;
    expect(c.get(7), equals(70));
    expect(c.length, 3);
  });
  test('Test LRU eviction', () {
    Cache<int, int> c = LruCache<int, int>(storage: SimpleStorage(), capacity: 3);
    c[4] = 40;
    sleep(Duration(milliseconds: 5));
    c[5] = 50;
    sleep(Duration(milliseconds: 5));
    c[6] = 60;
    sleep(Duration(milliseconds: 5));

    expect(c.get(4), equals(40));
    sleep(Duration(milliseconds: 5));
    expect(c.get(5), equals(50));
    sleep(Duration(milliseconds: 5));
    expect(c.get(6), equals(60));
    sleep(Duration(milliseconds: 5));
    expect(c.get(4), equals(40));
    sleep(Duration(milliseconds: 5));
    expect(c.get(6), equals(60));
    sleep(Duration(milliseconds: 5));
    c[7] = 70;
    expect(c.get(7), equals(70));
    expect(c.containsKey(5), equals(false));
  });
  test('Test LFU eviction', () {
    Cache<int, int> c = LfuCache<int, int>(storage: SimpleStorage(), capacity: 3);
    c[4] = 40;
    c[5] = 50;
    c[6] = 60;

    expect(c.get(4), equals(40));
    expect(c.get(5), equals(50));
    expect(c.get(6), equals(60));
    expect(c.get(4), equals(40));
    expect(c.get(6), equals(60));
    c[7] = 70;
    expect(c.get(7), equals(70));
    expect(c.containsKey(5), equals(false));
  });
}
