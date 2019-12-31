import 'package:harco_app/models/user.dart';

class Cash {
  String id;
  final String description;
  final double amount;
  final String mode;
  final User createdBy;
  final int createdAt;

  Cash(this.description, this.amount, this.mode,this.createdBy, this.createdAt,
      {this.id});

  factory Cash.fromMap(Map<String, dynamic> map) => Cash(
      map['description'], map['amount'], map['mode'], User.fromMap(map['createdBy']), map['createdAt'],
      id: map['id']);

  Map<String, dynamic> toMap() => {
        'description': this.description,
        'amount': this.amount,
        'mode': this.mode,
        'createdBy': this.createdBy.toMap(),
        'createdAt': this.createdAt,
        'id': this.id
      };
}
