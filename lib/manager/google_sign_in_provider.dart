import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vid_web/util/my_logger.dart';

typedef GoogleSignInCallback = void Function(GoogleSignInAccount? account);

class GoogleSignInProvider extends ChangeNotifier {

  static final GoogleSignInProvider _instance = GoogleSignInProvider._internal();

  // 私有的构造函数
  GoogleSignInProvider._internal();

  // 提供静态的 getter 来访问单例对象
  static GoogleSignInProvider get instance => _instance;


  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: '997863883560-0rlhh2h7l33p9lfsov6a703nn0e3r7nb.apps.googleusercontent.com',
    scopes: ['https://www.googleapis.com/auth/userinfo.profile', 'https://www.googleapis.com/auth/userinfo.email'],
  );

  GoogleSignInAccount? _user;

  GoogleSignInAccount? get user => _user;

  /// 尝试静默登录
  Future<GoogleSignInAccount?> signInSilently() async {
    return googleSignIn.signInSilently();
  }

  /// 登录
  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;
      notifyListeners();
    } catch (e) {
      mLogger.e(e.toString());
    }
  }

  /// 注销账户
  Future<void> handleSignOut(GoogleSignInCallback googleSignInCallback) async {
    final res = await googleSignIn.signOut();
    googleSignInCallback.call(res);
    _user = null;
  }

  /// 登出
  Future googleLogout() async {
    await googleSignIn.disconnect();
    _user = null;
    notifyListeners();
  }

  /// 坚挺当前的用户
  void currentUserListener(GoogleSignInCallback googleSignInCallback) {
    googleSignIn.onCurrentUserChanged.listen((account) {
      googleSignInCallback.call(account);
    });
  }
}
