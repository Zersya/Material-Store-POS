import 'package:harco_app/models/item.dart';
import 'package:harco_app/models/user.dart';

class Transaction {
  String id;
  final String name;
  final List<Item> items;
  final int profit;
  final int total;
  final User cashier;

  Transaction(this.name, this.items, this.profit, this.total, this.cashier, {this.id});

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        map['name'],
        map['profit'],
        map['items'],
        map['total'],
        User.fromMap(map['cashier']),
        id: map['id'],
      );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'name': this.name,
        'items': this.items.map((val) => val.toMap()).toList(),
        'profit': this.profit,
        'total': this.total,
        'cashier': this.cashier.toMap()
      };
}
