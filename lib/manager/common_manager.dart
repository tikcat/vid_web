import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:vid_web/util/sp_util.dart';

import '../data/user_info.dart';


class CommonManager {

  static const String starCodeKey = "star_code";
  static const String isBeepKey = "open_beep";
  static const String isVibrationKey = "open_vibration";
  static const String openLinkKey = "open_link";
  static const String rateShowKey = "rate_show";
  static const String firebaseUserIdKey = "firebase_uid";
  static const String autoUploadKey = "auto_upload";
  static const String userInfoKey = "user_info";

  /// 存储登录的数据
  static const String loginDataKey = "login_data_key";

  static Future<String?> getLoginData() async {
    return await SpUtil.getStringData(loginDataKey);
  }

  static Future<void> saveLoginData(String loginJson) async {
    SpUtil.saveStringData(userInfoKey, loginJson);
  }

  static Future<bool?> getAutoUpload() async {
    return await SpUtil.getBoolData(autoUploadKey);
  }

  static void updateAutoUpload(bool autoUpload) {
    SpUtil.saveBoolData(autoUploadKey, autoUpload);
  }

  static Future<String?> getFirebaseUId() async {
    return await SpUtil.getStringData(firebaseUserIdKey);
  }

  static void updateFirebaseUId(String firebaseUid) {
    SpUtil.saveStringData(firebaseUserIdKey, firebaseUid);
  }

  static Future<bool?> getStarState() async {
    return await SpUtil.getBoolData(starCodeKey);
  }

  static void updateStarState(bool starState) {
    SpUtil.saveBoolData(starCodeKey, starState);
  }

  static Future<bool?> isBeep() async {
    return await SpUtil.getBoolData(isBeepKey);
  }

  static void updateBeep(bool isBeepValue) async {
    SpUtil.saveBoolData(isBeepKey, isBeepValue);
  }

  static Future<bool?> isVibration() async {
    return await SpUtil.getBoolData(isVibrationKey);
  }

  static void updateVibration(bool isVibrationValue) async {
    SpUtil.saveBoolData(isVibrationKey, isVibrationValue);
  }

  static Future<bool?> isOpenLink() async {
    return await SpUtil.getBoolData(openLinkKey);
  }

  static void updateOpenLink(bool openLinkValue) async {
    SpUtil.saveBoolData(openLinkKey, openLinkValue);
  }

  static Future<UserInfo?> getUserInfo() async {
    final userInfoJson = await SpUtil.getStringData(userInfoKey);
    if(userInfoJson != null) {
      final userInfo = UserInfo.fromJson(jsonDecode(userInfoJson));
      return userInfo;
    } else {
      return null;
    }
  }

  static Future<void> updateUserInfo(UserInfo userInfo) async {
    final oldUserInfo = await getUserInfo();
    if(oldUserInfo != null) {
      if(userInfo.name.isNotEmpty) {
        oldUserInfo.name = userInfo.name;
      }
      if(userInfo.displayName.isNotEmpty) {
        oldUserInfo.displayName = userInfo.displayName;
      }
      if(userInfo.email.isNotEmpty) {
        oldUserInfo.email = userInfo.email;
      }
      if(userInfo.photoUrl.isNotEmpty) {
        oldUserInfo.photoUrl = userInfo.photoUrl;
      }
      if(userInfo.userId.isNotEmpty) {
        oldUserInfo.userId = userInfo.userId;
      }
      if(userInfo.googleId.isNotEmpty) {
        oldUserInfo.googleId = userInfo.googleId;
      }
      if(userInfo.googleServerAuthCode.isNotEmpty) {
        oldUserInfo.googleServerAuthCode = userInfo.googleServerAuthCode;
      }
      if(userInfo.appleId.isNotEmpty) {
        oldUserInfo.appleId = userInfo.appleId;
      }
      if(userInfo.facebookId.isNotEmpty) {
        oldUserInfo.facebookId = userInfo.facebookId;
      }
      if(userInfo.tiktokId.isNotEmpty) {
        oldUserInfo.tiktokId = userInfo.tiktokId;
      }
      if(userInfo.isMember) {
        oldUserInfo.isMember = userInfo.isMember;
      }
      if(userInfo.memberType != 0) {
        oldUserInfo.memberType = userInfo.memberType;
      }
      if(userInfo.memberExpireTime != 0) {
        oldUserInfo.memberExpireTime = userInfo.memberExpireTime;
      }
      final String oldUserInfoJson = oldUserInfo.toJson();
      SpUtil.saveStringData(userInfoKey, oldUserInfoJson);
    } else {
      final String userInfoJson = userInfo.toJson();
      SpUtil.saveStringData(userInfoKey, userInfoJson);
    }
  }

  static void saveUserInfo(UserInfo userInfo) {
    final String userInfoJson = userInfo.toJson();
    SpUtil.saveStringData(userInfoKey, userInfoJson);
  }

  /// 是否是会员
  static Future<bool> isMember() async {
    final userInfo = await getUserInfo();
    if(userInfo != null) {
      return userInfo.isMember;
    }
    return false;
  }

  /// 是否登陆
  static Future<bool> isLogin() async {
    final userInfo = await getUserInfo();
    if(userInfo != null) {
      return userInfo.userId.isNotEmpty;
    }
    return false;
  }

  static Future<String?> getUserAvatar() async {
    final userInfo = await getUserInfo();
    if(userInfo != null) {
      return userInfo.photoUrl;
    }
    return null;
  }

  static Future<String?> getUserId() async {
    final userInfo = await getUserInfo();
    if(userInfo != null) {
      return userInfo.userId;
    }
    return null;
  }

  /// HH:mm:ss 转换为毫秒数
  static int timeToMilliseconds(String time) {
    List<String> parts = time.split(":");

    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);

    // 计算总毫秒数
    int milliseconds = (hours * 3600 + minutes * 60 + seconds) * 1000;

    return milliseconds;
  }

  /// 获取当前时间戳
  static int getCurrentTimestamp() {
    DateTime now = DateTime.now();
    return now.millisecondsSinceEpoch;
  }

  /// 是否过期
  static bool isExpired(int expireTime) {
    int currentTimestamp = getCurrentTimestamp();
    return currentTimestamp > expireTime;
  }
  
  /// 生成一个用户Id
  static String generateUserId() {
    String userId = "vid${Uuid().v1().replaceAll("-", "")}";
    return userId;
  }

}