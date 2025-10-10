import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/attachment.dart';
import '../models/diary_entry.dart';

class ThumbnailCacheEntry {
  const ThumbnailCacheEntry({
    required this.cacheKey,
    required this.filePath,
    required this.fileSize,
    required this.createdAt,
    required this.lastAccessed,
    required this.isPlaceholder,
    required this.accessCount,
  });

  final String cacheKey;
  final String filePath;
  final int fileSize;
  final DateTime createdAt;
  final DateTime lastAccessed;
  final bool isPlaceholder;
  final int accessCount;

  ThumbnailCacheEntry copyWith({
    String? filePath,
    int? fileSize,
    DateTime? createdAt,
    DateTime? lastAccessed,
    bool? isPlaceholder,
    int? accessCount,
  }) {
    return ThumbnailCacheEntry(
      cacheKey: cacheKey,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      isPlaceholder: isPlaceholder ?? this.isPlaceholder,
      accessCount: accessCount ?? this.accessCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'cache_key': cacheKey,
    'file_path': filePath,
    'file_size': fileSize,
    'created_at': createdAt.toIso8601String(),
    'last_accessed': lastAccessed.toIso8601String(),
    'is_placeholder': isPlaceholder,
    'access_count': accessCount,
  };

  factory ThumbnailCacheEntry.fromJson(Map<String, dynamic> json) {
    return ThumbnailCacheEntry(
      cacheKey: json['cache_key'] as String,
      filePath: json['file_path'] as String,
      fileSize: json['file_size'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastAccessed: DateTime.parse(json['last_accessed'] as String),
      isPlaceholder: json['is_placeholder'] as bool? ?? false,
      accessCount: json['access_count'] as int? ?? 0,
    );
  }
}

class ThumbnailCacheService {
  ThumbnailCacheService._internal();

  static final ThumbnailCacheService _instance =
      ThumbnailCacheService._internal();

  factory ThumbnailCacheService() => _instance;

  bool _isInitialized = false;
  late Directory _cacheDirectory;
  late File _indexFile;
  final Map<String, ThumbnailCacheEntry> _entries = {};

  static const int _maxEntries = 200;
  static const int _maxCacheSizeBytes = 50 * 1024 * 1024; // 50MB
  static const int _thumbnailWidth = 320;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final documentsDir = await getApplicationDocumentsDirectory();
    _cacheDirectory = Directory(p.join(documentsDir.path, 'thumbnail_cache'));
    if (!await _cacheDirectory.exists()) {
      await _cacheDirectory.create(recursive: true);
    }

    _indexFile = File(p.join(_cacheDirectory.path, 'index.json'));
    await _loadIndex();

    _isInitialized = true;
  }

  Future<void> _loadIndex() async {
    if (!await _indexFile.exists()) {
      await _indexFile.writeAsString(jsonEncode([]));
      return;
    }

    try {
      final raw = await _indexFile.readAsString();
      final data = jsonDecode(raw) as List<dynamic>;
      _entries.clear();
      for (final item in data) {
        final entry = ThumbnailCacheEntry.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
        _entries[entry.cacheKey] = entry;
      }
    } catch (_) {
      _entries.clear();
    }
  }

  Future<void> _saveIndex() async {
    final data = _entries.values
        .map((entry) => entry.toJson())
        .toList(growable: false);
    await _indexFile.writeAsString(jsonEncode(data));
  }

  Future<void> _touchEntry(ThumbnailCacheEntry entry) async {
    final updated = entry.copyWith(
      lastAccessed: DateTime.now(),
      accessCount: entry.accessCount + 1,
    );
    _entries[entry.cacheKey] = updated;
    await _saveIndex();
  }

  String _cacheFileForKey(String cacheKey) {
    return p.join(
      _cacheDirectory.path,
      '${cacheKey.hashCode.abs()}_$cacheKey.png',
    );
  }

  Future<void> _enforceLimits() async {
    int totalSize = 0;
    final entries = _entries.values.toList()
      ..sort((a, b) => b.lastAccessed.compareTo(a.lastAccessed));

    for (final entry in entries) {
      totalSize += entry.fileSize;
    }

    if (_entries.length <= _maxEntries && totalSize <= _maxCacheSizeBytes) {
      return;
    }

    final sortedByOldest = _entries.values.toList()
      ..sort((a, b) => a.lastAccessed.compareTo(b.lastAccessed));

    while (_entries.length > _maxEntries || totalSize > _maxCacheSizeBytes) {
      if (sortedByOldest.isEmpty) break;
      final entry = sortedByOldest.removeAt(0);
      final file = File(entry.filePath);
      if (await file.exists()) {
        totalSize -= await file.length();
        await file.delete();
      }
      _entries.remove(entry.cacheKey);
    }

    await _saveIndex();
  }

  String _buildCacheKeyFromAttachment(
    Attachment attachment, {
    DiaryEntry? diary,
  }) {
    if (attachment.id != null) {
      return 'attachment_${attachment.id}';
    }
    if (diary?.id != null) {
      return 'diary_${diary!.id}';
    }
    final hashBase =
        '${diary?.date ?? ''}_${attachment.filePath}_${diary?.title ?? ''}';
    return 'temp_${hashBase.hashCode.abs()}';
  }

  Future<String?> resolveForAttachment(
    Attachment attachment, {
    DiaryEntry? diary,
  }) async {
    await initialize();

    final cacheKey = _buildCacheKeyFromAttachment(attachment, diary: diary);
    final file = File(attachment.filePath);
    if (await file.exists()) {
      return ensureThumbnail(
        cacheKey: cacheKey,
        sourcePath: attachment.filePath,
        diary: diary,
      );
    }

    return getPlaceholder(cacheKey: cacheKey, diary: diary);
  }

  Future<String?> ensureThumbnail({
    required String cacheKey,
    required String sourcePath,
    DiaryEntry? diary,
  }) async {
    await initialize();

    final existing = _entries[cacheKey];
    if (existing != null) {
      final cachedFile = File(existing.filePath);
      if (!existing.isPlaceholder && await cachedFile.exists()) {
        await _touchEntry(existing);
        return existing.filePath;
      }
      if (existing.isPlaceholder && await cachedFile.exists()) {
        await cachedFile.delete();
      }
      _entries.remove(cacheKey);
    }

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      return getPlaceholder(cacheKey: cacheKey, diary: diary);
    }

    try {
      final bytes = await sourceFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        return getPlaceholder(cacheKey: cacheKey, diary: diary);
      }

      final resized = img.copyResize(
        originalImage,
        width: _thumbnailWidth,
        interpolation: img.Interpolation.average,
      );

      final cachePath = _cacheFileForKey(cacheKey);
      final cacheFile = File(cachePath);
      await cacheFile.writeAsBytes(img.encodePng(resized), flush: true);
      final fileSize = await cacheFile.length();

      final entry = ThumbnailCacheEntry(
        cacheKey: cacheKey,
        filePath: cachePath,
        fileSize: fileSize,
        createdAt: DateTime.now(),
        lastAccessed: DateTime.now(),
        isPlaceholder: false,
        accessCount: 1,
      );

      _entries[cacheKey] = entry;
      await _saveIndex();
      await _enforceLimits();

      return cachePath;
    } catch (_) {
      return getPlaceholder(cacheKey: cacheKey, diary: diary);
    }
  }

  Future<String> getPlaceholder({
    required String cacheKey,
    DiaryEntry? diary,
  }) async {
    await initialize();

    final existing = _entries[cacheKey];
    if (existing != null) {
      final file = File(existing.filePath);
      if (await file.exists()) {
        await _touchEntry(existing);
        return existing.filePath;
      }
      _entries.remove(cacheKey);
    }

    final placeholderPath = _cacheFileForKey('${cacheKey}_placeholder');

    final baseColor = _colorFromDiary(diary);
    final accentColor = _accentColorFromColor(baseColor);

    final image = img.Image(width: _thumbnailWidth, height: _thumbnailWidth);
    _fillImage(image, baseColor);
    _drawDiagonalGradient(image, baseColor, accentColor);

    await File(placeholderPath).writeAsBytes(img.encodePng(image), flush: true);
    final fileSize = await File(placeholderPath).length();

    final entry = ThumbnailCacheEntry(
      cacheKey: cacheKey,
      filePath: placeholderPath,
      fileSize: fileSize,
      createdAt: DateTime.now(),
      lastAccessed: DateTime.now(),
      isPlaceholder: true,
      accessCount: 1,
    );

    _entries[cacheKey] = entry;
    await _saveIndex();
    await _enforceLimits();

    return placeholderPath;
  }

  Future<void> invalidate(String cacheKey) async {
    await initialize();
    final entry = _entries.remove(cacheKey);
    if (entry != null) {
      final file = File(entry.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      await _saveIndex();
    }
  }

  ({int r, int g, int b}) _colorFromDiary(DiaryEntry? diary) {
    final baseString = [
      diary?.mood,
      diary?.weather,
      diary?.title,
      diary?.content,
      diary?.date,
    ].whereType<String>().join('|');

    final hash = baseString.isEmpty
        ? DateTime.now().millisecondsSinceEpoch
        : baseString.hashCode;
    final red = (hash & 0xFF0000) >> 16;
    final green = (hash & 0x00FF00) >> 8;
    final blue = hash & 0x0000FF;

    return (
      r: _clampChannel(red),
      g: _clampChannel(green),
      b: _clampChannel(blue),
    );
  }

  ({int r, int g, int b}) _accentColorFromColor(({int r, int g, int b}) color) {
    final mix = (color.r + color.g + color.b) / 3;
    final accent = (mix > 128) ? mix - 60 : mix + 60;
    final clamp = _clampChannel(accent);

    return (
      r: clamp,
      g: _clampChannel(clamp * 0.8),
      b: _clampChannel(clamp * 0.6),
    );
  }

  void _fillImage(img.Image image, ({int r, int g, int b}) color) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        image.setPixelRgba(x, y, color.r, color.g, color.b, 255);
      }
    }
  }

  void _drawDiagonalGradient(
    img.Image image,
    ({int r, int g, int b}) base,
    ({int r, int g, int b}) accent,
  ) {
    final blended = _blendColors(base, accent);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        if ((x + y) % 40 < 20) {
          image.setPixelRgba(x, y, blended.r, blended.g, blended.b, 255);
        }
      }
    }
  }

  ({int r, int g, int b}) _blendColors(
    ({int r, int g, int b}) base,
    ({int r, int g, int b}) overlay,
  ) {
    return (
      r: _clampChannel((base.r + overlay.r) / 2),
      g: _clampChannel((base.g + overlay.g) / 2),
      b: _clampChannel((base.b + overlay.b) / 2),
    );
  }

  int _clampChannel(num value) {
    final rounded = value.round();
    if (rounded < 0) {
      return 0;
    }
    if (rounded > 255) {
      return 255;
    }
    return rounded;
  }
}
