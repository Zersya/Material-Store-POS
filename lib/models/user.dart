class User {
  final String email;

  String id;
  String username;
  String password;  

  User(this.email, {this.password, this.id, this.username});

  factory User.fromMap(Map<dynamic, dynamic> map) {
    return User(map['email'], id: map['id'], username: map['username']);
  }

  Map<String, dynamic> toMap() => {
        'id': this.email,
        'username': this.username,
        'email': this.email,
      };
}
