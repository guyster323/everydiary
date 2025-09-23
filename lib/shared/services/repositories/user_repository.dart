import '../../models/user.dart';
import '../database_service.dart';

/// 사용자 리포지토리
class UserRepository {
  final DatabaseService _databaseService;

  UserRepository(this._databaseService);

  /// 사용자 생성
  Future<User> createUser(CreateUserDto dto) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toIso8601String();

    final id = await db.insert('users', {
      'email': dto.email,
      'name': dto.name,
      'created_at': now,
      'updated_at': now,
      'is_deleted': 0,
    });

    return User(
      id: id,
      email: dto.email,
      name: dto.name,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 사용자 조회 (ID로)
  Future<User?> getUserById(int id) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'users',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  /// 사용자 조회 (이메일로)
  Future<User?> getUserByEmail(String email) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND is_deleted = 0',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  /// 모든 사용자 조회
  Future<List<User>> getAllUsers() async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'users',
      where: 'is_deleted = 0',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => User.fromJson(map)).toList();
  }

  /// 사용자 업데이트
  Future<User?> updateUser(int id, UpdateUserDto dto) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toIso8601String();

    final updateData = <String, dynamic>{'updated_at': now};

    if (dto.email != null) updateData['email'] = dto.email;
    if (dto.name != null) updateData['name'] = dto.name;

    final rowsAffected = await db.update(
      'users',
      updateData,
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (rowsAffected > 0) {
      return await getUserById(id);
    }
    return null;
  }

  /// 사용자 삭제 (소프트 삭제)
  Future<bool> deleteUser(int id) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toIso8601String();

    final rowsAffected = await db.update(
      'users',
      {'is_deleted': 1, 'updated_at': now},
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    return rowsAffected > 0;
  }

  /// 사용자 완전 삭제
  Future<bool> permanentlyDeleteUser(int id) async {
    final db = await _databaseService.database;

    final rowsAffected = await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    return rowsAffected > 0;
  }

  /// 사용자 존재 여부 확인
  Future<bool> userExists(int id) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM users WHERE id = ? AND is_deleted = 0',
      [id],
    );

    return result.first['count'] as int > 0;
  }

  /// 사용자 수 조회
  Future<int> getUserCount() async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM users WHERE is_deleted = 0',
    );

    return result.first['count'] as int;
  }
}
