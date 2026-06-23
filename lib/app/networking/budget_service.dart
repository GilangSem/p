import '/bootstrap/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/transaction.dart';
import '/app/networking/database_helper.dart';

class BudgetService extends NyApiService {
  BudgetService() : super(decoders: modelDecoders);

  // ── CREATE ─────────────────────────────────────────────────────────

  /// Inserts a new transaction into the database.
  /// Returns the auto-assigned integer id of the new row.
  Future<int> addTransaction(Transaction transaction) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(
      DatabaseHelper.tableTransactions,
      transaction.toMap(),
    );
  }

  // ── READ ──────────────────────────────────────────────────────────

  /// Returns all transactions, most recent date first.
  Future<List<Transaction>> fetchAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      DatabaseHelper.tableTransactions,
      orderBy: 'date DESC',
    );
    return rows.map((row) => Transaction.fromMap(row)).toList();
  }

  /// Returns a single transaction by id.
  /// Returns null if no transaction with that id exists.
  Future<Transaction?> fetchById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      DatabaseHelper.tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Transaction.fromMap(rows.first);
  }

  // ── UPDATE ─────────────────────────────────────────────────────────

  /// Updates an existing transaction.
  /// The transaction must have a non-null id.
  /// Returns the number of rows affected (1 if successful, 0 if not found).
  Future<int> updateTransaction(Transaction transaction) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      DatabaseHelper.tableTransactions,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // ── DELETE ─────────────────────────────────────────────────────────

  /// Deletes a transaction by id.
  /// Returns the number of rows deleted (1 if successful, 0 if not found).
  Future<int> deleteTransaction(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      DatabaseHelper.tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── SUMMARY ─────────────────────────────────────────────────────────

  /// Returns the total income across all transactions.
  Future<double> totalIncome() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) AS total FROM ${DatabaseHelper.tableTransactions} WHERE type = 'income'",
    );
    return (result.first['total'] as num).toDouble();
  }

  /// Returns the total expenses across all transactions.
  Future<double> totalExpense() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) AS total FROM ${DatabaseHelper.tableTransactions} WHERE type = 'expense'",
    );
    return (result.first['total'] as num).toDouble();
  }

  /// Returns the balance: total income minus total expenses.
  Future<double> balance() async {
    final income = await totalIncome();
    final expense = await totalExpense();
    return income - expense;
  }
}
