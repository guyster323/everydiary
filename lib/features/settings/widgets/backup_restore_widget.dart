import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/localization_provider.dart';
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
      final l10n = ref.read(localizationProvider);
      _showErrorSnackBar(l10n.get('load_error_backup').replaceAll('{error}', e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.get('backup_section_title')),
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
    final l10n = ref.watch(localizationProvider);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _createBackup,
            icon: const Icon(Icons.backup),
            label: Text(l10n.get('create_backup_button')),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _restoreFromFile,
            icon: const Icon(Icons.restore),
            label: Text(l10n.get('restore_from_file_button')),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoBackupSettings() {
    final l10n = ref.watch(localizationProvider);

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
                    l10n.get('auto_backup_title'),
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
    final l10n = ref.watch(localizationProvider);

    return Row(
      children: [
        Text(l10n.get('backup_interval_label')),
        DropdownButton<int>(
          value: _autoBackupSettings.intervalDays,
          items: [
            DropdownMenuItem(value: 1, child: Text(l10n.get('interval_daily'))),
            DropdownMenuItem(value: 3, child: Text(l10n.get('interval_3days'))),
            DropdownMenuItem(value: 7, child: Text(l10n.get('interval_weekly'))),
            DropdownMenuItem(value: 14, child: Text(l10n.get('interval_biweekly'))),
            DropdownMenuItem(value: 30, child: Text(l10n.get('interval_monthly'))),
          ],
          onChanged: _updateBackupInterval,
        ),
      ],
    );
  }

  Widget _buildMaxBackups() {
    final l10n = ref.watch(localizationProvider);

    return Row(
      children: [
        Text(l10n.get('max_backups_label')),
        DropdownButton<int>(
          value: _autoBackupSettings.maxBackups,
          items: [
            DropdownMenuItem(value: 3, child: Text(l10n.get('max_3'))),
            DropdownMenuItem(value: 5, child: Text(l10n.get('max_5'))),
            DropdownMenuItem(value: 10, child: Text(l10n.get('max_10'))),
            DropdownMenuItem(value: 20, child: Text(l10n.get('max_20'))),
          ],
          onChanged: _updateMaxBackups,
        ),
      ],
    );
  }

  Widget _buildBackupList() {
    final l10n = ref.watch(localizationProvider);

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
              Text(l10n.get('no_backups_title'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                l10n.get('no_backups_subtitle'),
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
          l10n.get('available_backups_title').replaceAll('{count}', _availableBackups.length.toString()),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ..._availableBackups.map((backup) => _buildBackupItem(backup)),
      ],
    );
  }

  Widget _buildBackupItem(BackupInfo backup) {
    final l10n = ref.watch(localizationProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.backup),
        title: Text(backup.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.get('created_date_label').replaceAll('{date}', backup.formattedDate)),
            Text(l10n.get('size_label').replaceAll('{size}', backup.formattedSize)),
            _buildBackupIncludes(backup.includes),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleBackupAction(value, backup),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'restore',
              child: ListTile(
                leading: const Icon(Icons.restore),
                title: Text(l10n.get('restore_action')),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(l10n.get('delete_action'), style: const TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupIncludes(Map<String, dynamic> includes) {
    final l10n = ref.watch(localizationProvider);
    final includedItems = <String>[];
    if (includes['settings'] == true) includedItems.add(l10n.get('includes_settings'));
    if (includes['profile'] == true) includedItems.add(l10n.get('includes_profile'));
    if (includes['diaryData'] == true) includedItems.add(l10n.get('includes_diary'));

    return Text(
      l10n.get('includes_label').replaceAll('{items}', includedItems.join(', ')),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Future<void> _createBackup() async {
    final l10n = ref.read(localizationProvider);
    setState(() => _isLoading = true);
    try {
      final result = await _backupService.createBackup();
      if (result.isSuccess) {
        _showSuccessSnackBar(l10n.get('backup_success'));
        await _loadData();
      } else {
        _showErrorSnackBar(result.errorMessage ?? l10n.get('backup_failed'));
      }
    } catch (e) {
      _showErrorSnackBar(l10n.get('backup_error').replaceAll('{error}', e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreFromFile() async {
    final l10n = ref.read(localizationProvider);
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
      _showErrorSnackBar(l10n.get('file_picker_error').replaceAll('{error}', e.toString()));
    }
  }

  Future<void> _restoreFromBackup(String filePath) async {
    final confirmed = await _showRestoreConfirmationDialog();
    if (!confirmed) return;

    final l10n = ref.read(localizationProvider);
    setState(() => _isLoading = true);
    try {
      final result = await _backupService.restoreFromBackup(filePath);
      if (result.isSuccess) {
        _showSuccessSnackBar(l10n.get('restore_success'));
        await _loadData();
      } else {
        _showErrorSnackBar(result.errorMessage ?? l10n.get('restore_failed'));
      }
    } catch (e) {
      _showErrorSnackBar(l10n.get('restore_error').replaceAll('{error}', e.toString()));
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

    final l10n = ref.read(localizationProvider);
    setState(() => _isLoading = true);
    try {
      final success = await _backupService.deleteBackup(backup.filePath);
      if (success) {
        _showSuccessSnackBar(l10n.get('delete_success'));
        await _loadData();
      } else {
        _showErrorSnackBar(l10n.get('delete_failed'));
      }
    } catch (e) {
      _showErrorSnackBar(l10n.get('delete_error').replaceAll('{error}', e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAutoBackupEnabled(bool enabled) async {
    final l10n = ref.read(localizationProvider);
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
      _showErrorSnackBar(l10n.get('auto_backup_update_error').replaceAll('{error}', e.toString()));
    }
  }

  Future<void> _updateBackupInterval(int? intervalDays) async {
    if (intervalDays == null) return;

    final l10n = ref.read(localizationProvider);
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
      _showErrorSnackBar(l10n.get('interval_update_error').replaceAll('{error}', e.toString()));
    }
  }

  Future<void> _updateMaxBackups(int? maxBackups) async {
    if (maxBackups == null) return;

    final l10n = ref.read(localizationProvider);
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
      _showErrorSnackBar(l10n.get('max_backups_update_error').replaceAll('{error}', e.toString()));
    }
  }

  Future<bool> _showRestoreConfirmationDialog() async {
    final l10n = ref.read(localizationProvider);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.get('restore_confirm_title')),
            content: Text(l10n.get('restore_confirm_message')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.get('cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.get('yes')),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showDeleteConfirmationDialog(String backupName) async {
    final l10n = ref.read(localizationProvider);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.get('delete_confirm_title')),
            content: Text(l10n.get('delete_confirm_message').replaceAll('{name}', backupName)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.get('cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.get('delete_action')),
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
