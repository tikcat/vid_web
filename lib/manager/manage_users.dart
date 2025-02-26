import 'dart:convert';

import 'package:vid_web/util/sp_util.dart';

class ManageUser {
  String googleAccount;
  String googlePassword;

  ManageUser({required this.googleAccount, required this.googlePassword});

  String toJson() => jsonEncode({
        'googleAccount': googleAccount,
        'googlePassword': googlePassword,
      });

  factory ManageUser.fromJson(String jsonString) {
    final Map<String, dynamic> obj = jsonDecode(jsonString);
    return ManageUser(
      googleAccount: obj['googleAccount'],
      googlePassword: obj['googlePassword'],
    );
  }
}

class ManageUsers {
  static final List<ManageUser> _users = [];

  static void addUser(ManageUser user) {
    _users.add(user);
  }

  static void addUsers(List<ManageUser> users) {
    _users.addAll(users);
  }

  static void removeUser(ManageUser user) {
    _users.remove(user);
  }

  static void clearUsers() {
    _users.clear();
  }

  static void updateUsers(List<ManageUser> users) {
    clearUsers();
    addUsers(users);
  }

  // 将对象转换为 JSON 字符串
  static String toJson() {
    return json.encode(_users);
  }

  // 从 JSON 字符串解析对象
  static List<ManageUser> fromJson(String jsonString) {
    json.decode(jsonString);
    final List<dynamic> jsonList = json.decode(jsonString);
    List<ManageUser> manageUserList = jsonList.map((json) => ManageUser.fromJson(json)).toList();
    updateUsers(manageUserList);
    return manageUserList;
  }
}

const String _googleUserKey = "google_user_key";

Future<String?> getGoogleUsers() async {
  return await SpUtil.getStringData(_googleUserKey);
}

void updateGoogleUsers(String googleUsers) {
  SpUtil.saveStringData(_googleUserKey, googleUsers);
}
