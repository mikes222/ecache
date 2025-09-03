import 'package:ecache/ecache.dart';
import 'package:ecache/src/storage/storage_mgr.dart';
import 'package:test/test.dart';

void main() {
  group('StorageMgr', () {
    late StorageMgr storageMgr;

    setUp(() {
      // Reset singleton instance for each test
      StorageMgr.resetInstance();
      storageMgr = StorageMgr();
    });

    tearDown(() {
      // Clean up after each test
      storageMgr.setEnable(false);
      StorageMgr.resetInstance();
    });

    test('should not work when disabled', () {
      // Arrange
      storageMgr.setEnable(false);
      
      // Act
      final cache = DefaultCache<String, int>(capacity: 10);
      
      // Assert
      expect(storageMgr.isEnabled(), false);
      expect(cache.storage, isA<SimpleStorage<String, int>>());
      expect(cache.storage, isNot(isA<StatisticsStorage<String, int>>()));
    });

    test('should instantiate StatisticsStorage by default when enabled', () {
      // Arrange
      storageMgr.setEnable(true);
      
      // Act
      final cache = DefaultCache<String, int>(capacity: 10);
      
      // Assert
      expect(storageMgr.isEnabled(), true);
      expect(cache.storage, isA<StatisticsStorage<String, int>>());
    });

    test('createReport() should return report with valid properties when enabled', () {
      // Arrange
      storageMgr.setEnable(true);
      final cache = DefaultCache<String, int>(capacity: 10);
      
      // Perform some cache operations to generate metrics
      cache.set('key1', 1);
      cache.set('key2', 2);
      cache.get('key1'); // hit
      cache.get('key3'); // miss
      
      // Act
      final report = storageMgr.createReport();
      
      // Assert
      expect(report, isA<StorageReport>());
      expect(report.storageMetrics, isNotEmpty);
      
      // Check that StatisticsStorage metrics are present
      final statisticsStorageKey = 'StatisticsStorage<String, int>';
      expect(report.storageMetrics.containsKey(statisticsStorageKey), true);
      
      final metric = report.storageMetrics[statisticsStorageKey]!;
      expect(metric.hitCount, 1);
      expect(metric.missCount, 1);
      expect(metric.setCount, 2);
      expect(metric.maxLength, 2);
    });

    test('createReport() should return empty report when disabled', () {
      // Arrange
      storageMgr.setEnable(false);
      final cache = DefaultCache<String, int>(capacity: 10);
      
      // Perform some cache operations
      cache.set('key1', 1);
      cache.get('key1');
      
      // Act
      final report = storageMgr.createReport();
      
      // Assert
      expect(report, isA<StorageReport>());
      expect(report.storageMetrics, isEmpty);
    });

    test('should register and unregister StatisticsStorage instances', () {
      // Arrange
      storageMgr.setEnable(true);
      final storage1 = StatisticsStorage<String, int>();
      final storage2 = StatisticsStorage<String, String>();
      
      // Act - StatisticsStorage auto-registers in constructor
      final report1 = storageMgr.createReport();
      
      // Dispose one storage (which unregisters it)
      storage1.dispose();
      final report2 = storageMgr.createReport();
      
      // Assert
      expect(report1.storageMetrics.length, 2);
      expect(report2.storageMetrics.length, 1);
      expect(report2.storageMetrics.containsKey('StatisticsStorage<String, String>'), true);
      
      // Clean up
      storage2.dispose();
    });

    test('singleton pattern should work correctly', () {
      // Act
      final instance1 = StorageMgr();
      final instance2 = StorageMgr();
      
      // Assert
      expect(identical(instance1, instance2), true);
    });

    test('createReport() should handle multiple storage types', () {
      // Arrange
      storageMgr.setEnable(true);
      final intStorage = StatisticsStorage<String, int>();
      final stringStorage = StatisticsStorage<int, String>();
      
      // Perform operations on both storages
      final intCache = SimpleCache<String, int>(capacity: 5, storage: intStorage);
      final stringCache = SimpleCache<int, String>(capacity: 5, storage: stringStorage);
      
      intCache.set('test', 42);
      stringCache.set(1, 'hello');
      
      // Act
      final report = storageMgr.createReport();
      
      // Assert
      expect(report.storageMetrics.length, 2);
      expect(report.storageMetrics.containsKey('StatisticsStorage<String, int>'), true);
      expect(report.storageMetrics.containsKey('StatisticsStorage<int, String>'), true);
      
      final intMetric = report.storageMetrics['StatisticsStorage<String, int>']!;
      final stringMetric = report.storageMetrics['StatisticsStorage<int, String>']!;
      
      expect(intMetric.setCount, 1);
      expect(stringMetric.setCount, 1);
      
      // Clean up
      intStorage.dispose();
      stringStorage.dispose();
    });
  });
}
