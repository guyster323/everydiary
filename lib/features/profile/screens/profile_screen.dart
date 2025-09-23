import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/animations/animations.dart';
import '../../../core/layout/responsive_widgets.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_edit_dialog.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_image_picker.dart';
import '../widgets/profile_stats_card.dart';

/// 프로필 화면
/// 사용자의 프로필 정보를 표시하고 관리할 수 있는 화면입니다.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final profileStats = ref.watch(profileStatsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: '프로필',
        actions: [
          IconButton(
            onPressed: () => _showEditDialog(),
            icon: const Icon(Icons.edit),
            tooltip: '프로필 편집',
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(profileProvider.notifier).refreshProfile();
            await ref.read(profileStatsProvider.notifier).refreshStats();
          },
          child: ScrollAnimations.scrollReveal(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 프로필 헤더
                ProfileHeader(
                  profile: profile,
                  onImageTap: () => _showImagePicker(),
                  onEditTap: () => _showEditDialog(),
                ),

                const SizedBox(height: 24),

                // 통계 카드들
                ProfileStatsCard(
                  title: '일기 통계',
                  stats: [
                    StatItem(
                      label: '총 일기 수',
                      value: '${profileStats.totalDiaries}개',
                      icon: Icons.book_outlined,
                    ),
                    StatItem(
                      label: '연속 작성일',
                      value: '${profileStats.consecutiveDays}일',
                      icon: Icons.local_fire_department,
                    ),
                    StatItem(
                      label: '총 단어 수',
                      value: '${profileStats.totalWords}개',
                      icon: Icons.text_fields,
                    ),
                    StatItem(
                      label: '총 글자 수',
                      value: '${profileStats.totalCharacters}자',
                      icon: Icons.abc,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                ProfileStatsCard(
                  title: '이번 달 활동',
                  stats: [
                    StatItem(
                      label: '이번 달 일기',
                      value: '${profileStats.thisMonthDiaries}개',
                      icon: Icons.calendar_month,
                    ),
                    StatItem(
                      label: '이번 주 일기',
                      value: '${profileStats.thisWeekDiaries}개',
                      icon: Icons.date_range,
                    ),
                    StatItem(
                      label: '최장 연속일',
                      value: '${profileStats.longestStreak}일',
                      icon: Icons.trending_up,
                    ),
                    StatItem(
                      label: '평균 단어 수',
                      value: '${profileStats.averageWordsPerDiary}개',
                      icon: Icons.analytics,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 활동 기간 정보
                ProfileStatsCard(
                  title: '활동 기간',
                  stats: [
                    StatItem(
                      label: '첫 일기',
                      value: _formatDate(profileStats.firstDiaryDate),
                      icon: Icons.start,
                    ),
                    StatItem(
                      label: '최근 일기',
                      value: _formatDate(profileStats.lastDiaryDate),
                      icon: Icons.update,
                    ),
                    StatItem(
                      label: '활동 기간',
                      value: _calculateActivityPeriod(
                        profileStats.firstDiaryDate,
                        profileStats.lastDiaryDate,
                      ),
                      icon: Icons.schedule,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 자주 사용하는 태그
                if (profileStats.mostUsedTags.isNotEmpty)
                  ProfileStatsCard(
                    title: '자주 사용하는 태그',
                    stats: profileStats.mostUsedTags.take(6).map((tag) {
                      return StatItem(label: tag, value: '', icon: Icons.tag);
                    }).toList(),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '없음';
    }
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _calculateActivityPeriod(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return '0일';
    }
    final difference = end.difference(start).inDays;
    if (difference < 30) {
      return '$difference일';
    } else if (difference < 365) {
      return '${(difference / 30).floor()}개월';
    } else {
      return '${(difference / 365).floor()}년';
    }
  }

  void _showImagePicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => ProfileImagePicker(
        onCameraTap: () => _pickImage(ImageSource.camera),
        onGalleryTap: () => _pickImage(ImageSource.gallery),
        onRemoveTap: () => _removeImage(),
      ),
    );
  }

  void _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await ref.read(profileProvider.notifier).updateProfileImage(image.path);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('프로필 이미지가 업데이트되었습니다')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이미지 업로드 실패: $e')));
      }
    }
  }

  void _removeImage() async {
    try {
      await ref.read(profileProvider.notifier).removeProfileImage();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('프로필 이미지가 제거되었습니다')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이미지 제거 실패: $e')));
      }
    }
  }

  void _showEditDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => ProfileEditDialog(
        profile: ref.read(profileProvider),
        onSave: (updatedProfile) async {
          final navigator = Navigator.of(context);
          final scaffoldMessenger = ScaffoldMessenger.of(context);

          try {
            await ref
                .read(profileProvider.notifier)
                .updateProfile(updatedProfile);
            if (mounted) {
              navigator.pop();
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('프로필이 업데이트되었습니다')),
              );
            }
          } catch (e) {
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('프로필 업데이트 실패: $e')),
              );
            }
          }
        },
      ),
    );
  }
}

/// 통계 항목 모델
class StatItem {
  final String label;
  final String value;
  final IconData icon;

  const StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}
