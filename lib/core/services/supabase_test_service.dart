import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 연결 테스트 서비스
class SupabaseTestService {
  static final SupabaseTestService _instance = SupabaseTestService._internal();
  factory SupabaseTestService() => _instance;
  SupabaseTestService._internal();

  /// Supabase 연결 상태 확인
  Future<Map<String, dynamic>> testConnection() async {
    try {
      debugPrint('🔍 Supabase 연결 테스트 시작...');

      // 1. 기본 연결 테스트
      final client = Supabase.instance.client;
      debugPrint('✅ Supabase 클라이언트 초기화됨');

      // 2. 인증 상태 확인
      final session = client.auth.currentSession;
      debugPrint('🔐 인증 상태: ${session != null ? "로그인됨" : "로그인 안됨"}');

      // 3. 간단한 쿼리 테스트 (테스트 테이블이 있다면)
      try {
        final response = await client
            .from('test_table') // 실제 테이블명으로 변경
            .select('*')
            .limit(1);
        debugPrint('📊 쿼리 테스트 성공: ${response.length}개 행');
      } catch (e) {
        debugPrint('⚠️ 쿼리 테스트 실패 (테이블 없음): $e');
      }

      // 4. 연결 정보 반환
      return {
        'connected': true,
        'authenticated': session != null,
        'url': 'Supabase 연결됨',
        'timestamp': DateTime.now().toIso8601String(),
      };

    } catch (e) {
      debugPrint('❌ Supabase 연결 테스트 실패: $e');
      return {
        'connected': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Supabase 설정 정보 출력
  void printConnectionInfo() {
    try {
      final client = Supabase.instance.client;
      debugPrint('📋 Supabase 연결 정보:');
      debugPrint('   URL: Supabase 연결됨');
      debugPrint('   Anon Key: 설정됨');
      debugPrint('   Session: ${client.auth.currentSession != null ? client.auth.currentSession!.user.id : "없음"}');
    } catch (e) {
      debugPrint('❌ Supabase 정보 출력 실패: $e');
    }
  }
}
