import 'package:harco_app/models/user.dart';

class Item {
  String id;
  int pcs;

  final User user;
  final String name;
  final String priceBuy;
  final String priceSell;
  final String unit;
  final String createdAt;

  Item(this.name, this.priceBuy, this.priceSell, this.unit,
      this.user,
      {this.id, this.pcs, this.createdAt,});

  factory Item.fromMap(Map<String, dynamic> map) => Item(
      map['name'],
      map['priceBuy'],
      map['priceSell'],
      map['unit'],
      User.fromMap(map['user']),
      id: map['id'],
      createdAt: map['createdAt']);

  factory Item.fromMapTransaction(Map<String, dynamic> map) => Item(
      map['name'],
      map['priceBuy'],
      map['priceSell'],
      map['unit'],
      User.fromMap(map['user']),
      createdAt: map['createdAt'],
      id: map['id'],
      pcs: map['pcs']);

  Map<String, dynamic> toMap() => {
        'name': this.name,
        'priceBuy': this.priceBuy,
        'priceSell': this.priceSell,
        'unit': this.unit,
        'user': this.user.toMap(),
        'createdAt': this.createdAt,
        'id': this.id
      };

  Map<String, dynamic> toMapTransaction() => {
        'name': this.name,
        'priceBuy': this.priceBuy,
        'priceSell': this.priceSell,
        'unit': this.unit,
        'createdAt': this.createdAt,
        'user': this.user.toMap(),
        'id': this.id,
        'pcs': this.pcs,
      };
}
