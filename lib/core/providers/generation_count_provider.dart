import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 이미지 생성 횟수 관리 상태
class GenerationCountState {
  final int remainingCount;
  final bool isLoading;
  final String? error;

  const GenerationCountState({
    required this.remainingCount,
    this.isLoading = false,
    this.error,
  });

  GenerationCountState copyWith({
    int? remainingCount,
    bool? isLoading,
    String? error,
  }) {
    return GenerationCountState(
      remainingCount: remainingCount ?? this.remainingCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 이미지 생성 횟수 관리 노티파이어
class GenerationCountNotifier extends StateNotifier<GenerationCountState> {
  static const String _storageKey = 'remaining_generations';
  static const String _lastResetDateKey = 'generation_last_reset_date';
  static const int _initialCount = 3; // 초기 무료 제공 횟수

  // AdMob 정책 이슈로 인한 임시 제한 (2026-01-03 ~ 2026-02-15)
  static final DateTime _adPolicyLimitStartDate = DateTime(2026, 1, 3);
  static final DateTime _adPolicyLimitEndDate = DateTime(2026, 2, 15);
  static const int _adPolicyLimitCount = 2; // 임시 제한 기간 중 초기 무료 횟수

  GenerationCountNotifier() : super(const GenerationCountState(remainingCount: 0)) {
    _loadCount();
  }

  /// 현재 AdMob 정책 제한 기간인지 확인
  static bool isInAdPolicyLimitPeriod() {
    final now = DateTime.now();
    return now.isAfter(_adPolicyLimitStartDate.subtract(const Duration(days: 1))) &&
           now.isBefore(_adPolicyLimitEndDate.add(const Duration(days: 1)));
  }

  /// 현재 적용되어야 할 초기 횟수 반환
  static int getCurrentInitialCount() {
    return isInAdPolicyLimitPeriod() ? _adPolicyLimitCount : _initialCount;
  }

  /// 저장된 횟수 로드
  Future<void> _loadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final lastResetDate = prefs.getString(_lastResetDateKey);

      // 정책 제한 기간 중에는 매일 2회로 초기화
      if (isInAdPolicyLimitPeriod()) {
        // 오늘 날짜와 마지막 리셋 날짜가 다르면 2회로 리셋
        if (lastResetDate != today) {
          await prefs.setInt(_storageKey, _adPolicyLimitCount);
          await prefs.setString(_lastResetDateKey, today);
          state = state.copyWith(remainingCount: _adPolicyLimitCount);
          debugPrint('🔔 [GenerationCount] 정책 기간 중 일일 리셋 - $_adPolicyLimitCount회로 초기화 (날짜: $today)');
          return;
        }
        // 오늘 이미 리셋됨 - 저장된 값 사용
        final count = prefs.getInt(_storageKey) ?? _adPolicyLimitCount;
        state = state.copyWith(remainingCount: count);
        return;
      }

      // 정책 기간 외: 기존 로직
      const currentInitialCount = _initialCount;
      final count = prefs.getInt(_storageKey) ?? currentInitialCount;

      // 초기 설치 시 기본 횟수 저장
      if (!prefs.containsKey(_storageKey)) {
        await prefs.setInt(_storageKey, currentInitialCount);
        await prefs.setString(_lastResetDateKey, today);
      }

      state = state.copyWith(remainingCount: count);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 외부에서 호출 가능한 횟수 새로고침 (UI 갱신용)
  Future<void> reload() async {
    debugPrint('🔵 [GenerationCount] reload 호출됨');
    await _loadCount();
    debugPrint('✅ [GenerationCount] reload 완료: count=${state.remainingCount}');
  }

  /// 횟수 저장
  Future<void> _saveCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_storageKey, count);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 생성 횟수 추가
  Future<void> addGenerations(int amount) async {
    if (amount <= 0) return;

    debugPrint('🔵 [GenerationCount] addGenerations 호출: amount=$amount, current=${state.remainingCount}');
    state = state.copyWith(isLoading: true);
    try {
      final newCount = state.remainingCount + amount;
      await _saveCount(newCount);
      state = state.copyWith(remainingCount: newCount, isLoading: false, error: null);
      debugPrint('✅ [GenerationCount] addGenerations 완료: new count=$newCount');
    } catch (e) {
      debugPrint('❌ [GenerationCount] addGenerations 실패: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 생성 횟수 소비
  Future<bool> consumeGeneration() async {
    debugPrint('🔵 [GenerationCount] consumeGeneration 호출: current=${state.remainingCount}');
    if (state.remainingCount <= 0) {
      debugPrint('❌ [GenerationCount] consumeGeneration 실패: 남은 횟수 없음');
      return false;
    }

    state = state.copyWith(isLoading: true);
    try {
      final newCount = state.remainingCount - 1;
      await _saveCount(newCount);
      state = state.copyWith(remainingCount: newCount, isLoading: false, error: null);
      debugPrint('✅ [GenerationCount] consumeGeneration 완료: new count=$newCount');
      return true;
    } catch (e) {
      debugPrint('❌ [GenerationCount] consumeGeneration 실패: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// 횟수 초기화 (테스트용)
  Future<void> reset() async {
    final currentInitialCount = getCurrentInitialCount();
    await _saveCount(currentInitialCount);
    state = state.copyWith(remainingCount: currentInitialCount, isLoading: false, error: null);
  }
}

/// 이미지 생성 횟수 프로바이더
final generationCountProvider = StateNotifierProvider<GenerationCountNotifier, GenerationCountState>((ref) {
  return GenerationCountNotifier();
});

/// 남은 횟수만 제공하는 간단한 프로바이더
final remainingGenerationsProvider = Provider<AsyncValue<int>>((ref) {
  final countState = ref.watch(generationCountProvider);
  return AsyncValue.data(countState.remainingCount);
});

/// 이미지 생성 횟수 서비스 NotifierProvider (추가/소비 메소드 제공)
final generationCountServiceProvider = Provider<GenerationCountNotifier>((ref) {
  return ref.watch(generationCountProvider.notifier);
});
