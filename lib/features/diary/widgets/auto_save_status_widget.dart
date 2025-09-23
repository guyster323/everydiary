import 'package:flutter/material.dart';

import '../services/auto_save_service.dart';

/// 자동 저장 상태 표시 위젯
class AutoSaveStatusWidget extends StatelessWidget {
  final AutoSaveService autoSaveService;

  const AutoSaveStatusWidget({super.key, required this.autoSaveService});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: autoSaveService,
      builder: (context, child) {
        switch (autoSaveService.status) {
          case AutoSaveStatus.idle:
            return const SizedBox.shrink();

          case AutoSaveStatus.saving:
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '저장 중...',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                  ),
                ],
              ),
            );

          case AutoSaveStatus.saved:
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 12,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '저장됨',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            );

          case AutoSaveStatus.error:
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error, size: 12, color: Colors.red.shade600),
                  const SizedBox(width: 6),
                  Text(
                    '저장 실패',
                    style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}
