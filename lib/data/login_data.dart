import 'dart:convert';

class LoginData {
  /// 邮箱
  String email = "";

  /// 是否游客登录
  bool isAnonymous = false;
  String displayName = "";
  String photoURL = "";
  String uid = "";
  String refreshToken = "";
  String tenantId = "";

  /// 邮箱是否已验证
  bool emailVerified = false;

  /// 手机号码
  String phoneNumber = "";

  /// 返回用于向 Firebase 服务识别用户的 JSON Web Token (JWT)。
  String tokenId = "";

  LoginData({
    this.email = "",
    this.isAnonymous = false,
    this.displayName = "",
    this.photoURL = "",
    this.uid = "",
    this.refreshToken = "",
    this.tenantId = "",
    this.emailVerified = false,
    this.phoneNumber = "",
    this.tokenId = "",
  });

  // 将对象转化为Map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'isAnonymous': isAnonymous,
      'displayName': displayName,
      'photoURL': photoURL,
      'uid': uid,
      'refreshToken': refreshToken,
      'tenantId': tenantId,
      'emailVerified': emailVerified,
      'phoneNumber': phoneNumber,
      'tokenId': tokenId,
    };
  }

  factory LoginData.fromMap(Map<String, dynamic> jsonMap) {
    return LoginData(
      email: jsonMap['email'],
      isAnonymous: jsonMap['isAnonymous'],
      displayName: jsonMap['displayName'],
      photoURL: jsonMap['photoURL'],
      uid: jsonMap['uid'],
      refreshToken: jsonMap['refreshToken'],
      tenantId: jsonMap['tenantId'],
      emailVerified: jsonMap['emailVerified'],
      phoneNumber: jsonMap['phoneNumber'],
      tokenId: jsonMap['tokenId'],
    );
  }

  // 将对象转换为 JSON 字符串
  String toJson() => jsonEncode({
        'email': email,
        'isAnonymous': isAnonymous,
        'displayName': displayName,
        'photoURL': photoURL,
        'uid': uid,
        'refreshToken': refreshToken,
        'tenantId': tenantId,
        'emailVerified': emailVerified,
        'phoneNumber': phoneNumber,
        'tokenId': tokenId,
      });

  // 从 JSON 字符串解析对象
  factory LoginData.fromJson(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return LoginData(
      email: jsonMap['email'],
      isAnonymous: jsonMap['isAnonymous'],
      displayName: jsonMap['displayName'],
      photoURL: jsonMap['photoURL'],
      uid: jsonMap['uid'],
      refreshToken: jsonMap['refreshToken'],
      tenantId: jsonMap['tenantId'],
      emailVerified: jsonMap['emailVerified'],
      phoneNumber: jsonMap['phoneNumber'],
      tokenId: jsonMap['tokenId'],
    );
  }
}
