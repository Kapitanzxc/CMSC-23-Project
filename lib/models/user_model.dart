// Friend Class
class User {
  String? id;
  String name;
  String nickname;
  String age;
  String relationshipStatus;
  String happinessLevel;
  String superpower;
  String motto;

  // Constuctor
  User({
    this.id,
    required this.name,
    required this.nickname,
    required this.age,
    required this.relationshipStatus,
    required this.happinessLevel,
    required this.superpower,
    required this.motto,
  });

  // Factory constructor to instantiate object from json format
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      nickname: json['nickname'],
      age: json['age'],
      relationshipStatus: json['relationshipStatus'],
      happinessLevel: json['happinessLevel'],
      superpower: json['superpower'],
      motto: json['motto'],
    );
  }

  // static List<Friend> fromJsonArray(String jsonData) {
  //   final Iterable<dynamic> data = jsonDecode(jsonData);
  //   return data.map<Friend>((dynamic d) => Friend.fromJson(d)).toList();
  // }

  // Transforming a friend class to a map
  Map<String, dynamic> toJson(User user) {
    return {
      'name': user.name,
      'nickname': user.nickname,
      'age': user.age,
      'relationshipStatus': user.relationshipStatus,
      'happinessLevel': user.happinessLevel,
      'superpower': user.superpower,
      'motto': user.motto
    };
  }
}
