import 'dart:async';

import 'package:ecache/ecache.dart';
import 'package:test/test.dart';

void main() {
  group('General Cache Functionality', () {
    test('clear() removes all items and calls onEvict', () {
      int evictCount = 0;
      final cache = SimpleCache<String, int>(
        capacity: 3,
        storage: SimpleStorage(onEvict: (key, value) {
          evictCount++;
        }),
      );

      cache.set('a', 1);
      cache.set('b', 2);
      cache.clear();

      expect(cache.length, 0);
      expect(evictCount, 2);
    });

    test('remove() deletes an item and calls onEvict', () {
      int evictCount = 0;
      final cache = SimpleCache<String, int>(
        capacity: 3,
        storage: SimpleStorage(onEvict: (key, value) {
          evictCount++;
        }),
      );

      cache.set('a', 1);
      final removedValue = cache.remove('a');

      expect(removedValue, 1);
      expect(cache.containsKey('a'), isFalse);
      expect(evictCount, 1);
    });

    test('cache with capacity of one evicts immediately', () {
      int evictCount = 0;
      final cache = SimpleCache<String, int>(
        capacity: 1,
        storage: SimpleStorage(onEvict: (key, value) {
          evictCount++;
        }),
      );

      cache.set('a', 1);
      cache.set('b', 2);

      expect(cache.containsKey('a'), isFalse);
      expect(cache.containsKey('b'), isTrue);
      expect(cache.length, 1);
      expect(evictCount, 1);
    });

    test('getOrProduce() handles producer errors', () async {
      final cache = SimpleCache<String, int>(capacity: 5);

      Future<int> producer(String key) async {
        throw Exception('Producer error');
      }

      expect(
        () async => await cache.getOrProduce('a', producer),
        throwsA(isA<Exception>()),
      );

      // Ensure the key is not cached after an error
      await Future.delayed(Duration.zero);
      expect(cache.containsKey('a'), isFalse);
    });

    test('getOrProduce() calls producer only once with concurrent requests', () async {
      final cache = SimpleCache<String, int>(capacity: 5);
      int producerCallCount = 0;

      Future<int> producer(String key) async {
        producerCallCount++;
        await Future.delayed(const Duration(milliseconds: 100));
        return 42;
      }

      // Make multiple concurrent requests for the same key
      final futures = [
        cache.getOrProduce('a', producer),
        cache.getOrProduce('a', producer),
        cache.getOrProduce('a', producer),
      ];

      final results = await Future.wait(futures);

      // The producer should only be called once
      expect(producerCallCount, 1);
      // All requests should receive the same result
      expect(results, [42, 42, 42]);
      // The value should be cached
      expect(await cache.getAsync('a'), 42);
    });

    test('getOrProduce() succeeds when producer is faster than timeout', () async {
      final cache = SimpleCache<String, int>(capacity: 1);
      final value = await cache.getOrProduce('a', (key) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return 1;
      }, 100);

      expect(value, 1);
      expect(await cache.getAsync('a'), 1);
    });

    test('getOrProduce() throws TimeoutException when producer is slower than timeout', () async {
      final cache = SimpleCache<String, int>(capacity: 1);

      try {
        await cache.getOrProduce('a', (key) async {
          await Future.delayed(const Duration(milliseconds: 200));
          return 1;
        }, 100);
        fail('should have thrown a TimeoutException');
      } catch (e) {
        expect(e, isA<TimeoutException>());
      }

      // Ensure the key is not cached after a timeout
      expect(cache.containsKey('a'), isFalse);
    });
  });
}
