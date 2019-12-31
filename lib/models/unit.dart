import 'package:harco_app/models/user.dart';

class Unit {
  String id;
  final String name;
  final String createdAt;
  User createdBy;

  Unit(this.name, this.createdAt, {this.id, this.createdBy});

  factory Unit.fromMap(Map<dynamic, dynamic> map) =>
      Unit(map['name'], map['createdAt'],
          id: map['id'], createdBy: User.fromMap(map['createdBy']));

  Map<String, dynamic> toMap() => {
        'name': this.name,
        'createdAt': this.createdAt,
        'id': this.id,
        'createdBy': this.createdBy.toMap()
      };
}
