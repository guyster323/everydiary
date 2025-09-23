import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/local_storage_service.dart';
import '../services/advanced_settings_service.dart';

/// 설정 저장소 위젯
/// 설정 저장소 상태를 표시하고 관리할 수 있는 위젯입니다.
class SettingsStorageWidget extends ConsumerStatefulWidget {
  const SettingsStorageWidget({super.key});

  @override
  ConsumerState<SettingsStorageWidget> createState() =>
      _SettingsStorageWidgetState();
}

class _SettingsStorageWidgetState extends ConsumerState<SettingsStorageWidget> {
  final AdvancedSettingsService _settingsService = AdvancedSettingsService();
  final LocalStorageService _storageService = LocalStorageService.instance;

  StorageStatus? _storageStatus;
  SettingsStatistics? _settingsStats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  /// 저장소 정보 로드
  Future<void> _loadStorageInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final storageStatus = await _storageService.getStorageStatus();
      final settingsStats = await _settingsService.getSettingsStatistics();

      if (mounted) {
        setState(() {
          _storageStatus = storageStatus;
          _settingsStats = settingsStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장소 정보 로드 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '저장소 정보',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isLoading ? null : _loadStorageInfo,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  tooltip: '새로고침',
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_storageStatus != null && _settingsStats != null)
              _buildStorageInfo()
            else
              const Text('저장소 정보를 불러올 수 없습니다'),

            const SizedBox(height: 16),

            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageInfo() {
    return Column(
      children: [
        _buildInfoRow('총 키 수', '${_storageStatus!.totalKeys}개'),
        _buildInfoRow('저장소 크기', _storageStatus!.formattedSize),
        _buildInfoRow('설정 변경 횟수', '${_settingsStats!.totalChanges}회'),
        _buildInfoRow('마지막 수정', _formatDate(_settingsStats!.lastModified)),
        _buildInfoRow('설정 유효성', _settingsStats!.isValid ? '유효' : '무효'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: _exportSettings,
          icon: const Icon(Icons.download),
          label: const Text('내보내기'),
        ),
        ElevatedButton.icon(
          onPressed: _importSettings,
          icon: const Icon(Icons.upload),
          label: const Text('가져오기'),
        ),
        ElevatedButton.icon(
          onPressed: _showHistory,
          icon: const Icon(Icons.history),
          label: const Text('히스토리'),
        ),
        ElevatedButton.icon(
          onPressed: _cleanupStorage,
          icon: const Icon(Icons.cleaning_services),
          label: const Text('정리'),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '없음';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  /// 설정 내보내기
  void _exportSettings() async {
    try {
      final settingsJson = await _settingsService.exportSettings();

      if (settingsJson != null) {
        // 클립보드에 복사
        await _copyToClipboard(settingsJson);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('설정이 클립보드에 복사되었습니다')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('설정 내보내기 실패')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('내보내기 실패: $e')));
      }
    }
  }

  /// 설정 가져오기
  void _importSettings() {
    showDialog<void>(
      context: context,
      builder: (context) => _ImportSettingsDialog(
        onImport: (settingsJson) async {
          final navigator = Navigator.of(context);
          final scaffoldMessenger = ScaffoldMessenger.of(context);

          try {
            final success = await _settingsService.importSettings(settingsJson);

            if (mounted) {
              navigator.pop();

              if (success) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('설정이 성공적으로 가져와졌습니다')),
                );
                _loadStorageInfo(); // 정보 새로고침
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('설정 가져오기 실패')),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              navigator.pop();
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('가져오기 실패: $e')),
              );
            }
          }
        },
      ),
    );
  }

  /// 히스토리 보기
  void _showHistory() async {
    try {
      final history = await _settingsService.getSettingsHistory();

      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => _SettingsHistoryDialog(
            history: history,
            onRestore: (historyId) async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              try {
                final success = await _settingsService.restoreFromHistory(
                  historyId,
                );

                if (mounted) {
                  navigator.pop();

                  if (success) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('설정이 복원되었습니다')),
                    );
                    _loadStorageInfo(); // 정보 새로고침
                  } else {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('설정 복원 실패')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('복원 실패: $e')),
                  );
                }
              }
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('히스토리 로드 실패: $e')));
      }
    }
  }

  /// 저장소 정리
  void _cleanupStorage() async {
    try {
      final removedCount = await _settingsService.cleanupHistory(
        maxEntries: 10,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$removedCount개의 오래된 히스토리가 정리되었습니다')),
        );
        _loadStorageInfo(); // 정보 새로고침
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('정리 실패: $e')));
      }
    }
  }

  /// 클립보드에 복사
  Future<void> _copyToClipboard(String text) async {
    // 클립보드 복사 기능 구현
    try {
      await Clipboard.setData(ClipboardData(text: text));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('클립보드에 복사되었습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('클립보드 복사 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('복사 실패: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

/// 설정 가져오기 다이얼로그
class _ImportSettingsDialog extends StatefulWidget {
  final void Function(String) onImport;

  const _ImportSettingsDialog({required this.onImport});

  @override
  State<_ImportSettingsDialog> createState() => _ImportSettingsDialogState();
}

class _ImportSettingsDialogState extends State<_ImportSettingsDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('설정 가져오기'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('설정 JSON을 입력하세요:'),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '설정 JSON을 여기에 붙여넣으세요...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            final settingsJson = _controller.text.trim();
            if (settingsJson.isNotEmpty) {
              widget.onImport(settingsJson);
            }
          },
          child: const Text('가져오기'),
        ),
      ],
    );
  }
}

/// 설정 히스토리 다이얼로그
class _SettingsHistoryDialog extends StatelessWidget {
  final List<SettingsHistoryEntry> history;
  final void Function(String) onRestore;

  const _SettingsHistoryDialog({
    required this.history,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('설정 히스토리'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: history.isEmpty
            ? const Center(child: Text('히스토리가 없습니다'))
            : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  return ListTile(
                    leading: const Icon(Icons.settings),
                    title: Text(entry.description),
                    subtitle: Text(_formatDate(entry.timestamp)),
                    trailing: IconButton(
                      onPressed: () => onRestore(entry.id),
                      icon: const Icon(Icons.restore),
                      tooltip: '복원',
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
