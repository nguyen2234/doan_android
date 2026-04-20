import '../database/database_helper.dart';
import '../models/user.dart';

class UserDao {
  final db = DatabaseHelper.instance;

  Future<int> insert(User user) async {
    final database = await db.database;
    return await database.insert('users', user.toMap());
  }

  Future<User?> getByEmail(String email) async {
    final database = await db.database;
    final result = await database.query('users', where: 'email = ?', whereArgs: [email]);
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<User?> getById(int id) async {
    final database = await db.database;
    final result = await database.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<int> update(User user) async {
    final database = await db.database;
    return await database.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<User?> login(String email, String password) async {
    final database = await db.database;
    final result = await database.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }
}
