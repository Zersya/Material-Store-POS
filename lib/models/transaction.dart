import 'package:harco_app/models/customer.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/models/user.dart';

class Transaction {
  String id;
  Customer customer;
  double deposit;
  final List<Item> items;
  final int profit;
  final int total;
  final User cashier;
  final int createdAt;

  Transaction(this.customer, this.items, this.profit, this.total, this.deposit, this.cashier,
      this.createdAt, 
      {this.id});

  factory Transaction.fromMap(Map<String, dynamic> map) {
    List list = map['items'];
    return Transaction(
      Customer.fromMap(map['customer']),
      list
          .map((val) => Item.fromMapTransaction(Map<String, dynamic>.from(val)))
          .toList(),
      map['profit'],
      map['total'],
      map['deposit'],
      User.fromMap(map['cashier']),
      map['createdAt'],
      id: map['id'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'customer': this.customer.toMap(),
        'items': this.items.map((val) => val.toMapTransaction()).toList(),
        'profit': this.profit,
        'total': this.total,
        'deposit': this.deposit,
        'cashier': this.cashier.toMap(),
        'createdAt': this.createdAt,
      };
}
