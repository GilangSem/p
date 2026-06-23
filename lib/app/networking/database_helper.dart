import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // The name of the database file stored on the device.
  static const String _dbName = 'budget.db';

  // The current schema version. Increment this when you change the table structure.
  static const int _dbVersion = 1;

  // The name of the table that stores transactions.
  static const String tableTransactions = 'transactions';

  // ── Singleton setup ──────────────────────────────────────────────────────

  // Private constructor prevents direct instantiation from outside this class.
  DatabaseHelper._internal();

  // The single shared instance. Created once, reused everywhere.
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // The database connection. Null until first access.
  static Database? _database;

  // Returns the open database. Opens it on the first call; reuses it after.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // ── Initialization ───────────────────────────────────────────────────────

  // Resolves the full file path and opens (or creates) the database.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  // Called by sqflite the very first time the database file is created.
  // This is where you define your table schema.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        title   TEXT    NOT NULL,
        amount  REAL    NOT NULL,
        type    TEXT    NOT NULL,
        date    TEXT    NOT NULL
      )
    ''');
  }
}
