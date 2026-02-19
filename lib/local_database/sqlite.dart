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
      version: 3, // 🔼 Updated version number
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE lead_category (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE visit_type (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE cmt_type (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE expense_type (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE roles (
            id TEXT PRIMARY KEY,
            role TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE task_type (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE task_status (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT
          )
        ''');
      },
      // 🔼 Added onUpgrade to handle existing DBs
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE expense_type (
              id TEXT PRIMARY KEY,
              value TEXT,
              categories TEXT
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
          CREATE TABLE task_type (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE task_status (
            id TEXT PRIMARY KEY,
            value TEXT,
            categories TEXT
          )
        ''');
          await db.execute('''
          CREATE TABLE grades (
            id TEXT PRIMARY KEY,
            grade TEXT
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

  static Future<void> insertTaskType(List<Map<String, String>> leadList) async {
    final db = _db;
    if (db == null) return;
    await db.delete('task_type');
    Batch batch = db.batch();
    for (var item in leadList) {
      batch.insert('task_type', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertTaskStatus(List<Map<String, String>> leadList) async {
    final db = _db;
    if (db == null) return;
    await db.delete('task_status');
    Batch batch = db.batch();
    for (var item in leadList) {
      batch.insert('task_status', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertExpenseType(List<Map<String, String>> leadList) async {
    final db = _db;
    if (db == null) return;
    await db.delete('expense_type');
    Batch batch = db.batch();
    for (var item in leadList) {
      batch.insert('expense_type', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertLeadCategory(List<Map<String, String>> leadList) async {
    final db = _db;
    if (db == null) return;
    await db.delete('lead_category');
    Batch batch = db.batch();
    for (var item in leadList) {
      batch.insert('lead_category', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertVisitType(List<Map<String, String>> visitList) async {
    final db = _db;
    if (db == null) return;
    await db.delete('visit_type');
    Batch batch = db.batch();
    for (var item in visitList) {
      batch.insert('visit_type', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertCmtType(List<Map<String, String>> visitList) async {
    final db = _db;
    if (db == null) return;
    await db.delete('cmt_type');
    Batch batch = db.batch();
    for (var item in visitList) {
      batch.insert('cmt_type', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> insertRole(List<Map<String, String>> visitList) async {
    final db = _db;
    if (db == null) return;
    await db.delete('roles');
    Batch batch = db.batch();
    for (var item in visitList) {
      batch.insert('roles', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
static Future<void> insertGrade(List<Map<String, String>> visitList) async {
    final db = _db;
    if (db == null) return;
    await db.delete('grades');
    Batch batch = db.batch();
    for (var item in visitList) {
      batch.insert('grades', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, String>>> getTaskStatus() async {
    final db = await database;
    final List<Map<String, Object?>> result = await db.query('task_status');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  static Future<List<Map<String, String>>> getTaskTypes() async {
    final db = await database;
    final List<Map<String, Object?>> result = await db.query('task_type');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  static Future<List<Map<String, String>>> getExpenseTypes() async {
    final db = await database;
    final List<Map<String, Object?>> result = await db.query('expense_type');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  static Future<List<Map<String, String>>> getLeadCategories() async {
    final db = await database;
    final List<Map<String, Object?>> result = await db.query('lead_category');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  static Future<List<Map<String, String>>> getVisitTypes() async {
    final db = await database;
    final List<Map<String, Object?>> result = await db.query('visit_type');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  static Future<List<Map<String, String>>> getCmtTypes() async {
    final db = await database;
    final List<Map<String, Object?>> result = await db.query('cmt_type');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }

  static Future<List<Map<String, String>>> getRoles() async {
    final db = await database;
    final List<Map<String, Object?>> result = await db.query('roles');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }
static Future<List<Map<String, String>>> getGrades() async {
    final db = await database;
    final List<Map<String, Object?>> result = await db.query('grades');
    return result.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList();
  }
  static Future<void> deleteTaskTypeById(String id) async {
    final db = _db;
    if (db == null) return;

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
