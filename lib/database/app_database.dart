import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/constants/branches.dart';

/// قاعدة البيانات المحلية (SQLite). تُفتح مرة واحدة وتُعاد استخدامها.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Future<Database>? _opening;

  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'almegdaa.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE branches (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            sort_order INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE transfers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            from_branch TEXT NOT NULL,
            to_branch TEXT NOT NULL,
            transfer_date TEXT NOT NULL,
            employee_name TEXT NOT NULL,
            employee_phone TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE transfer_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transfer_id INTEGER NOT NULL,
            barcode TEXT NOT NULL,
            name TEXT,
            quantity INTEGER NOT NULL,
            expiry_date TEXT,
            FOREIGN KEY (transfer_id) REFERENCES transfers (id) ON DELETE CASCADE
          )
        ''');
        await db.execute(
            'CREATE INDEX idx_items_transfer ON transfer_items (transfer_id)');

        for (var i = 0; i < defaultBranchNames.length; i++) {
          await db.insert('branches', {
            'name': defaultBranchNames[i],
            'sort_order': i,
          });
        }
      },
    );
  }
}
