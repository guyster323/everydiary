import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/profile_model.dart';

/// 프로필 편집 다이얼로그
/// 사용자의 프로필 정보를 편집할 수 있는 다이얼로그입니다.
class ProfileEditDialog extends StatefulWidget {
  final ProfileModel profile;
  final void Function(ProfileModel) onSave;

  const ProfileEditDialog({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _timezoneController;
  late TextEditingController _languageController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _emailController = TextEditingController(text: widget.profile.email);
    _bioController = TextEditingController(text: widget.profile.bio);
    _timezoneController = TextEditingController(text: widget.profile.timezone);
    _languageController = TextEditingController(text: widget.profile.language);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _timezoneController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('프로필 편집'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 사용자 이름
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '사용자 이름',
                  hintText: '이름을 입력하세요',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 16),

              // 이메일
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  hintText: '이메일을 입력하세요',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              // 자기소개
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: '자기소개',
                  hintText: '자기소개를 입력하세요',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),

              // 타임존
              TextField(
                controller: _timezoneController,
                decoration: const InputDecoration(
                  labelText: '타임존',
                  hintText: '예: Asia/Seoul',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _showTimezonePicker(),
              ),

              const SizedBox(height: 16),

              // 언어
              TextField(
                controller: _languageController,
                decoration: const InputDecoration(
                  labelText: '언어',
                  hintText: '언어를 선택하세요',
                  prefixIcon: Icon(Icons.language),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _showLanguagePicker(),
              ),

              const SizedBox(height: 16),

              // 프리미엄 상태
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.profile.isPremium ? Icons.star : Icons.star_border,
                      color: widget.profile.isPremium
                          ? Colors.amber
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '프리미엄 상태',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            widget.profile.isPremium
                                ? '프리미엄 사용자입니다'
                                : '일반 사용자입니다',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.profile.isPremium)
                      TextButton(
                        onPressed: () => _showPremiumUpgrade(),
                        child: const Text('업그레이드'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: _saveProfile, child: const Text('저장')),
      ],
    );
  }

  void _saveProfile() {
    final updatedProfile = widget.profile.copyWith(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      bio: _bioController.text.trim(),
      timezone: _timezoneController.text.trim(),
      language: _languageController.text.trim(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(updatedProfile);
  }

  void _showTimezonePicker() {
    final timezones = [
      'Asia/Seoul',
      'Asia/Tokyo',
      'America/New_York',
      'America/Los_Angeles',
      'Europe/London',
      'Europe/Paris',
      'Australia/Sydney',
    ];

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('타임존 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: timezones.length,
            itemBuilder: (context, index) {
              final timezone = timezones[index];
              return ListTile(
                title: Text(timezone),
                selected: timezone == _timezoneController.text,
                onTap: () {
                  setState(() {
                    _timezoneController.text = timezone;
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    final languages = [
      {'code': 'ko', 'name': '한국어'},
      {'code': 'en', 'name': 'English'},
      {'code': 'ja', 'name': '日本語'},
    ];

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('언어 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];
              return ListTile(
                title: Text(language['name']!),
                selected: language['code'] == _languageController.text,
                onTap: () {
                  setState(() {
                    _languageController.text = language['code']!;
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPremiumUpgrade() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프리미엄 업그레이드'),
        content: const Text(
          '프리미엄 기능을 사용하려면 업그레이드가 필요합니다.\n\n'
          '프리미엄 기능:\n'
          '• 무제한 일기 작성\n'
          '• 고급 통계 분석\n'
          '• 클라우드 백업\n'
          '• 광고 제거',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 프리미엄 업그레이드 로직 - 구독 화면으로 이동
              context.go('/settings/subscription');
            },
            child: const Text('업그레이드'),
          ),
        ],
      ),
    );
  }
}
