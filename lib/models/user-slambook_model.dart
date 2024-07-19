// Users Class
import 'dart:convert';

class Users {
  String? id;
  String name;
  String nickname;
  String age;
  String relationshipStatus;
  String happinessLevel;
  String superpower;
  String motto;

  // Constuctor
  Users({
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
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
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

  String toJsonString(Users user) {
    Map<String, dynamic> userMap = toJson(user);
    return jsonEncode(userMap);
  }

  // Transforming a user slambook data to a map
  Map<String, dynamic> toJson(Users user) {
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
