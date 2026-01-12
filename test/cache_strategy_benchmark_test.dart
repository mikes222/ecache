import 'package:ecache/ecache.dart';
import 'package:test/test.dart';

void main() {
  test('cache strategy micro-benchmark', () {
    const int preloadCount = 10000;
    const int iterations = 10000;

    Map<String, Cache<String, int> Function()> strategiesForCapacity(
        int capacity) {
      return <String, Cache<String, int> Function()>{
        'Simple': () => SimpleCache<String, int>(capacity: capacity),
        'LRU': () => LruCache<String, int>(capacity: capacity),
        'LFU': () => LfuCache<String, int>(capacity: capacity),
        'Expiration': () => ExpirationCache<String, int>(
              capacity: capacity,
              expiration: const Duration(days: 1),
            ),
      };
    }

    final methods = <String>[
      'get',
      'set',
      'containsKey',
      'remove',
      'getOrProduceSync'
    ];

    double benchmark(void Function() op) {
      for (int i = 0; i < 200; i++) {
        op();
      }

      final sw = Stopwatch()..start();
      for (int i = 0; i < iterations; i++) {
        op();
      }
      sw.stop();

      final totalMicros = sw.elapsedMicroseconds;
      return totalMicros / iterations;
    }

    Map<String, Map<String, double>> runScenario(
        {required int capacity, required int initialFill}) {
      final results = <String, Map<String, double>>{
        for (final m in methods) m: <String, double>{},
      };

      final strategies = strategiesForCapacity(capacity);

      for (final entry in strategies.entries) {
        final strategyName = entry.key;
        final cache = entry.value();

        for (int i = 0; i < initialFill; i++) {
          cache.set('k$i', i);
        }

        int sink = 0;

        int getIndex = 0;
        results['get']![strategyName] = benchmark(() {
          final key = 'k${getIndex++ % initialFill}';
          sink ^= cache.get(key) ?? 0;
        });

        int setIndex = 0;
        results['set']![strategyName] = benchmark(() {
          final idx = setIndex++;
          cache.set('s$idx', idx);
        });

        int containsIndex = 0;
        results['containsKey']![strategyName] = benchmark(() {
          final key = 'k${containsIndex++ % initialFill}';
          if (cache.containsKey(key)) sink ^= 1;
        });

        int removeIndex = 0;
        results['remove']![strategyName] = benchmark(() {
          final idx = removeIndex++ % initialFill;
          final key = 'k$idx';
          sink ^= cache.remove(key) ?? 0;
          cache.set(key, idx);
        });

        int produceIndex = 0;
        results['getOrProduceSync']![strategyName] = benchmark(() {
          final idx = produceIndex++ % initialFill;
          final key = 'k$idx';
          sink ^= cache.getOrProduceSync(key, (k) => -1);
        });

        expect(sink, isNotNull);
        cache.dispose();
      }
      return results;
    }

    final atCapacityResults =
        runScenario(capacity: preloadCount, initialFill: preloadCount);
    final plentySpaceResults =
        runScenario(capacity: preloadCount * 10, initialFill: preloadCount);

    final strategyNames = strategiesForCapacity(preloadCount).keys.toList();

    String renderTable(String title, Map<String, Map<String, double>> results) {
      final buffer = StringBuffer();
      buffer.writeln(title);
      buffer.writeln('| Method | ${strategyNames.join(' | ')} |');
      buffer.writeln(
          '| --- | ${List.filled(strategyNames.length, '---').join(' | ')} |');

      for (final methodName in methods) {
        final row = <String>[methodName];
        for (final strategyName in strategyNames) {
          final avgMicros = results[methodName]![strategyName]!;
          row.add(avgMicros.toStringAsFixed(2));
        }
        buffer.writeln('| ${row.join(' | ')} |');
      }
      return buffer.toString();
    }

    print(renderTable(
        '### At/near capacity (eviction pressure)', atCapacityResults));
    print(renderTable('### Plenty of free capacity', plentySpaceResults));
  });
}
