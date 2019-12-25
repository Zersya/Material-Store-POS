import 'package:harco_app/models/item.dart';
import 'package:harco_app/models/user.dart';

class Transaction {
  String id;
  final String name;
  final List<Item> items;
  final int profit;
  final int total;
  final User cashier;
  final int createdAt;

  Transaction(this.name, this.items, this.profit, this.total, this.cashier,
      this.createdAt,
      {this.id});

  factory Transaction.fromMap(Map<String, dynamic> map) {
    List list = map['items'];
    return Transaction(
      map['name'],
      list.map((val) => Item.fromMapTransaction(Map<String, dynamic>.from(val))).toList(),
      map['profit'],
      map['total'],
      User.fromMap(map['cashier']),
      map['createdAt'],
      id: map['id'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'name': this.name,
        'items': this.items.map((val) => val.toMapTransaction()).toList(),
        'profit': this.profit,
        'total': this.total,
        'cashier': this.cashier.toMap(),
        'createdAt': this.createdAt,
      };
}
