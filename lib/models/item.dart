import 'package:harco_app/models/user.dart';

class Item {
  String id;
  int pcs;

  User createdBy;
  final String name;
  final String priceBuy;
  final String priceSell;
  final String unit;
  final String createdAt;

  Item(
    this.name,
    this.priceBuy,
    this.priceSell,
    this.unit,
    this.createdBy, {
    this.id,
    this.pcs,
    this.createdAt,
  });

  factory Item.fromMap(Map<String, dynamic> map) => Item(
      map['name'],
      map['priceBuy'],
      map['priceSell'],
      map['unit'],
      User.fromMap(map['createdBy']),
      id: map['id'],
      createdAt: map['createdAt']);

  factory Item.fromMapTransaction(Map<String, dynamic> map) => Item(
      map['name'],
      map['priceBuy'],
      map['priceSell'],
      map['unit'],
      User.fromMap(map['createdBy']),
      createdAt: map['createdAt'],
      id: map['id'],
      pcs: map['pcs']);

  Map<String, dynamic> toMap() => {
        'name': this.name,
        'priceBuy': this.priceBuy,
        'priceSell': this.priceSell,
        'unit': this.unit,
        'createdBy': this.createdBy.toMap(),
        'createdAt': this.createdAt,
        'id': this.id
      };

  Map<String, dynamic> toMapTransaction() => {
        'name': this.name,
        'priceBuy': this.priceBuy,
        'priceSell': this.priceSell,
        'unit': this.unit,
        'createdAt': this.createdAt,
        'createdBy': this.createdBy.toMap(),
        'id': this.id,
        'pcs': this.pcs,
      };
}
