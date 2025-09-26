import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

/// 캐시 전략 타입
enum CacheStrategy {
  cacheFirst,
  networkFirst,
  staleWhileRevalidate,
  networkOnly,
  cacheOnly,
}

/// 리소스 타입
enum ResourceType { static, dynamic, api, image, data }

/// 캐싱 전략을 관리하는 서비스 (웹 전용)
class CacheStrategyService {
  static const String _version = '1.0.0';
  static const String _staticCacheName = 'everydiary-static-v$_version';
  static const String _dynamicCacheName = 'everydiary-dynamic-v$_version';
  static const String _dataCacheName = 'everydiary-data-v$_version';

  // 캐시 크기 제한 (바이트)
  static const int _maxStaticCacheSize = 30 * 1024 * 1024; // 30MB
  static const int _maxDynamicCacheSize = 15 * 1024 * 1024; // 15MB
  static const int _maxDataCacheSize = 5 * 1024 * 1024; // 5MB

  /// 캐시 전략 초기화
  Future<void> initialize() async {
    if (!kIsWeb) return;

    try {
      debugPrint('🗂️ 캐시 전략 서비스 초기화 시작');

      // 캐시 크기 확인 및 정리
      await _cleanupExpiredCaches();
      await _enforceCacheSizeLimits();

      debugPrint('✅ 캐시 전략 서비스 초기화 완료');
    } catch (e) {
      debugPrint('❌ 캐시 전략 서비스 초기화 실패: $e');
    }
  }

  /// 리소스 타입에 따른 캐시 전략 결정
  CacheStrategy getStrategyForResource(String url, ResourceType type) {
    switch (type) {
      case ResourceType.static:
        return CacheStrategy.cacheFirst;
      case ResourceType.dynamic:
        return CacheStrategy.staleWhileRevalidate;
      case ResourceType.api:
        return CacheStrategy.networkFirst;
      case ResourceType.image:
        return CacheStrategy.staleWhileRevalidate;
      case ResourceType.data:
        return CacheStrategy.cacheFirst;
    }
  }

  /// 리소스 타입 자동 감지
  ResourceType detectResourceType(String url) {
    if (url.contains('/assets/') ||
        url.contains('/canvaskit/') ||
        url.contains('/flutter.js') ||
        url.contains('/manifest.json') ||
        url.endsWith('.html') ||
        url.endsWith('.css') ||
        url.endsWith('.js')) {
      return ResourceType.static;
    }

    if (url.contains('/api/') ||
        url.contains('/supabase/') ||
        url.contains('/firebase/')) {
      return ResourceType.api;
    }

    if (RegExp(
      r'\.(jpg|jpeg|png|gif|webp|svg)$',
      caseSensitive: false,
    ).hasMatch(url)) {
      return ResourceType.image;
    }

    if (url.contains('/data/') || url.contains('/user/')) {
      return ResourceType.data;
    }

    return ResourceType.dynamic;
  }

  /// 캐시에 리소스 저장
  Future<void> cacheResource(
    String url,
    dynamic response,
    ResourceType type,
  ) async {
    if (!kIsWeb) return;

    try {
      final cacheName = _getCacheNameForType(type);
      final cache = await html.window.caches?.open(cacheName);

      if (cache != null) {
        // 캐시 메타데이터 추가 (실제로는 캐시에 저장만 함)
        // final metadata = {
        //   'url': url,
        //   'timestamp': DateTime.now().millisecondsSinceEpoch,
        //   'type': type.toString(),
        //   'strategy': getStrategyForResource(url, type).toString(),
        //   'expiry': _getExpiryForType(type),
        // };

        // 응답에 메타데이터 헤더 추가 (실제로는 캐시에 저장만 함)
        // final headers = Map<String, String>.from(response.headers);
        // headers['x-cache-metadata'] = jsonEncode(metadata);

        final modifiedResponse = response;

        await cache.put(url, modifiedResponse);
        debugPrint('💾 리소스 캐시됨: $url (${type.toString()})');
      }
    } catch (e) {
      debugPrint('❌ 리소스 캐시 실패: $url - $e');
    }
  }

  /// 캐시에서 리소스 가져오기
  Future<dynamic> getCachedResource(String url, ResourceType type) async {
    if (!kIsWeb) return null;

    try {
      final cacheName = _getCacheNameForType(type);
      final cache = await html.window.caches?.open(cacheName);

      if (cache != null) {
        final response = await cache.match(url);

        if (response != null) {
          // 캐시 만료 확인
          if (await _isCacheExpired(response)) {
            await cache.delete(url);
            debugPrint('⏰ 만료된 캐시 삭제: $url');
            return null;
          }

          debugPrint('📦 캐시에서 리소스 로드: $url');
          return response;
        }
      }
    } catch (e) {
      debugPrint('❌ 캐시에서 리소스 로드 실패: $url - $e');
    }

    return null;
  }

  /// 캐시 만료된 리소스 정리
  Future<void> _cleanupExpiredCaches() async {
    if (!kIsWeb) return;

    try {
      final cacheNames = [_staticCacheName, _dynamicCacheName, _dataCacheName];

      for (final cacheName in cacheNames) {
        try {
          final cache = await html.window.caches?.open(cacheName);
          if (cache != null) {
            final requests = await cache.keys();

            if (requests != null) {
              try {
                final requestList = List<dynamic>.from(
                  requests as Iterable? ?? [],
                );
                for (final request in requestList) {
                  try {
                    final response = await cache.match(request);
                    if (response != null && await _isCacheExpired(response)) {
                      await cache.delete(request);
                      debugPrint('🗑️ 만료된 캐시 삭제: $request');
                    }
                  } catch (e) {
                    debugPrint('❌ 캐시 정리 실패: $e');
                  }
                }
              } catch (e) {
                debugPrint('❌ 캐시 요청 목록 처리 실패: $e');
              }
            }
          }
        } catch (e) {
          debugPrint('❌ 캐시 $cacheName 정리 실패: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ 만료된 캐시 정리 실패: $e');
    }
  }

  /// 캐시 크기 제한 적용
  Future<void> _enforceCacheSizeLimits() async {
    if (!kIsWeb) return;

    try {
      final cacheNames = [
        (_staticCacheName, _maxStaticCacheSize),
        (_dynamicCacheName, _maxDynamicCacheSize),
        (_dataCacheName, _maxDataCacheSize),
      ];

      for (final (cacheName, maxSize) in cacheNames) {
        final cache = await html.window.caches?.open(cacheName);
        if (cache != null) {
          final currentSize = await _getCacheSize(cache);

          if (currentSize > maxSize) {
            await _trimCacheToSize(cache, maxSize);
            debugPrint(
              '✂️ 캐시 크기 제한 적용: $cacheName (${(currentSize / 1024 / 1024).toStringAsFixed(2)}MB -> ${(maxSize / 1024 / 1024).toStringAsFixed(2)}MB)',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ 캐시 크기 제한 적용 실패: $e');
    }
  }

  /// 캐시 크기 계산
  Future<int> _getCacheSize(dynamic cache) async {
    try {
      int totalSize = 0;
      final requests = await cache.keys();

      if (requests != null) {
        try {
          final requestList = List<dynamic>.from(requests as Iterable<dynamic>);
          for (final request in requestList) {
            try {
              final response = await cache.match(request);
              if (response != null) {
                final body = await response.arrayBuffer();
                totalSize += (body.lengthInBytes as num).toInt();
              }
            } catch (e) {
              debugPrint('❌ 캐시 크기 계산 실패: $e');
            }
          }
        } catch (e) {
          debugPrint('❌ 캐시 요청 목록 처리 실패: $e');
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('❌ 캐시 크기 계산 실패: $e');
      return 0;
    }
  }

  /// 캐시를 지정된 크기로 트림
  Future<void> _trimCacheToSize(dynamic cache, int maxSize) async {
    try {
      final requests = await cache.keys();
      if (requests == null) return;

      final entries = <MapEntry<int, dynamic>>[];

      // 각 요청의 타임스탬프 수집
      try {
        final requestList = List<dynamic>.from(requests as Iterable<dynamic>);
        for (final request in requestList) {
          try {
            final response = await cache.match(request);
            if (response != null) {
              final timestamp = _getCacheTimestamp(response);
              entries.add(MapEntry(timestamp, request));
            }
          } catch (e) {
            debugPrint('❌ 캐시 항목 처리 실패: $e');
          }
        }
      } catch (e) {
        debugPrint('❌ 캐시 요청 목록 처리 실패: $e');
      }

      // 타임스탬프 순으로 정렬 (오래된 것부터)
      entries.sort((a, b) => a.key.compareTo(b.key));

      int currentSize = await _getCacheSize(cache);

      // 크기 제한에 도달할 때까지 오래된 항목 삭제
      for (final entry in entries) {
        if (currentSize <= maxSize) break;

        try {
          final response = await cache.match(entry.value);
          if (response != null) {
            final body = await response.arrayBuffer();
            currentSize -= (body.lengthInBytes as num).toInt();
            await cache.delete(entry.value);
          }
        } catch (e) {
          debugPrint('❌ 캐시 항목 삭제 실패: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ 캐시 트림 실패: $e');
    }
  }

  /// 캐시 타입에 따른 캐시 이름 반환
  String _getCacheNameForType(ResourceType type) {
    switch (type) {
      case ResourceType.static:
        return _staticCacheName;
      case ResourceType.dynamic:
      case ResourceType.api:
      case ResourceType.image:
        return _dynamicCacheName;
      case ResourceType.data:
        return _dataCacheName;
    }
  }

  /// 캐시가 만료되었는지 확인
  Future<bool> _isCacheExpired(dynamic response) async {
    try {
      final metadataHeader = response.headers?['x-cache-metadata'];
      if (metadataHeader != null && metadataHeader is String) {
        final metadata = jsonDecode(metadataHeader) as Map<String, dynamic>;
        final timestamp = metadata['timestamp'] as int;
        final expiry = metadata['expiry'] as int;

        return DateTime.now().millisecondsSinceEpoch - timestamp > expiry;
      }
    } catch (e) {
      debugPrint('❌ 캐시 만료 확인 실패: $e');
    }

    return true; // 메타데이터가 없으면 만료된 것으로 간주
  }

  /// 캐시 타임스탬프 가져오기
  int _getCacheTimestamp(dynamic response) {
    try {
      final metadataHeader = response.headers?['x-cache-metadata'];
      if (metadataHeader != null && metadataHeader is String) {
        final metadata = jsonDecode(metadataHeader) as Map<String, dynamic>;
        return metadata['timestamp'] as int;
      }
    } catch (e) {
      debugPrint('❌ 캐시 타임스탬프 가져오기 실패: $e');
    }

    return 0;
  }

  /// 캐시 통계 정보 가져오기
  Future<Map<String, dynamic>> getCacheStats() async {
    if (!kIsWeb) return {};

    try {
      final stats = <String, dynamic>{};
      final cacheNames = [_staticCacheName, _dynamicCacheName, _dataCacheName];

      for (final cacheName in cacheNames) {
        final cache = await html.window.caches?.open(cacheName);
        if (cache != null) {
          final requests = await cache.keys();
          final size = await _getCacheSize(cache);

          stats[cacheName] = {
            'count': requests.length,
            'size': size,
            'sizeMB': (size / 1024 / 1024).toStringAsFixed(2),
          };
        }
      }

      return stats;
    } catch (e) {
      debugPrint('❌ 캐시 통계 가져오기 실패: $e');
      return {};
    }
  }

  /// 모든 캐시 삭제
  Future<void> clearAllCaches() async {
    if (!kIsWeb) return;

    try {
      final cacheNames = [_staticCacheName, _dynamicCacheName, _dataCacheName];

      for (final cacheName in cacheNames) {
        await html.window.caches?.delete(cacheName);
        debugPrint('🗑️ 캐시 삭제됨: $cacheName');
      }
    } catch (e) {
      debugPrint('❌ 캐시 삭제 실패: $e');
    }
  }
}
