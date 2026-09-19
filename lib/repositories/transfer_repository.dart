import '../database/app_database.dart';
import '../models/transfer.dart';
import '../models/transfer_item.dart';

class TransferRepository {
  /// يحفظ التحويل وأصنافه في عملية واحدة ويعيد المعرّف.
  Future<int> insert(Transfer transfer) async {
    final db = await AppDatabase.instance.database;
    return db.transaction<int>((txn) async {
      final id = await txn.insert('transfers', transfer.toMap());
      final batch = txn.batch();
      for (final item in transfer.items) {
        batch.insert('transfer_items', item.toMap(id));
      }
      await batch.commit(noResult: true);
      return id;
    });
  }

  /// قائمة التحويلات (الأحدث أولًا) مع عدد الأصناف فقط.
  Future<List<Transfer>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT t.*,
             (SELECT COUNT(*) FROM transfer_items i WHERE i.transfer_id = t.id)
               AS items_count
      FROM transfers t
      ORDER BY t.id DESC
    ''');
    return rows.map((r) => Transfer.fromMap(r)).toList();
  }

  /// تحويل كامل مع أصنافه.
  Future<Transfer?> getById(int id) async {
    final db = await AppDatabase.instance.database;
    final rows =
        await db.query('transfers', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    final itemRows = await db.query('transfer_items',
        where: 'transfer_id = ?', whereArgs: [id], orderBy: 'id ASC');
    final items = itemRows.map(TransferItem.fromMap).toList();
    return Transfer.fromMap(rows.first, items: items);
  }
}
