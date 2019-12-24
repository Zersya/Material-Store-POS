import 'package:harco_app/models/item.dart';
import 'package:harco_app/models/user.dart';

class Transaction {
  final String name;
  final List<Item> items;
  final String profit;
  final User cashier;

  Transaction(this.name, this.items, this.profit,
      this.cashier);

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
      map['name'],
      map['profit'],
      map['items'],
      User.fromMap(map['cashier']));

  Map<String, dynamic> toMap() => {
        'name': this.name,
        'items': this.items,
        'profit': this.profit,
        'cashier': this.cashier
      };
}
