import 'package:sqflite/sqflite.dart';

import '../models/regression_sample.dart';
import 'database_service.dart';

class RegressionSampleRepository {
  RegressionSampleRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  final DatabaseService _databaseService;

  Future<List<RegressionSample>> fetchSamples({
    int? limit,
    String? group,
    int? minPriority,
  }) async {
    final db = await _databaseService.database;
    final where = <String>[];
    final args = <Object?>[];

    if (group != null) {
      where.add('(sample_group = ? OR sample_group IS NULL)');
      args.add(group);
    }
    if (minPriority != null) {
      where.add('priority >= ?');
      args.add(minPriority);
    }

    final rows = await db.query(
      'regression_samples',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'priority DESC, updated_at ASC',
      limit: limit,
    );

    return rows.map(RegressionSample.fromDb).toList();
  }

  Future<int> upsertSample(RegressionSample sample) async {
    final db = await _databaseService.database;
    return db.insert(
      'regression_samples',
      sample.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> touchSample(int id) async {
    final db = await _databaseService.database;
    await db.update(
      'regression_samples',
      {'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSample(int id) async {
    final db = await _databaseService.database;
    await db.delete('regression_samples', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countSamples({String? group}) async {
    final db = await _databaseService.database;
    final where = <String>[];
    final args = <Object?>[];

    if (group != null) {
      where.add('sample_group = ?');
      args.add(group);
    }

    final rows = await db.rawQuery(
      'SELECT COUNT(*) as count FROM regression_samples'
      '${where.isEmpty ? '' : ' WHERE ${where.join(' AND ')}'}',
      args,
    );

    return (rows.first['count'] as int?) ?? 0;
  }
}
