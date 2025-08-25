import 'package:ecache/ecache.dart';
import 'package:test/test.dart';

void main() {
  test('Test cache initialization', () {
    Cache cache = SimpleCache<int, int>(storage: StatisticsStorage(), capacity: 20);
    expect(cache, isNotNull);
    print(cache.storage.toString());
  });
  //
  test('Test simple insert/get', () {
    Cache c = SimpleCache<String, int>(storage: StatisticsStorage(), capacity: 20);

    c.set('key', 42);
    expect(c.get('key'), equals(42));
    print(c.storage.toString());
  });
  test('Test simple Cache', () {
    Cache<int, int> c = SimpleCache<int, int>(storage: StatisticsStorage(), capacity: 20);
    c[4] = 40;
    c[5] = 50;
    expect(c.get(4), equals(40));
    expect(c.get(5), equals(50));
    print(c.storage.toString());
  });
  test('Test simple eviction', () {
    Cache<int, int> c = SimpleCache<int, int>(storage: StatisticsStorage(), capacity: 3);
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
    print(c.storage.toString());
  });

  test('Test LRU eviction', () {
    Cache<int, int> c = LruCache<int, int>(storage: StatisticsStorage(), capacity: 3);
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
    print(c.storage.toString());
  });

  test('Test LFU eviction', () {
    int evicted = 0;
    Cache<int, int> c = LfuCache<int, int>(
        storage: StatisticsStorage(onEvict: (k, v) {
          ++evicted;
        }),
        capacity: 3);
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
    expect(evicted, equals(1));
    print(c.storage.toString());
  });

  test('Test expiration eviction', () async {
    int evicted = 0;
    Cache<int, int> c = ExpirationCache<int, int>(
        storage: StatisticsStorage(onEvict: (k, v) {
          ++evicted;
        }),
        expiration: const Duration(seconds: 1),
        capacity: 3);
    c[4] = 40;
    c[5] = 50;
    c[6] = 60;

    expect(c.get(4), equals(40));
    expect(c.get(5), equals(50));
    expect(c.get(6), equals(60));
    await Future.delayed(const Duration(milliseconds: 1100));
    c[7] = 70;
    expect(c.get(7), equals(70));
    expect(c.containsKey(4), equals(false));
    expect(c.containsKey(5), equals(false));
    expect(c.containsKey(6), equals(false));
    expect(c.containsKey(7), equals(true));
    expect(evicted, equals(3));
    print(c.storage.toString());
  });

  test("test async producer", () async {
    Cache<int, int> c = LfuCache<int, int>(storage: StatisticsStorage(), capacity: 3);

    int a1 = await c.getOrProduce(4, (int key) {
      return Future.delayed(const Duration(seconds: 1), () {
        return 40;
      });
    });
    int a2 = await c.getOrProduce(5, (int key) {
      return Future.delayed(const Duration(seconds: 1), () {
        return 50;
      });
    });
    // value is already available, produce should not be called
    int a3 = await c.getOrProduce(4, (int key) {
      return Future.delayed(const Duration(seconds: 1), () {
        return 60;
      });
    });
    expect(a1, equals(40));
    expect(a2, equals(50));
    expect(a3, equals(40));
    expect(await c.getAsync(4), equals(40));
    expect(await c.getAsync(5), equals(50));
    print(c.storage.toString());
  });

  test("test async producer with async calls", () async {
    Cache<int, int> c = LfuCache<int, int>(storage: StatisticsStorage(), capacity: 3);

    int calls = 0;
    List<Future> futures = [];
    futures.add(c.getOrProduce(4, (int key) {
      ++calls;
      return Future.delayed(const Duration(seconds: 1), () {
        return 40;
      });
    }));
    futures.add(c.getOrProduce(5, (int key) {
      ++calls;
      return Future.delayed(const Duration(seconds: 1), () {
        return 50;
      });
    }));
    futures.add(c.getOrProduce(4, (int key) {
      ++calls;
      return Future.delayed(const Duration(seconds: 1), () {
        return 60;
      });
    }));
    await Future.wait(futures);
    expect(calls, equals(2));
    expect(await c.getAsync(4), equals(40));
    expect(await c.getAsync(5), equals(50));
    expect(c.length, equals(2));
    print(c.storage.toString());
  });
}
