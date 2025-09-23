import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile_model.dart';
import '../services/profile_service.dart';

/// 프로필 프로바이더
/// 사용자 프로필 상태를 관리하는 Riverpod 프로바이더입니다.
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileModel>(
  (ref) => ProfileNotifier(),
);

/// 프로필 통계 프로바이더
final profileStatsProvider =
    StateNotifierProvider<ProfileStatsNotifier, ProfileStats>(
      (ref) => ProfileStatsNotifier(),
    );

/// 프로필 상태 관리자
class ProfileNotifier extends StateNotifier<ProfileModel> {
  ProfileNotifier() : super(const ProfileModel()) {
    _loadProfile();
  }

  final ProfileService _profileService = ProfileService();

  /// 프로필 로드
  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.loadProfile();
      state = profile;
    } catch (e) {
      debugPrint('프로필 로드 실패: $e');
    }
  }

  /// 프로필 새로고침
  Future<void> refreshProfile() async {
    await _loadProfile();
  }

  /// 프로필 업데이트
  Future<void> updateProfile(ProfileModel updatedProfile) async {
    try {
      await _profileService.saveProfile(updatedProfile);
      state = updatedProfile;
    } catch (e) {
      debugPrint('프로필 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 프로필 이미지 업데이트
  Future<void> updateProfileImage(String imagePath) async {
    try {
      final updatedProfile = state.copyWith(
        profileImagePath: imagePath,
        updatedAt: DateTime.now(),
      );
      await _profileService.saveProfile(updatedProfile);
      state = updatedProfile;
    } catch (e) {
      debugPrint('프로필 이미지 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 프로필 이미지 제거
  Future<void> removeProfileImage() async {
    try {
      final updatedProfile = state.copyWith(
        profileImagePath: '',
        updatedAt: DateTime.now(),
      );
      await _profileService.saveProfile(updatedProfile);
      state = updatedProfile;
    } catch (e) {
      debugPrint('프로필 이미지 제거 실패: $e');
      rethrow;
    }
  }

  /// 사용자 이름 업데이트
  Future<void> updateUsername(String username) async {
    try {
      final updatedProfile = state.copyWith(
        username: username,
        updatedAt: DateTime.now(),
      );
      await _profileService.saveProfile(updatedProfile);
      state = updatedProfile;
    } catch (e) {
      debugPrint('사용자 이름 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 이메일 업데이트
  Future<void> updateEmail(String email) async {
    try {
      final updatedProfile = state.copyWith(
        email: email,
        updatedAt: DateTime.now(),
      );
      await _profileService.saveProfile(updatedProfile);
      state = updatedProfile;
    } catch (e) {
      debugPrint('이메일 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 자기소개 업데이트
  Future<void> updateBio(String bio) async {
    try {
      final updatedProfile = state.copyWith(
        bio: bio,
        updatedAt: DateTime.now(),
      );
      await _profileService.saveProfile(updatedProfile);
      state = updatedProfile;
    } catch (e) {
      debugPrint('자기소개 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 프리미엄 상태 업데이트
  Future<void> updatePremiumStatus(bool isPremium) async {
    try {
      final updatedProfile = state.copyWith(
        isPremium: isPremium,
        updatedAt: DateTime.now(),
      );
      await _profileService.saveProfile(updatedProfile);
      state = updatedProfile;
    } catch (e) {
      debugPrint('프리미엄 상태 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 일기 수 증가
  Future<void> incrementDiaryCount() async {
    try {
      final updatedProfile = state.copyWith(
        totalDiaries: state.totalDiaries + 1,
        updatedAt: DateTime.now(),
      );
      await _profileService.saveProfile(updatedProfile);
      state = updatedProfile;
    } catch (e) {
      debugPrint('일기 수 증가 실패: $e');
    }
  }

  /// 연속 작성일 업데이트
  Future<void> updateConsecutiveDays(int days) async {
    try {
      final updatedProfile = state.copyWith(
        consecutiveDays: days,
        updatedAt: DateTime.now(),
      );
      await _profileService.saveProfile(updatedProfile);
      state = updatedProfile;
    } catch (e) {
      debugPrint('연속 작성일 업데이트 실패: $e');
    }
  }

  /// 총 단어 수 업데이트
  Future<void> updateTotalWords(int words) async {
    try {
      final updatedProfile = state.copyWith(
        totalWords: state.totalWords + words,
        updatedAt: DateTime.now(),
      );
      await _profileService.saveProfile(updatedProfile);
      state = updatedProfile;
    } catch (e) {
      debugPrint('총 단어 수 업데이트 실패: $e');
    }
  }

  /// 총 글자 수 업데이트
  Future<void> updateTotalCharacters(int characters) async {
    try {
      final updatedProfile = state.copyWith(
        totalCharacters: state.totalCharacters + characters,
        updatedAt: DateTime.now(),
      );
      await _profileService.saveProfile(updatedProfile);
      state = updatedProfile;
    } catch (e) {
      debugPrint('총 글자 수 업데이트 실패: $e');
    }
  }
}

/// 프로필 통계 상태 관리자
class ProfileStatsNotifier extends StateNotifier<ProfileStats> {
  ProfileStatsNotifier() : super(const ProfileStats()) {
    _loadStats();
  }

  final ProfileService _profileService = ProfileService();

  /// 통계 로드
  Future<void> _loadStats() async {
    try {
      final stats = await _profileService.loadProfileStats();
      state = stats;
    } catch (e) {
      debugPrint('프로필 통계 로드 실패: $e');
    }
  }

  /// 통계 새로고침
  Future<void> refreshStats() async {
    await _loadStats();
  }

  /// 통계 업데이트
  Future<void> updateStats(ProfileStats newStats) async {
    try {
      await _profileService.saveProfileStats(newStats);
      state = newStats;
    } catch (e) {
      debugPrint('프로필 통계 업데이트 실패: $e');
    }
  }
}
