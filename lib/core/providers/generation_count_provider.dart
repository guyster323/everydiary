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
  static const int _initialCount = 3; // 초기 무료 제공 횟수

  GenerationCountNotifier() : super(const GenerationCountState(remainingCount: 0)) {
    _loadCount();
  }

  /// 저장된 횟수 로드
  Future<void> _loadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(_storageKey) ?? _initialCount;

      // 초기 설치 시 기본 횟수 저장
      if (!prefs.containsKey(_storageKey)) {
        await prefs.setInt(_storageKey, _initialCount);
      }

      state = state.copyWith(remainingCount: count);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 외부에서 호출 가능한 횟수 새로고침 (UI 갱신용)
  Future<void> reload() async {
    print('🔵 [GenerationCount] reload 호출됨');
    await _loadCount();
    print('✅ [GenerationCount] reload 완료: count=${state.remainingCount}');
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

    print('🔵 [GenerationCount] addGenerations 호출: amount=$amount, current=${state.remainingCount}');
    state = state.copyWith(isLoading: true);
    try {
      final newCount = state.remainingCount + amount;
      await _saveCount(newCount);
      state = state.copyWith(remainingCount: newCount, isLoading: false, error: null);
      print('✅ [GenerationCount] addGenerations 완료: new count=$newCount');
    } catch (e) {
      print('❌ [GenerationCount] addGenerations 실패: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 생성 횟수 소비
  Future<bool> consumeGeneration() async {
    print('🔵 [GenerationCount] consumeGeneration 호출: current=${state.remainingCount}');
    if (state.remainingCount <= 0) {
      print('❌ [GenerationCount] consumeGeneration 실패: 남은 횟수 없음');
      return false;
    }

    state = state.copyWith(isLoading: true);
    try {
      final newCount = state.remainingCount - 1;
      await _saveCount(newCount);
      state = state.copyWith(remainingCount: newCount, isLoading: false, error: null);
      print('✅ [GenerationCount] consumeGeneration 완료: new count=$newCount');
      return true;
    } catch (e) {
      print('❌ [GenerationCount] consumeGeneration 실패: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// 횟수 초기화 (테스트용)
  Future<void> reset() async {
    await _saveCount(_initialCount);
    state = state.copyWith(remainingCount: _initialCount, isLoading: false, error: null);
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
