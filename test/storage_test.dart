import 'package:ecache/ecache.dart';
import 'package:test/test.dart';

void main() {
  group('StatisticsStorage', () {
    test('tracks hits, misses, and evictions', () {
      final statisticsStorage = StatisticsStorage<String, int>();
      final cache = SimpleCache<String, int>(
        capacity: 2,
        storage: statisticsStorage,
      );

      // Initial state
      expect(statisticsStorage.storageMetric.hitCount, 0);
      expect(statisticsStorage.storageMetric.missCount, 0);
      expect(statisticsStorage.storageMetric.evictionCount, 0);

      // Miss
      cache.get('a');
      expect(statisticsStorage.storageMetric.missCount, 1);

      // Set
      cache.set('a', 1);
      cache.set('b', 2);

      // Hit
      cache.get('a');
      expect(statisticsStorage.storageMetric.hitCount, 1);

      // Eviction
      cache.set('c', 3);
      expect(statisticsStorage.storageMetric.evictionCount, 1);

      // Final state
      expect(statisticsStorage.storageMetric.hitCount, 1);
      expect(statisticsStorage.storageMetric.missCount, 1);
      expect(statisticsStorage.storageMetric.evictionCount, 1);
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
      expect(statsString, contains('_hitCount: 1'));
      expect(statsString, contains('_missCount: 1'));
      expect(statsString, contains('_evictionCount: 1'));
    });
  });
}
