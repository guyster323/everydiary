import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 오프라인 이미지 정보 모델
class OfflineImageInfo {
  final String id;
  final String fileName;
  final String filePath;
  final String category;
  final String style;
  final String emotion;
  final String topic;
  final int fileSize;
  final DateTime createdAt;
  final DateTime lastAccessed;
  final int accessCount;
  final bool isDefault;
  final Map<String, dynamic> metadata;

  const OfflineImageInfo({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.category,
    required this.style,
    required this.emotion,
    required this.topic,
    required this.fileSize,
    required this.createdAt,
    required this.lastAccessed,
    required this.accessCount,
    this.isDefault = false,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'file_name': fileName,
    'file_path': filePath,
    'category': category,
    'style': style,
    'emotion': emotion,
    'topic': topic,
    'file_size': fileSize,
    'created_at': createdAt.toIso8601String(),
    'last_accessed': lastAccessed.toIso8601String(),
    'access_count': accessCount,
    'is_default': isDefault,
    'metadata': metadata,
  };

  factory OfflineImageInfo.fromJson(Map<String, dynamic> json) {
    return OfflineImageInfo(
      id: json['id'] as String,
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      category: json['category'] as String,
      style: json['style'] as String,
      emotion: json['emotion'] as String,
      topic: json['topic'] as String,
      fileSize: json['file_size'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastAccessed: DateTime.parse(json['last_accessed'] as String),
      accessCount: json['access_count'] as int,
      isDefault: json['is_default'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  OfflineImageInfo copyWith({
    String? id,
    String? fileName,
    String? filePath,
    String? category,
    String? style,
    String? emotion,
    String? topic,
    int? fileSize,
    DateTime? createdAt,
    DateTime? lastAccessed,
    int? accessCount,
    bool? isDefault,
    Map<String, dynamic>? metadata,
  }) {
    return OfflineImageInfo(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      category: category ?? this.category,
      style: style ?? this.style,
      emotion: emotion ?? this.emotion,
      topic: topic ?? this.topic,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      accessCount: accessCount ?? this.accessCount,
      isDefault: isDefault ?? this.isDefault,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 네트워크 상태 열거형
enum NetworkStatus {
  online('온라인'),
  offline('오프라인'),
  unknown('알 수 없음');

  const NetworkStatus(this.displayName);
  final String displayName;
}

/// 오프라인 모드 및 이미지 관리 서비스
/// 오프라인 상태에서 사용할 기본 배경 세트를 제공하고 생성된 이미지의 효율적인 저장 및 관리 시스템을 구현합니다.
class OfflineImageManagerService {
  static final OfflineImageManagerService _instance =
      OfflineImageManagerService._internal();
  factory OfflineImageManagerService() => _instance;
  OfflineImageManagerService._internal();

  bool _isInitialized = false;
  NetworkStatus _networkStatus = NetworkStatus.unknown;
  final List<OfflineImageInfo> _offlineImages = [];
  final List<OfflineImageInfo> _defaultImages = [];
  final Map<String, dynamic> _storageStats = {};
  final StreamController<NetworkStatus> _networkStatusController =
      StreamController<NetworkStatus>.broadcast();

  // 기본 이미지 카테고리
  static const List<String> _defaultCategories = [
    'nature',
    'abstract',
    'minimal',
    'vintage',
    'modern',
  ];

  // 기본 이미지 스타일
  static const List<String> _defaultStyles = [
    'realistic',
    'watercolor',
    'oil',
    'sketch',
    'digital',
  ];

  // 기본 감정
  static const List<String> _defaultEmotions = [
    'positive',
    'neutral',
    'negative',
    'calm',
    'energetic',
  ];

  // 기본 주제
  static const List<String> _defaultTopics = [
    'daily',
    'travel',
    'food',
    'emotion',
    'work',
  ];

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 오프라인 이미지 관리 서비스 초기화 시작');

      // 네트워크 상태 확인
      await _checkNetworkStatus();

      // 오프라인 이미지 목록 로드
      await _loadOfflineImages();

      // 기본 이미지 설정
      await _setupDefaultImages();

      // 저장소 통계 로드
      await _loadStorageStats();

      // 네트워크 상태 모니터링 시작
      _startNetworkMonitoring();

      _isInitialized = true;
      debugPrint('✅ 오프라인 이미지 관리 서비스 초기화 완료');
    } catch (e) {
      debugPrint('❌ 오프라인 이미지 관리 서비스 초기화 실패: $e');
    }
  }

  /// 네트워크 상태 확인
  Future<void> _checkNetworkStatus() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _networkStatus = _mapConnectivityToNetworkStatus(connectivityResult);
      _networkStatusController.add(_networkStatus);
      debugPrint('🌐 네트워크 상태: ${_networkStatus.displayName}');
    } catch (e) {
      debugPrint('❌ 네트워크 상태 확인 실패: $e');
      _networkStatus = NetworkStatus.unknown;
    }
  }

  /// Connectivity 결과를 NetworkStatus로 매핑
  NetworkStatus _mapConnectivityToNetworkStatus(
    List<ConnectivityResult> results,
  ) {
    if (results.isEmpty) return NetworkStatus.unknown;

    final result = results.first;
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return NetworkStatus.online;
      case ConnectivityResult.none:
        return NetworkStatus.offline;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.vpn:
      case ConnectivityResult.other:
        return NetworkStatus.unknown;
    }
  }

  /// 네트워크 상태 모니터링 시작
  void _startNetworkMonitoring() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final newStatus = _mapConnectivityToNetworkStatus(results);
      if (newStatus != _networkStatus) {
        _networkStatus = newStatus;
        _networkStatusController.add(_networkStatus);
        debugPrint('🌐 네트워크 상태 변경: ${_networkStatus.displayName}');
      }
    });
  }

  /// 기본 이미지 설정
  Future<void> _setupDefaultImages() async {
    try {
      if (_defaultImages.isNotEmpty) return;

      debugPrint('🖼️ 기본 이미지 설정 시작');

      for (final category in _defaultCategories) {
        for (final style in _defaultStyles) {
          for (final emotion in _defaultEmotions) {
            for (final topic in _defaultTopics) {
              final imageInfo = OfflineImageInfo(
                id: 'default_${category}_${style}_${emotion}_$topic',
                fileName: '${category}_${style}_${emotion}_$topic.jpg',
                filePath: await _getDefaultImagePath(
                  category,
                  style,
                  emotion,
                  topic,
                ),
                category: category,
                style: style,
                emotion: emotion,
                topic: topic,
                fileSize: 0, // 기본 이미지는 실제 파일이 없으므로 0
                createdAt: DateTime.now(),
                lastAccessed: DateTime.now(),
                accessCount: 0,
                isDefault: true,
                metadata: {'is_placeholder': true, 'generated': false},
              );

              _defaultImages.add(imageInfo);
            }
          }
        }
      }

      debugPrint('✅ 기본 이미지 설정 완료: ${_defaultImages.length}개');
    } catch (e) {
      debugPrint('❌ 기본 이미지 설정 실패: $e');
    }
  }

  /// 기본 이미지 경로 생성
  Future<String> _getDefaultImagePath(
    String category,
    String style,
    String emotion,
    String topic,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/default_images/${category}_${style}_${emotion}_$topic.jpg';
  }

  /// 오프라인 이미지 저장
  Future<String?> saveOfflineImage({
    required String imageUrl,
    required String category,
    required String style,
    required String emotion,
    required String topic,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      debugPrint('💾 오프라인 이미지 저장 시작');

      final imageId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
      final fileName = '$imageId.jpg';
      final filePath = await _getImageFilePath(fileName);

      // 이미지 다운로드 및 저장
      final imageData = await _downloadImage(imageUrl);
      if (imageData == null) {
        debugPrint('❌ 이미지 다운로드 실패');
        return null;
      }

      final file = File(filePath);
      await file.writeAsBytes(imageData);

      final imageInfo = OfflineImageInfo(
        id: imageId,
        fileName: fileName,
        filePath: filePath,
        category: category,
        style: style,
        emotion: emotion,
        topic: topic,
        fileSize: imageData.length,
        createdAt: DateTime.now(),
        lastAccessed: DateTime.now(),
        accessCount: 0,
        isDefault: false,
        metadata: metadata ?? {},
      );

      _offlineImages.add(imageInfo);
      await _saveOfflineImages();

      // 저장소 통계 업데이트
      await _updateStorageStats();

      debugPrint('✅ 오프라인 이미지 저장 완료: $imageId');
      return imageId;
    } catch (e) {
      debugPrint('❌ 오프라인 이미지 저장 실패: $e');
      return null;
    }
  }

  /// 이미지 다운로드
  Future<Uint8List?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint('❌ 이미지 다운로드 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ 이미지 다운로드 실패: $e');
      return null;
    }
  }

  /// 이미지 파일 경로 생성
  Future<String> _getImageFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${directory.path}/offline_images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return '${imageDir.path}/$fileName';
  }

  /// 오프라인 이미지 가져오기
  Future<OfflineImageInfo?> getOfflineImage(String imageId) async {
    try {
      final imageInfo = _offlineImages.firstWhere(
        (image) => image.id == imageId,
        orElse: () => _defaultImages.firstWhere(
          (image) => image.id == imageId,
          orElse: () => throw Exception('이미지를 찾을 수 없습니다'),
        ),
      );

      // 접근 시간 및 횟수 업데이트
      final updatedImageInfo = imageInfo.copyWith(
        lastAccessed: DateTime.now(),
        accessCount: imageInfo.accessCount + 1,
      );

      if (imageInfo.isDefault) {
        final index = _defaultImages.indexWhere((img) => img.id == imageId);
        if (index != -1) {
          _defaultImages[index] = updatedImageInfo;
        }
      } else {
        final index = _offlineImages.indexWhere((img) => img.id == imageId);
        if (index != -1) {
          _offlineImages[index] = updatedImageInfo;
          await _saveOfflineImages();
        }
      }

      return updatedImageInfo;
    } catch (e) {
      debugPrint('❌ 오프라인 이미지 가져오기 실패: $e');
      return null;
    }
  }

  /// 카테고리별 이미지 가져오기
  List<OfflineImageInfo> getImagesByCategory(String category) {
    return _offlineImages.where((image) => image.category == category).toList();
  }

  /// 스타일별 이미지 가져오기
  List<OfflineImageInfo> getImagesByStyle(String style) {
    return _offlineImages.where((image) => image.style == style).toList();
  }

  /// 감정별 이미지 가져오기
  List<OfflineImageInfo> getImagesByEmotion(String emotion) {
    return _offlineImages.where((image) => image.emotion == emotion).toList();
  }

  /// 주제별 이미지 가져오기
  List<OfflineImageInfo> getImagesByTopic(String topic) {
    return _offlineImages.where((image) => image.topic == topic).toList();
  }

  /// 사용하지 않는 이미지 정리
  Future<void> cleanupUnusedImages() async {
    try {
      debugPrint('🧹 사용하지 않는 이미지 정리 시작');

      final now = DateTime.now();
      final cutoffDate = now.subtract(
        const Duration(days: 30),
      ); // 30일 이상 사용하지 않은 이미지

      final imagesToRemove = _offlineImages.where((image) {
        return !image.isDefault &&
            image.lastAccessed.isBefore(cutoffDate) &&
            image.accessCount < 3; // 3회 미만 접근한 이미지
      }).toList();

      for (final image in imagesToRemove) {
        try {
          final file = File(image.filePath);
          if (await file.exists()) {
            await file.delete();
          }
          _offlineImages.remove(image);
        } catch (e) {
          debugPrint('❌ 이미지 삭제 실패: ${image.id} - $e');
        }
      }

      await _saveOfflineImages();
      await _updateStorageStats();

      debugPrint('✅ 사용하지 않는 이미지 정리 완료: ${imagesToRemove.length}개 삭제');
    } catch (e) {
      debugPrint('❌ 사용하지 않는 이미지 정리 실패: $e');
    }
  }

  /// 저장소 사용량 모니터링
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final offlineImageDir = Directory('${directory.path}/offline_images');

      int totalSize = 0;
      int fileCount = 0;

      if (await offlineImageDir.exists()) {
        await for (final entity in offlineImageDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
            fileCount++;
          }
        }
      }

      return {
        'total_size': totalSize,
        'file_count': fileCount,
        'average_size': fileCount > 0 ? totalSize / fileCount : 0,
        'last_cleanup': _storageStats['last_cleanup'],
        'cleanup_count': _storageStats['cleanup_count'] ?? 0,
      };
    } catch (e) {
      debugPrint('❌ 저장소 통계 가져오기 실패: $e');
      return {};
    }
  }

  /// 저장소 사용량 경고 확인
  Future<bool> checkStorageWarning() async {
    try {
      final stats = await getStorageStats();
      final totalSize = stats['total_size'] as int;
      const maxSize = 100 * 1024 * 1024; // 100MB

      return totalSize > maxSize;
    } catch (e) {
      debugPrint('❌ 저장소 경고 확인 실패: $e');
      return false;
    }
  }

  /// 오프라인 이미지 목록 로드
  Future<void> _loadOfflineImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagesJson = prefs.getString('offline_images');

      if (imagesJson != null) {
        final imagesList = jsonDecode(imagesJson) as List<dynamic>;
        _offlineImages.clear();
        _offlineImages.addAll(
          imagesList.map(
            (item) => OfflineImageInfo.fromJson(item as Map<String, dynamic>),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ 오프라인 이미지 목록 로드 실패: $e');
    }
  }

  /// 오프라인 이미지 목록 저장
  Future<void> _saveOfflineImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagesList = _offlineImages.map((image) => image.toJson()).toList();
      await prefs.setString('offline_images', jsonEncode(imagesList));
    } catch (e) {
      debugPrint('❌ 오프라인 이미지 목록 저장 실패: $e');
    }
  }

  /// 저장소 통계 로드
  Future<void> _loadStorageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('storage_stats');

      if (statsJson != null) {
        _storageStats.clear();
        _storageStats.addAll(jsonDecode(statsJson) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('❌ 저장소 통계 로드 실패: $e');
    }
  }

  /// 저장소 통계 저장
  Future<void> _saveStorageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('storage_stats', jsonEncode(_storageStats));
    } catch (e) {
      debugPrint('❌ 저장소 통계 저장 실패: $e');
    }
  }

  /// 저장소 통계 업데이트
  Future<void> _updateStorageStats() async {
    try {
      final stats = await getStorageStats();
      _storageStats.clear();
      _storageStats.addAll(stats);
      _storageStats['last_cleanup'] = DateTime.now().toIso8601String();
      _storageStats['cleanup_count'] =
          (_storageStats['cleanup_count'] ?? 0) + 1;
      await _saveStorageStats();
    } catch (e) {
      debugPrint('❌ 저장소 통계 업데이트 실패: $e');
    }
  }

  /// 현재 네트워크 상태 가져오기
  NetworkStatus get currentNetworkStatus => _networkStatus;

  /// 네트워크 상태 스트림 가져오기
  Stream<NetworkStatus> get networkStatusStream =>
      _networkStatusController.stream;

  /// 모든 오프라인 이미지 가져오기
  List<OfflineImageInfo> get allOfflineImages => List.from(_offlineImages);

  /// 모든 기본 이미지 가져오기
  List<OfflineImageInfo> get allDefaultImages => List.from(_defaultImages);

  /// 서비스 정리
  void dispose() {
    _networkStatusController.close();
    _offlineImages.clear();
    _defaultImages.clear();
    _storageStats.clear();
    _isInitialized = false;
    debugPrint('🗑️ 오프라인 이미지 관리 서비스 정리 완료');
  }
}
