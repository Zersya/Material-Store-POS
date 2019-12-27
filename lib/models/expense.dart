import 'package:harco_app/models/user.dart';

class Expense {
  String id;
  final String description;
  final double amount;
  final User createdBy;
  final int createdAt;

  Expense(this.description, this.amount, this.createdBy, this.createdAt,
      {this.id});

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
      map['description'], map['amount'], User.fromMap(map['createdBy']), map['createdAt'],
      id: map['id']);

  Map<String, dynamic> toMap() => {
        'description': this.description,
        'amount': this.amount,
        'createdBy': this.createdBy.toMap(),
        'createdAt': this.createdAt,
        'id': this.id
      };
}
