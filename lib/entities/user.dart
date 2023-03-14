class User {
  final String userID;
  final String email;

  User(this.userID, this.email);

  User.fromJson(Map<String, dynamic> json)
      : userID = json['userID'],
        email = json['email'];
}
