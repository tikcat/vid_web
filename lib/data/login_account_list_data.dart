import 'dart:convert';

import 'package:vid_web/data/login_account_data.dart';

class LoginAccountListData {
  List<LoginAccountData> loginDataList = [];

  LoginAccountListData({
    this.loginDataList = const [],
  });

  // 将对象转化为Map
  Map<String, dynamic> toMap() {
    return {
      'loginDataList': loginDataList.map((item) => item.toMap()).toList(),
    };
  }

  factory LoginAccountListData.fromMap(Map<String, dynamic> jsonMap) {
    return LoginAccountListData(
      loginDataList: jsonMap['loginDataList'],
    );
  }

  // 将对象转换为 JSON 字符串
  String toJson() => jsonEncode({'loginDataList': loginDataList});

  // 从 JSON 字符串解析对象
  factory LoginAccountListData.fromJson(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return LoginAccountListData(loginDataList: jsonMap['loginDataList']);
  }
}
