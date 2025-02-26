import 'dart:convert';

class UserInfo {
  /// 用户展示的姓名
  String name = "";
  String displayName = "";
  String email = "";

  /// 根据userId查询用户的信息
  String userId = "";

  /// google
  String googleId = "";
  String photoUrl = "";
  String googleServerAuthCode = "";

  /// apple
  String appleId = "";

  /// facebook
  String facebookId = "";

  /// tiktok
  String tiktokId = "";
  bool isMember = false;
  int memberType = 0;
  int memberExpireTime = 0;

  UserInfo({
    this.name = "",
    this.displayName = "",
    this.email = "",
    this.userId = "",
    this.googleId = "",
    this.photoUrl = "",
    this.googleServerAuthCode = "",
    this.appleId = "",
    this.facebookId = "",
    this.tiktokId = "",
    this.isMember = false,
    this.memberType = 0,
    this.memberExpireTime = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'displayName': displayName,
      'email': email,
      'userId': userId,
      'googleId': googleId,
      'photoUrl': photoUrl,
      'googleServerAuthCode': googleServerAuthCode,
      'appleId': appleId,
      'facebookId': facebookId,
      'tiktokId': tiktokId,
      'isMember': isMember,
      'memberType': memberType,
      'memberExpireTime': memberExpireTime,
    };
  }

  factory UserInfo.fromMap(Map<String, dynamic> jsonMap) {
    return UserInfo(
      name: jsonMap['name'],
      displayName: jsonMap['displayName'],
      email: jsonMap['email'],
      userId: jsonMap['userId'],
      googleId: jsonMap['googleId'],
      photoUrl: jsonMap['photoUrl'],
      googleServerAuthCode: jsonMap['googleServerAuthCode'],
      appleId: jsonMap['appleId'],
      facebookId: jsonMap['facebookId'],
      tiktokId: jsonMap['tiktokId'],
      isMember: jsonMap['isMember'],
      memberType: jsonMap['memberType'],
      memberExpireTime: jsonMap['memberExpireTime'],
    );
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'] ?? "",
      displayName: json['displayName'] ?? "",
      email: json['email'] ?? "",
      userId: json['userId'] ?? "",
      googleId: json['googleId'] ?? "",
      photoUrl: json['photoUrl'] ?? "",
      googleServerAuthCode: json['googleServerAuthCode'] ?? "",
      appleId: json['appleId'] ?? "",
      facebookId: json['facebookId'] ?? "",
      tiktokId: json['tiktokId'] ?? "",
      isMember: json['isMember'] ?? false,
      memberType: json['memberType'] ?? 0,
      memberExpireTime: json['memberExpireTime'] ?? 0,
    );
  }

  String toJson() {
    return jsonEncode({
      'name': name,
      'displayName': displayName,
      'email': email,
      'userId': userId,
      'googleId': googleId,
      'photoUrl': photoUrl,
      'googleServerAuthCode': googleServerAuthCode,
      'appleId': appleId,
      'facebookId': facebookId,
      'tiktokId': tiktokId,
      'isMember': isMember,
      'memberType': memberType,
      'memberExpireTime': memberExpireTime,
    });
  }

}
