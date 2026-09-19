import '../database/app_database.dart';
import '../models/branch.dart';

class BranchRepository {
  Future<List<Branch>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('branches', orderBy: 'sort_order ASC, id ASC');
    return rows.map(Branch.fromMap).toList();
  }

  Future<void> add(String name) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery(
        'SELECT COALESCE(MAX(sort_order), -1) + 1 AS next_order FROM branches');
    final next = (rows.first['next_order'] as int?) ?? 0;
    await db.insert('branches', {'name': name, 'sort_order': next});
  }

  Future<void> rename(int id, String name) async {
    final db = await AppDatabase.instance.database;
    await db.update('branches', {'name': name},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('branches', where: 'id = ?', whereArgs: [id]);
  }
}
