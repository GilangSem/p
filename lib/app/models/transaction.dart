import 'package:nylo_framework/nylo_framework.dart';

class Transaction extends Model {
  final int? id;
  final String title;
  final double amount;
  final String type; // "income" or "expense"
  final String date; // "YYYY-MM-DD"

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });

  /// Converts this Transaction object → Map so SQLite can store it.
  /// Note: id is excluded — SQLite assigns it automatically on INSERT.
  Map<String, dynamic> toMap() {
    return {'title': title, 'amount': amount, 'type': type, 'date': date};
  }

  /// Converts a raw SQLite row (Map) → a typed Transaction object.
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
      type: map['type'] as String,
    );
  }

  /// Required by Nylo's Model base class.
  Transaction.fromJson(dynamic data)
    : id = data['id'],
      title = data['title'] ?? '',
      amount = (data['amount'] as num?)?.toDouble() ?? 0.0,
      type = data['type'] ?? 'expense',
      date = data['date'] ?? '';

  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, amount: $amount, type: $type, date: $date)';
  }
}
