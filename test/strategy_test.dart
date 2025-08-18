import 'package:ecache/ecache.dart';
import 'package:test/test.dart';

void main() {
  group('Cache Strategies', () {
    group('LruStrategy', () {
      test('evicts the least recently used item', () {
        final cache = LruCache<String, int>(capacity: 3);

        cache.set('a', 1);
        cache.set('b', 2);
        cache.set('c', 3);

        // Access 'a' to make it the most recently used
        cache.get('a');

        // Add a new item to trigger eviction
        cache.set('d', 4);

        // 'b' should be evicted
        expect(cache.containsKey('b'), isFalse);
        expect(cache.containsKey('a'), isTrue);
        expect(cache.containsKey('c'), isTrue);
        expect(cache.containsKey('d'), isTrue);
      });
    });

    group('LfuStrategy', () {
      test('evicts the least frequently used item', () {
        final cache = LfuCache<String, int>(capacity: 3);

        cache.set('a', 1);
        cache.set('b', 2);
        cache.set('c', 3);

        // Access 'a' and 'c' to increase their frequency
        cache.get('a');
        cache.get('a');
        cache.get('c');

        // Add a new item to trigger eviction
        cache.set('d', 4);

        // 'b' should be evicted as it's the least frequently used
        expect(cache.containsKey('b'), isFalse);
        expect(cache.containsKey('a'), isTrue);
        expect(cache.containsKey('c'), isTrue);
        expect(cache.containsKey('d'), isTrue);
      });
    });

    group('ExpirationStrategy', () {
      test('evicts expired items on access', () async {
        final cache = ExpirationCache<String, int>(
          capacity: 3,
          expiration: const Duration(milliseconds: 100),
        );

        cache.set('a', 1);
        await Future.delayed(const Duration(milliseconds: 150));

        // Accessing 'a' after it has expired should return null
        expect(cache.get('a'), isNull);
        expect(cache.containsKey('a'), isFalse);
      });

      test('does not reset expiration on access', () async {
        final cache = ExpirationCache<String, int>(
          capacity: 3,
          expiration: const Duration(milliseconds: 200),
        );

        cache.set('a', 1);
        await Future.delayed(const Duration(milliseconds: 100));

        // Access 'a', but it should still expire at the original time
        cache.get('a');
        await Future.delayed(const Duration(milliseconds: 150));

        expect(cache.get('a'), isNull);
      });
    });
  });
}
