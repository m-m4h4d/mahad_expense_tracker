class Expense {
  final int? id;
  final int? userId;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String type;

  Expense({
    this.id,
    this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
  });

  Expense copyWith({
    int? id,
    int? userId,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? type,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      type: map['type'] ?? 'Expense',
    );
  }
}
