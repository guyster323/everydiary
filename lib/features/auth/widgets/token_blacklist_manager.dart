import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/token_blacklist_service.dart';

/// 토큰 블랙리스트 관리 위젯
class TokenBlacklistManager extends ConsumerStatefulWidget {
  const TokenBlacklistManager({super.key});

  @override
  ConsumerState<TokenBlacklistManager> createState() =>
      _TokenBlacklistManagerState();
}

class _TokenBlacklistManagerState extends ConsumerState<TokenBlacklistManager> {
  BlacklistStats? _stats;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await TokenBlacklistService.getBlacklistStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanupExpiredTokens() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await TokenBlacklistService.cleanupExpiredTokens();
      await _loadStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('만료된 토큰이 정리되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _clearBlacklist() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('블랙리스트 초기화'),
        content: const Text('모든 토큰 블랙리스트를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        await TokenBlacklistService.clearBlacklist();
        await _loadStats();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('블랙리스트가 초기화되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security),
                const SizedBox(width: 8),
                const Text(
                  '토큰 블랙리스트 관리',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isLoading ? null : _loadStats,
                  icon: const Icon(Icons.refresh),
                  tooltip: '새로고침',
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            '오류 발생',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadStats,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_stats != null)
              Column(
                children: [
                  _buildStatsCard(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('데이터를 불러올 수 없습니다.'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final stats = _stats!;

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '블랙리스트 통계',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '전체 토큰',
                    stats.totalTokens.toString(),
                    Icons.token,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '활성 토큰',
                    stats.activeTokens.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '만료 토큰',
                    stats.expiredTokens.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
              ],
            ),
            if (stats.oldestToken != null || stats.newestToken != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              if (stats.oldestToken != null)
                _buildDateInfo('가장 오래된 토큰', stats.oldestToken!),
              if (stats.newestToken != null)
                _buildDateInfo('가장 최근 토큰', stats.newestToken!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDateInfo(String label, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          Text(
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _cleanupExpiredTokens,
            icon: const Icon(Icons.cleaning_services),
            label: const Text('만료된 토큰 정리'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
              foregroundColor: Colors.orange.shade700,
              side: BorderSide(color: Colors.orange.shade200),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _clearBlacklist,
            icon: const Icon(Icons.delete_forever),
            label: const Text('블랙리스트 초기화'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade200),
            ),
          ),
        ),
      ],
    );
  }
}

/// 토큰 블랙리스트 상태 표시 위젯
class TokenBlacklistStatusWidget extends ConsumerStatefulWidget {
  const TokenBlacklistStatusWidget({super.key});

  @override
  ConsumerState<TokenBlacklistStatusWidget> createState() =>
      _TokenBlacklistStatusWidgetState();
}

class _TokenBlacklistStatusWidgetState
    extends ConsumerState<TokenBlacklistStatusWidget> {
  BlacklistStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await TokenBlacklistService.getBlacklistStats();
      if (mounted) {
        setState(() {
          _stats = stats;
        });
      }
    } catch (e) {
      // 에러는 무시 (상태 표시 위젯이므로)
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stats == null) {
      return const SizedBox.shrink();
    }

    final stats = _stats!;

    if (stats.totalTokens == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      color: stats.expiredTokens > 0
          ? Colors.orange.shade50
          : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              stats.expiredTokens > 0 ? Icons.warning : Icons.security,
              color: stats.expiredTokens > 0 ? Colors.orange : Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '토큰 블랙리스트: ${stats.activeTokens}개 활성, ${stats.expiredTokens}개 만료',
                style: TextStyle(
                  fontSize: 12,
                  color: stats.expiredTokens > 0
                      ? Colors.orange.shade700
                      : Colors.green.shade700,
                ),
              ),
            ),
            if (stats.expiredTokens > 0)
              TextButton(
                onPressed: () async {
                  await TokenBlacklistService.cleanupExpiredTokens();
                  await _loadStats();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('정리', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}

