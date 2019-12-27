class User {
  final String email;

  String id;
  String name;
  String password;  

  User(this.email, {this.password, this.id, this.name});

  factory User.fromMap(Map<dynamic, dynamic> map) {
    return User(map['email'], id: map['id'], name: map['name']);
  }

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'name': this.email,
        'email': this.email,
      };
}
