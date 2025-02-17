import 'dart:convert';

class LoginAccountData {
  String account = "";
  String password = "";
  String displayName = "";
  String photoURL = "";
  String uid = "";

  LoginAccountData({
    this.account = "",
    this.password = "",
    this.displayName = "",
    this.photoURL = "",
    this.uid = "",
  });

  // 将对象转化为Map
  Map<String, dynamic> toMap() {
    return {
      'account': account,
      'password': password,
      'displayName': displayName,
      'photoURL': photoURL,
      'uid': uid,
    };
  }

  factory LoginAccountData.fromMap(Map<String, dynamic> jsonMap) {
    return LoginAccountData(
      account: jsonMap['account'],
      password: jsonMap['password'],
      displayName: jsonMap['displayName'],
      photoURL: jsonMap['photoURL'],
      uid: jsonMap['uid'],
    );
  }

  // 将对象转换为 JSON 字符串
  String toJson() => jsonEncode({
    'account': account,
    'password': password,
    'displayName': displayName,
    'photoURL': photoURL,
    'uid': uid,
  });

  // 从 JSON 字符串解析对象
  factory LoginAccountData.fromJson(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return LoginAccountData(
      account: jsonMap['account'],
      password: jsonMap['password'],
      displayName: jsonMap['displayName'],
      photoURL: jsonMap['photoURL'],
      uid: jsonMap['uid'],
    );
  }
}