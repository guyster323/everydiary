import 'package:flutter/material.dart';

/// 성능 테스트 컨트롤 위젯
/// 다양한 성능 테스트를 실행할 수 있는 버튼들을 제공합니다.
class PerformanceTestControls extends StatelessWidget {
  final bool isRunning;
  final String currentTest;
  final VoidCallback onSingleTest;
  final VoidCallback onBatchTest;
  final VoidCallback onPreprocessingTest;

  const PerformanceTestControls({
    super.key,
    required this.isRunning,
    required this.currentTest,
    required this.onSingleTest,
    required this.onBatchTest,
    required this.onPreprocessingTest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 현재 테스트 상태
          if (isRunning) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      currentTest,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 테스트 버튼들
          Row(
            children: [
              Expanded(
                child: _buildTestButton(
                  icon: Icons.image,
                  title: '단일 테스트',
                  description: '이미지 1개',
                  onPressed: isRunning ? null : onSingleTest,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTestButton(
                  icon: Icons.photo_library,
                  title: '배치 테스트',
                  description: '이미지 5개',
                  onPressed: isRunning ? null : onBatchTest,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 전처리 비교 테스트
          SizedBox(
            width: double.infinity,
            child: _buildTestButton(
              icon: Icons.compare,
              title: '전처리 비교',
              description: '전처리 유무 비교',
              onPressed: isRunning ? null : onPreprocessingTest,
              color: Colors.orange,
              isFullWidth: true,
            ),
          ),

          // 도움말 텍스트
          const SizedBox(height: 16),
          Text(
            isRunning
                ? '테스트가 실행 중입니다. 잠시만 기다려주세요...'
                : '다양한 성능 테스트를 실행하여 OCR 기능을 최적화하세요',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 테스트 버튼 빌드
  Widget _buildTestButton({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback? onPressed,
    required Color color,
    bool isFullWidth = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      child: isFullWidth
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
    );
  }
}
