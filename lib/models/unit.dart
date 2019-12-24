import 'package:harco_app/models/user.dart';

class Unit {
  String id;
  final String name;
  final String createdAt;
  User user;

  Unit(this.name, this.createdAt, {this.id, this.user});

  factory Unit.fromMap(Map<String, dynamic> map) =>
      Unit(map['name'], map['createdAt'],
          id: map['id'], user: User.fromMap(map['user']));

  Map<String, dynamic> toMap() => {
        'name': this.name,
        'createdAt': this.createdAt,
        'id': this.id,
        'user': this.user.toMap()
      };
}
