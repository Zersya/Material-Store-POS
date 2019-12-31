import 'package:harco_app/models/user.dart';

class Customer {
  String id;
  String name;
  double deposit;
  User createdBy;

  Customer({this.deposit, this.id, this.name, this.createdBy});

  factory Customer.fromMap(Map<dynamic, dynamic> map) {
    return Customer(
        deposit: map['deposit'],
        id: map['id'],
        name: map['name'],
        createdBy: User.fromMap(map['createdBy']));
  }

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'name': this.name,
        'deposit': this.deposit,
        'createdBy': this.createdBy.toMap()
      };
}
