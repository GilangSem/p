import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/transaction.dart';
import '/app/networking/budget_service.dart';

class HomeController extends NyController {
  // ── State ─────────────────────────────────────────────────────────
  List<Transaction> transactions = [];
  double totalIncome = 0;
  double totalExpense = 0;

  // ── Computed ─────────────────────────────────────────────────────────
  double get balance => totalIncome - totalExpense;

  // ── Lifecycle ────────────────────────────────────────────────────────
  @override
  Future<void> construct(BuildContext context) async {
    super.construct(context);
  }

  // ── Data loading ──────────────────────────────────────────────────────

  /// Fetches all transactions and summary totals from SQLite.
  /// Called on page load and after any add / edit / delete.
  Future<void> loadData() async {
    try {
      transactions = await api<BudgetService>((s) => s.fetchAll());
      totalIncome = await api<BudgetService>((s) => s.totalIncome());
      totalExpense = await api<BudgetService>((s) => s.totalExpense());
      print(
        '[HomeController] loadData completed: transactions=${transactions.length}, income=$totalIncome, expense=$totalExpense',
      );
    } catch (error, stackTrace) {
      print('[HomeController] loadData failed: $error');
      print(stackTrace);
    }
  }

  // ── Delete ──────────────────────────────────────────────────────────

  /// Deletes a transaction by id, then reloads data to refresh the UI.
  Future<void> deleteTransaction(int id) async {
    await api<BudgetService>((s) => s.deleteTransaction(id));
  }
}
