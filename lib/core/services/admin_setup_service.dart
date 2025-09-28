import 'package:flutter/foundation.dart';

import '../../shared/services/database_service.dart';
import '../../shared/services/password_service.dart';

/// 관리자 계정 설정 서비스
class AdminSetupService {
  static const String _adminEmail = 'dev@dev.ac.kr';
  static const String _adminPassword = 'KkKk!#@\$1';
  static const String _adminName = '관리자';

  /// 기본 관리자 계정 생성
  static Future<void> createDefaultAdmin() async {
    try {
      final databaseService = DatabaseService();
      final db = await databaseService.database;

      // 기존 관리자 계정 확인
      final existingAdmin = await db.query(
        'users',
        where: 'email = ? AND is_deleted = 0',
        whereArgs: [_adminEmail],
      );

      if (existingAdmin.isNotEmpty) {
        debugPrint('✅ 기본 관리자 계정이 이미 존재합니다.');
        return;
      }

      // 비밀번호 해시화
      final hashedPassword = PasswordService.hashPassword(_adminPassword);

      // 관리자 계정 생성
      final now = DateTime.now().toIso8601String();
      final adminId = await db.insert('users', {
        'email': _adminEmail,
        'username': _adminName,
        'password_hash': hashedPassword,
        'profile_image_url': null,
        'is_premium': 1,
        'premium_expires_at': null,
        'created_at': now,
        'updated_at': now,
        'is_deleted': 0,
      });

      debugPrint('✅ 기본 관리자 계정이 생성되었습니다.');
      debugPrint('📧 이메일: $_adminEmail');
      debugPrint('🔑 비밀번호: $_adminPassword');
      debugPrint('👤 사용자 ID: $adminId');
    } catch (e) {
      debugPrint('❌ 관리자 계정 생성 실패: $e');
    }
  }

  /// 앱 시작 시 관리자 계정 확인 및 생성
  static Future<void> ensureAdminAccount() async {
    try {
      await createDefaultAdmin();
    } catch (e) {
      debugPrint('❌ 관리자 계정 설정 실패: $e');
    }
  }
}
