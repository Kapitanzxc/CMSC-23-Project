// Friend Class
class Friend {
  String? id;
  String verified;
  String name;
  String nickname;
  String age;
  String relationshipStatus;
  String happinessLevel;
  String superpower;
  String motto;
  String? profilePictureURL;

  // Constuctor
  Friend({
    this.id,
    required this.verified,
    required this.name,
    required this.nickname,
    required this.age,
    required this.relationshipStatus,
    required this.happinessLevel,
    required this.superpower,
    required this.motto,
    required this.profilePictureURL,
  });

  // Factory constructor to instantiate object from json format
  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
        id: json['id'],
        verified: json['verified'],
        name: json['name'],
        nickname: json['nickname'],
        age: json['age'],
        relationshipStatus: json['relationshipStatus'],
        happinessLevel: json['happinessLevel'],
        superpower: json['superpower'],
        motto: json['motto'],
        profilePictureURL: json['profilePictureURL']);
  }

  // Transforming a friend class to a map
  Map<String, dynamic> toJson(Friend friend) {
    return {
      'verified': friend.verified,
      'name': friend.name,
      'nickname': friend.nickname,
      'age': friend.age,
      'relationshipStatus': friend.relationshipStatus,
      'happinessLevel': friend.happinessLevel,
      'superpower': friend.superpower,
      'motto': friend.motto,
      'profilePictureURL': friend.profilePictureURL
    };
  }
}
