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

/// 캐싱 전략을 관리하는 서비스 (웹이 아닌 플랫폼용 스텁)
class CacheStrategyService {
  /// 캐시 전략 초기화
  Future<void> initialize() async {
    debugPrint('🗂️ 캐시 전략 서비스 초기화 (스텁)');
  }

  /// 리소스 타입에 따른 캐시 전략 결정
  CacheStrategy getStrategyForResource(String url, ResourceType type) {
    return CacheStrategy.cacheFirst;
  }

  /// 리소스 타입 자동 감지
  ResourceType detectResourceType(String url) {
    return ResourceType.static;
  }

  /// 캐시에 리소스 저장
  Future<void> cacheResource(
    String url,
    dynamic response,
    ResourceType type,
  ) async {
    debugPrint('💾 리소스 캐시 (스텁): $url');
  }

  /// 캐시에서 리소스 가져오기
  Future<dynamic> getCachedResource(String url, ResourceType type) async {
    debugPrint('📦 캐시에서 리소스 로드 (스텁): $url');
    return null;
  }

  /// 캐시 통계 정보 가져오기
  Future<Map<String, dynamic>> getCacheStats() async {
    return {};
  }

  /// 모든 캐시 삭제
  Future<void> clearAllCaches() async {
    debugPrint('🗑️ 모든 캐시 삭제 (스텁)');
  }
}
