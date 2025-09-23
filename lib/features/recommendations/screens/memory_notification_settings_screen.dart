import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_error_widget.dart';
import '../../../core/widgets/custom_loading.dart';
import '../models/memory_filter.dart';
import '../services/memory_notification_service.dart';

/// 회상 알림 설정 화면
class MemoryNotificationSettingsScreen extends ConsumerStatefulWidget {
  const MemoryNotificationSettingsScreen({super.key});

  @override
  ConsumerState<MemoryNotificationSettingsScreen> createState() =>
      _MemoryNotificationSettingsScreenState();
}

class _MemoryNotificationSettingsScreenState
    extends ConsumerState<MemoryNotificationSettingsScreen> {
  final MemoryNotificationService _notificationService =
      MemoryNotificationService();

  bool _isLoading = false;
  String? _error;
  bool _notificationsEnabled = false;
  bool _hasPermission = false;
  List<int> _selectedHours = [9, 18]; // 기본값: 오전 9시, 오후 6시
  MemorySettings _settings = const MemorySettings();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 알림 권한 확인
      final hasPermission = await _notificationService.hasPermission();

      // 사용자 설정에서 알림 설정 로드
      await _loadNotificationSettings();

      setState(() {
        _hasPermission = hasPermission;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 알림 설정 로드
  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 알림 활성화 상태 로드
      _notificationsEnabled =
          prefs.getBool('memory_notifications_enabled') ?? false;

      // 선택된 시간들 로드
      final hoursString = prefs.getString('memory_notification_hours');
      if (hoursString != null) {
        _selectedHours = hoursString.split(',').map(int.parse).toList();
      }

      // 설정 로드
      final settingsString = prefs.getString('memory_notification_settings');
      if (settingsString != null) {
        final settingsMap = jsonDecode(settingsString) as Map<String, dynamic>;
        _settings = MemorySettings.fromJson(settingsMap);
      }
    } catch (e) {
      debugPrint('알림 설정 로드 실패: $e');
    }
  }

  /// 알림 설정 저장
  Future<void> _saveNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 알림 활성화 상태 저장
      await prefs.setBool(
        'memory_notifications_enabled',
        _notificationsEnabled,
      );

      // 선택된 시간들 저장
      await prefs.setString(
        'memory_notification_hours',
        _selectedHours.join(','),
      );

      // 설정 저장
      await prefs.setString(
        'memory_notification_settings',
        jsonEncode(_settings.toJson()),
      );
    } catch (e) {
      debugPrint('알림 설정 저장 실패: $e');
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final granted = await _notificationService.requestPermission();
      setState(() {
        _hasPermission = granted;
        _notificationsEnabled = granted;
        _isLoading = false;
      });

      if (mounted) {
        if (granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('알림 권한이 허용되었습니다'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('알림 권한이 거부되었습니다'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool enabled) async {
    if (!_hasPermission && enabled) {
      await _requestPermission();
      return;
    }

    setState(() {
      _notificationsEnabled = enabled;
    });

    if (enabled) {
      await _scheduleNotifications();
    } else {
      await _notificationService.cancelAllMemoryNotifications();
    }

    // 설정 저장
    await _saveNotificationSettings();
  }

  Future<void> _scheduleNotifications() async {
    try {
      // 실제 사용자 ID를 가져오기 (임시로 1 사용)
      const userId = '1';

      await _notificationService.scheduleDailyMemoryNotifications(
        userId: userId,
        notificationHours: _selectedHours,
        settings: _settings,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회상 알림이 설정되었습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('알림 설정 중 오류가 발생했습니다: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showTimePicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _TimeSelectionBottomSheet(
        selectedHours: _selectedHours,
        onHoursChanged: (hours) {
          setState(() {
            _selectedHours = hours;
          });
          if (_notificationsEnabled) {
            _scheduleNotifications();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '회상 알림 설정'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CustomLoading(message: '설정을 불러오는 중...'));
    }

    if (_error != null) {
      return CustomErrorWidget(
        message: '설정을 불러오는데 실패했습니다',
        error: _error!,
        onRetry: _loadSettings,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 알림 활성화/비활성화
          _buildNotificationToggle(),
          const SizedBox(height: 24),

          // 알림 시간 설정
          if (_notificationsEnabled) ...[
            _buildTimeSettings(),
            const SizedBox(height: 24),
          ],

          // 알림 유형 설정
          if (_notificationsEnabled) ...[
            _buildNotificationTypes(),
            const SizedBox(height: 24),
          ],

          // 권한 상태
          _buildPermissionStatus(),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '회상 알림',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '과거 일기를 회상하도록 알림을 받습니다',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSettings() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '알림 시간',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _showTimePicker,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '알림 받을 시간',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedHours
                              .map((h) => '${h.toString().padLeft(2, '0')}:00')
                              .join(', '),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypes() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '알림 유형',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildNotificationTypeItem(
            '어제의 기록',
            '어제 작성한 일기를 회상합니다',
            _settings.enableYesterdayMemories,
            (value) {
              setState(() {
                _settings = _settings.copyWith(enableYesterdayMemories: value);
              });
            },
          ),
          _buildNotificationTypeItem(
            '일주일 전의 기록',
            '일주일 전 작성한 일기를 회상합니다',
            _settings.enableOneWeekAgoMemories,
            (value) {
              setState(() {
                _settings = _settings.copyWith(enableOneWeekAgoMemories: value);
              });
            },
          ),
          _buildNotificationTypeItem(
            '한달 전의 기록',
            '한달 전 작성한 일기를 회상합니다',
            _settings.enableOneMonthAgoMemories,
            (value) {
              setState(() {
                _settings = _settings.copyWith(
                  enableOneMonthAgoMemories: value,
                );
              });
            },
          ),
          _buildNotificationTypeItem(
            '1년 전의 기록',
            '1년 전 작성한 일기를 회상합니다',
            _settings.enableOneYearAgoMemories,
            (value) {
              setState(() {
                _settings = _settings.copyWith(enableOneYearAgoMemories: value);
              });
            },
          ),
          _buildNotificationTypeItem(
            '과거의 오늘',
            '작년, 재작년 같은 날의 기록을 회상합니다',
            _settings.enablePastTodayMemories,
            (value) {
              setState(() {
                _settings = _settings.copyWith(enablePastTodayMemories: value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypeItem(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildPermissionStatus() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _hasPermission ? Icons.check_circle : Icons.warning,
                color: _hasPermission
                    ? Colors.green
                    : Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '알림 권한',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _hasPermission ? '알림 권한이 허용되었습니다' : '알림 권한이 필요합니다',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _hasPermission
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_hasPermission)
                TextButton(
                  onPressed: _requestPermission,
                  child: const Text('권한 요청'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 시간 선택 바텀시트
class _TimeSelectionBottomSheet extends StatefulWidget {
  final List<int> selectedHours;
  final ValueChanged<List<int>> onHoursChanged;

  const _TimeSelectionBottomSheet({
    required this.selectedHours,
    required this.onHoursChanged,
  });

  @override
  State<_TimeSelectionBottomSheet> createState() =>
      _TimeSelectionBottomSheetState();
}

class _TimeSelectionBottomSheetState extends State<_TimeSelectionBottomSheet> {
  late List<int> _selectedHours;

  @override
  void initState() {
    super.initState();
    _selectedHours = List.from(widget.selectedHours);
  }

  void _toggleHour(int hour) {
    setState(() {
      if (_selectedHours.contains(hour)) {
        _selectedHours.remove(hour);
      } else {
        _selectedHours.add(hour);
        _selectedHours.sort();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '알림 시간 선택',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 24,
              itemBuilder: (context, index) {
                final hour = index;
                final isSelected = _selectedHours.contains(hour);

                return InkWell(
                  onTap: () => _toggleHour(hour),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onHoursChanged(_selectedHours);
                    Navigator.of(context).pop();
                  },
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
