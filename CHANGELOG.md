## 2.1.1

* Enhancing StorageMgr to improve usefullness of statistics

## 2.1.0

* Introducing StorageMgr to easily collect statistics

## 2.0.13

* Bugfix when producer throws an exception

## 2.0.12

* Refactored cacheEntry to support nullable values

## 2.0.11

* Change type of cachEntry after successful async produce() call. This way get() will work after the entry has been produced.
* Stripped down version of defaultCache (syncCache) with all async methods removed. This is a bit faster due to reduced code. 

## 2.0.10

* Implemented getOrProduceSync() for convenience

## 2.0.9

* Dart-support

## 2.0.8

* Introducing Strategies to being able to exchange the underlying default_cache if necessary
* Updated documentation

## 2.0.7

* key removed from cacheEntries to save memory
* getOrProduce() handles exceptions now
* minor performance improvement for expirationCache

## 2.0.6

* Bugfix for weak references

## 2.0.5

* Bugfix for weak references

## 2.0.4

* Introducing getOrProduce()

## 2.0.3

* Introducing WeakreferenceStorage
* Added a bunch of documentation to the sourcecode
* StatisticsStorage simplified

## 2.0.2

* Improved performance
* Updated libraries
* Added StatisticsStorage to get a glimpse about performance

## 2.0.1

* Improved performance for LRUCache

## 2.0.0

* Support for null-safety

## 1.0.1

* Downgrading meta package since many users still uses the previous meta

## 1.0.0

* Initial fork of dcache
