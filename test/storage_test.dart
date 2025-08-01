import 'package:ecache/ecache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatisticsStorage', () {
    test('tracks hits, misses, and evictions', () {
      final statisticsStorage = StatisticsStorage<String, int>();
      final cache = SimpleCache<String, int>(
        capacity: 2,
        storage: statisticsStorage,
      );

      // Initial state
      expect(statisticsStorage.hitCount, 0);
      expect(statisticsStorage.missCount, 0);
      expect(statisticsStorage.evictionCount, 0);

      // Miss
      cache.get('a');
      expect(statisticsStorage.missCount, 1);

      // Set
      cache.set('a', 1);
      cache.set('b', 2);

      // Hit
      cache.get('a');
      expect(statisticsStorage.hitCount, 1);

      // Eviction
      cache.set('c', 3);
      expect(statisticsStorage.evictionCount, 1);

      // Final state
      expect(statisticsStorage.hitCount, 1);
      expect(statisticsStorage.missCount, 1);
      expect(statisticsStorage.evictionCount, 1);
    });

    test('toString() reports correct statistics', () {
      final statisticsStorage = StatisticsStorage<String, int>();
      final cache = SimpleCache<String, int>(
        capacity: 1,
        storage: statisticsStorage,
      );

      cache.set('a', 1);
      cache.get('a'); // Hit
      cache.get('b'); // Miss
      cache.set('c', 2); // Eviction

      final statsString = statisticsStorage.toString();
      expect(statsString, contains('hits: 1'));
      expect(statsString, contains('misses: 1'));
      expect(statsString, contains('evictions: 1'));
    });
  });
}
