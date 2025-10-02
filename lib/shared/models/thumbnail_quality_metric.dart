import 'dart:convert';

class ThumbnailQualityMetric {
  const ThumbnailQualityMetric({
    required this.id,
    required this.logId,
    required this.metricType,
    this.value,
    this.details,
    required this.createdAt,
  });

  final int id;
  final int logId;
  final String metricType;
  final double? value;
  final Map<String, dynamic>? details;
  final DateTime createdAt;

  static ThumbnailQualityMetric fromDb(Map<String, Object?> row) {
    return ThumbnailQualityMetric(
      id: row['id'] as int,
      logId: row['log_id'] as int,
      metricType: row['metric_type'] as String,
      value: (row['value'] as num?)?.toDouble(),
      details: _decodeJson(row['details'] as String?),
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  static Map<String, dynamic>? _decodeJson(String? value) {
    if (value == null) {
      return null;
    }
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
