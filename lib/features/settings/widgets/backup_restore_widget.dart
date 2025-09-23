import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/backup_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../profile/services/profile_service.dart';
import '../services/preferences_service.dart';

/// 백업/복원 위젯
class BackupRestoreWidget extends ConsumerStatefulWidget {
  const BackupRestoreWidget({super.key});

  @override
  ConsumerState<BackupRestoreWidget> createState() =>
      _BackupRestoreWidgetState();
}

class _BackupRestoreWidgetState extends ConsumerState<BackupRestoreWidget> {
  final BackupService _backupService = BackupService(
    localStorageService: LocalStorageService.instance,
    preferencesService: PreferencesService(),
    profileService: ProfileService(),
  );

  bool _isLoading = false;
  List<BackupInfo> _availableBackups = [];
  AutoBackupSettings _autoBackupSettings = const AutoBackupSettings(
    enabled: false,
    intervalDays: 7,
    maxBackups: 5,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final backups = await _backupService.getAvailableBackups();
      final settings = await _backupService.getAutoBackupSettings();
      setState(() {
        _availableBackups = backups;
        _autoBackupSettings = settings;
      });
    } catch (e) {
      _showErrorSnackBar('데이터 로드 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('백업 및 복원'),
        const SizedBox(height: 16),
        _buildBackupActions(),
        const SizedBox(height: 24),
        _buildAutoBackupSettings(),
        const SizedBox(height: 24),
        _buildBackupList(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBackupActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _createBackup,
            icon: const Icon(Icons.backup),
            label: const Text('백업 생성'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _restoreFromFile,
            icon: const Icon(Icons.restore),
            label: const Text('파일에서 복원'),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoBackupSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '자동 백업',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: _autoBackupSettings.enabled,
                  onChanged: _updateAutoBackupEnabled,
                ),
              ],
            ),
            if (_autoBackupSettings.enabled) ...[
              const SizedBox(height: 16),
              _buildAutoBackupInterval(),
              const SizedBox(height: 12),
              _buildMaxBackups(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAutoBackupInterval() {
    return Row(
      children: [
        const Text('백업 주기: '),
        DropdownButton<int>(
          value: _autoBackupSettings.intervalDays,
          items: const [
            DropdownMenuItem(value: 1, child: Text('매일')),
            DropdownMenuItem(value: 3, child: Text('3일마다')),
            DropdownMenuItem(value: 7, child: Text('주간')),
            DropdownMenuItem(value: 14, child: Text('2주마다')),
            DropdownMenuItem(value: 30, child: Text('월간')),
          ],
          onChanged: _updateBackupInterval,
        ),
      ],
    );
  }

  Widget _buildMaxBackups() {
    return Row(
      children: [
        const Text('최대 백업 수: '),
        DropdownButton<int>(
          value: _autoBackupSettings.maxBackups,
          items: const [
            DropdownMenuItem(value: 3, child: Text('3개')),
            DropdownMenuItem(value: 5, child: Text('5개')),
            DropdownMenuItem(value: 10, child: Text('10개')),
            DropdownMenuItem(value: 20, child: Text('20개')),
          ],
          onChanged: _updateMaxBackups,
        ),
      ],
    );
  }

  Widget _buildBackupList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableBackups.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.backup_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text('백업이 없습니다', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                '첫 번째 백업을 생성해보세요',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사용 가능한 백업 (${_availableBackups.length}개)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ..._availableBackups.map((backup) => _buildBackupItem(backup)),
      ],
    );
  }

  Widget _buildBackupItem(BackupInfo backup) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.backup),
        title: Text(backup.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('생성일: ${backup.formattedDate}'),
            Text('크기: ${backup.formattedSize}'),
            _buildBackupIncludes(backup.includes),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleBackupAction(value, backup),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: ListTile(
                leading: Icon(Icons.restore),
                title: Text('복원'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('삭제', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupIncludes(Map<String, dynamic> includes) {
    final includedItems = <String>[];
    if (includes['settings'] == true) includedItems.add('설정');
    if (includes['profile'] == true) includedItems.add('프로필');
    if (includes['diaryData'] == true) includedItems.add('일기');

    return Text(
      '포함: ${includedItems.join(', ')}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);
    try {
      final result = await _backupService.createBackup();
      if (result.isSuccess) {
        _showSuccessSnackBar('백업이 성공적으로 생성되었습니다.');
        await _loadData();
      } else {
        _showErrorSnackBar(result.errorMessage ?? '백업 생성에 실패했습니다.');
      }
    } catch (e) {
      _showErrorSnackBar('백업 생성 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        await _restoreFromBackup(filePath);
      }
    } catch (e) {
      _showErrorSnackBar('파일 선택 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _restoreFromBackup(String filePath) async {
    final confirmed = await _showRestoreConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final result = await _backupService.restoreFromBackup(filePath);
      if (result.isSuccess) {
        _showSuccessSnackBar('복원이 성공적으로 완료되었습니다.');
        await _loadData();
      } else {
        _showErrorSnackBar(result.errorMessage ?? '복원에 실패했습니다.');
      }
    } catch (e) {
      _showErrorSnackBar('복원 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBackupAction(String action, BackupInfo backup) async {
    switch (action) {
      case 'restore':
        await _restoreFromBackup(backup.filePath);
        break;
      case 'delete':
        await _deleteBackup(backup);
        break;
    }
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    final confirmed = await _showDeleteConfirmationDialog(backup.name);
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final success = await _backupService.deleteBackup(backup.filePath);
      if (success) {
        _showSuccessSnackBar('백업이 삭제되었습니다.');
        await _loadData();
      } else {
        _showErrorSnackBar('백업 삭제에 실패했습니다.');
      }
    } catch (e) {
      _showErrorSnackBar('백업 삭제 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAutoBackupEnabled(bool enabled) async {
    try {
      await _backupService.setAutoBackup(
        enabled: enabled,
        intervalDays: _autoBackupSettings.intervalDays,
        maxBackups: _autoBackupSettings.maxBackups,
      );
      setState(() {
        _autoBackupSettings = AutoBackupSettings(
          enabled: enabled,
          intervalDays: _autoBackupSettings.intervalDays,
          maxBackups: _autoBackupSettings.maxBackups,
        );
      });
    } catch (e) {
      _showErrorSnackBar('자동 백업 설정 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _updateBackupInterval(int? intervalDays) async {
    if (intervalDays == null) return;

    try {
      await _backupService.setAutoBackup(
        enabled: _autoBackupSettings.enabled,
        intervalDays: intervalDays,
        maxBackups: _autoBackupSettings.maxBackups,
      );
      setState(() {
        _autoBackupSettings = AutoBackupSettings(
          enabled: _autoBackupSettings.enabled,
          intervalDays: intervalDays,
          maxBackups: _autoBackupSettings.maxBackups,
        );
      });
    } catch (e) {
      _showErrorSnackBar('백업 주기 설정 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _updateMaxBackups(int? maxBackups) async {
    if (maxBackups == null) return;

    try {
      await _backupService.setAutoBackup(
        enabled: _autoBackupSettings.enabled,
        intervalDays: _autoBackupSettings.intervalDays,
        maxBackups: maxBackups,
      );
      setState(() {
        _autoBackupSettings = AutoBackupSettings(
          enabled: _autoBackupSettings.enabled,
          intervalDays: _autoBackupSettings.intervalDays,
          maxBackups: maxBackups,
        );
      });
    } catch (e) {
      _showErrorSnackBar('최대 백업 수 설정 중 오류가 발생했습니다: $e');
    }
  }

  Future<bool> _showRestoreConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('데이터 복원'),
            content: const Text(
              '현재 데이터가 백업 데이터로 덮어씌워집니다.\n'
              '이 작업은 되돌릴 수 없습니다.\n\n'
              '계속하시겠습니까?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('복원'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showDeleteConfirmationDialog(String backupName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('백업 삭제'),
            content: Text('백업 "$backupName"을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('삭제'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
