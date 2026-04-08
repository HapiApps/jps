import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _db;

  static Future<void> initDb() async {
    if (_db != null) return;

    String path = join(await getDatabasesPath(), 'ACI.db');

    _db = await openDatabase(
      path,
      version: 6, // ✅ Version increase whenever new table/column added
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS lead_category (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS visit_type (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS cmt_type (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS expense_type (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS roles (
            id TEXT PRIMARY KEY,
            role TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS task_type (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT,
            created_ts TEXT,
            created_by TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS cus_type (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT,
            created_ts TEXT,
            created_by TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS task_status (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS grades (
            id TEXT PRIMARY KEY,
            grade TEXT
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        log("Upgrading DB from $oldVersion to $newVersion");

        /// ✅ oldVersion < 4
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS expense_type (
              id TEXT PRIMARY KEY,
              value TEXT,
              categories TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS task_type (
              id TEXT PRIMARY KEY,
              value TEXT,
              categories TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS task_status (
              id TEXT PRIMARY KEY,
              value TEXT,
              categories TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS grades (
              id TEXT PRIMARY KEY,
              grade TEXT
            )
          ''');
        }

        /// ✅ oldVersion < 5 (task_type new columns)
        if (oldVersion < 5) {
          try {
            await db.execute("ALTER TABLE task_type ADD COLUMN created_ts TEXT");
          } catch (e) {
            log("created_ts already exists");
          }

          try {
            await db.execute("ALTER TABLE task_type ADD COLUMN created_by TEXT");
          } catch (e) {
            log("created_by already exists");
          }
        }

        /// ✅ oldVersion < 6 (cus_type table)
        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS cus_type (
              id TEXT PRIMARY KEY,
              value TEXT,
              categories TEXT,
              created_ts TEXT,
              created_by TEXT
            )
          ''');
        }
      },
    );
  }

  static Future<Database> get database async {
    if (_db != null) return _db!;
    await initDb();
    return _db!;
  }

  /// ===================== INSERT FUNCTIONS =====================

  static Future<void> insertTaskType(List<Map<String, String>> leadList) async {
    final db = await database;
    await db.delete('task_type');

    Batch batch = db.batch();
    for (var item in leadList) {
      batch.insert(
        'task_type',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertCusType(List<Map<String, String>> leadList) async {
    final db = await database;
    await db.delete('cus_type');

    Batch batch = db.batch();
    for (var item in leadList) {
      batch.insert(
        'cus_type',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertTaskStatus(List<Map<String, String>> leadList) async {
    final db = await database;
    await db.delete('task_status');

    Batch batch = db.batch();
    for (var item in leadList) {
      batch.insert(
        'task_status',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertExpenseType(List<Map<String, String>> leadList) async {
    final db = await database;
    await db.delete('expense_type');

    Batch batch = db.batch();
    for (var item in leadList) {
      batch.insert(
        'expense_type',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertLeadCategory(List<Map<String, String>> leadList) async {
    final db = await database;
    await db.delete('lead_category');

    Batch batch = db.batch();
    for (var item in leadList) {
      batch.insert(
        'lead_category',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertVisitType(List<Map<String, String>> visitList) async {
    final db = await database;
    await db.delete('visit_type');

    Batch batch = db.batch();
    for (var item in visitList) {
      batch.insert(
        'visit_type',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertCmtType(List<Map<String, String>> visitList) async {
    final db = await database;
    await db.delete('cmt_type');

    Batch batch = db.batch();
    for (var item in visitList) {
      batch.insert(
        'cmt_type',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertRole(List<Map<String, String>> visitList) async {
    final db = await database;
    await db.delete('roles');

    Batch batch = db.batch();
    for (var item in visitList) {
      batch.insert(
        'roles',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertGrade(List<Map<String, String>> visitList) async {
    final db = await database;
    await db.delete('grades');

    Batch batch = db.batch();
    for (var item in visitList) {
      batch.insert(
        'grades',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// ===================== GET FUNCTIONS =====================

  static Future<List<Map<String, String>>> getTaskStatus() async {
    final db = await database;
    final result = await db.query('task_status');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  static Future<List<Map<String, String>>> getTaskTypes() async {
    final db = await database;
    final result = await db.query('task_type');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  static Future<List<Map<String, String>>> getExpenseTypes() async {
    final db = await database;
    final result = await db.query('expense_type');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  static Future<List<Map<String, String>>> getLeadCategories() async {
    final db = await database;
    final result = await db.query('lead_category');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  static Future<List<Map<String, String>>> getVisitTypes() async {
    final db = await database;
    final result = await db.query('visit_type');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  static Future<List<Map<String, String>>> getCmtTypes() async {
    final db = await database;
    final result = await db.query('cmt_type');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  static Future<List<Map<String, String>>> getCusTypes() async {
    final db = await database;
    final result = await db.query('cus_type');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  static Future<List<Map<String, String>>> getRoles() async {
    final db = await database;
    final result = await db.query('roles');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  static Future<List<Map<String, String>>> getGrades() async {
    final db = await database;
    final result = await db.query('grades');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  /// ===================== DELETE FUNCTIONS =====================

  static Future<void> deleteTaskTypeById(String id) async {
    final db = await database;
    await db.delete(
      'task_type',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteDb() async {
    String path = join(await getDatabasesPath(), 'ACI.db');
    await deleteDatabase(path);
    _db = null;
    log("Database deleted successfully");
  }
}