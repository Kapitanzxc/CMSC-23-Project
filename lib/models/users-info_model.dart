// Users Personal Class
class UsersInfo {
  String email;
  String name;
  String username;
  String contact;
  String? profilePicURL;
  List<String> additionalContacts;

  // Constuctor
  UsersInfo(
      {required this.email,
      required this.name,
      required this.username,
      required this.contact,
      required this.profilePicURL,
      required this.additionalContacts});

// Factory constructor to instantiate object from JSON format
  factory UsersInfo.fromJson(Map<String, dynamic> json) {
    return UsersInfo(
      email: json['email'],
      name: json['name'],
      username: json['username'],
      contact: json['contact'],
      profilePicURL: json['profilePicURL'] ?? "",
      additionalContacts: List<String>.from(json['additionalContacts'] ?? []),
    );
  }

  // Transforming a User object to a map
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'username': username,
      'contact': contact,
      'profilePicURL': profilePicURL,
      'additionalContacts': additionalContacts,
    };
  }
}
