import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/data/login_data.dart';
import 'package:vid_web/dialog/loading_dialog.dart';
import 'package:vid_web/manager/common_manager.dart';
import 'package:vid_web/r.dart';
import 'package:vid_web/routes.dart';
import 'package:vid_web/size.dart';
import 'package:vid_web/text_style.dart';
import 'package:vid_web/util/image_loader.dart';
import 'package:vid_web/util/toast_util.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '997863883560-0rlhh2h7l33p9lfsov6a703nn0e3r7nb.apps.googleusercontent.com',
    scopes: ['https://www.googleapis.com/auth/userinfo.profile', 'https://www.googleapis.com/auth/userinfo.email'],
  );
  TextEditingController? _emailController;
  TextEditingController? _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController?.dispose();
    _passwordController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("登录页面");

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(20.0), child: ImageLoader.loadAssetImage(R.assetsImagesLogo, width: 100.0, height: 100.0)),
              ImageLoader.loadAssetImage(R.assetsImagesVidscape, width: 159, height: 64),
              h60,
              buildLoginWidget(),
              h20,
              buildLoginButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoginWidget() {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(horizontal: 150),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: '请输入登录邮箱账号',
              suffixIcon: InkWell(
                onTap: () {
                  // _emailController?.clear();
                  // _passwordController?.clear();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: ImageLoader.loadIcon(R.assetsImagesClear, size: 10, iconColor: MyColor.blackColor),
                ),
              ),
            ),
            onChanged: (_) {
              debugPrint("用户的账号为：${_emailController?.text}");

            },
          ),
          h20,
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: '请输入登录邮箱密码',
              suffixIcon: InkWell(
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: ImageLoader.loadIcon(R.assetsImagesInvisible, size: 10, iconColor: MyColor.blackColor),
                ),
              ),
            ),
            onChanged: (_) {
              debugPrint("用户的密码为：${_passwordController?.text}");
            },
          ),
          h20,
        ],
      ),
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 165),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColor.colorFF546E7A,
          foregroundColor: MyColor.whiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          elevation: 5,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        ),
        onPressed: () async {
          if (_emailController?.text == null || _emailController?.text == "" || _passwordController?.text == null || _passwordController?.text == "") {
            ToastUtil.showToast("请填写登陆账户和密码");
            return;
          }
          LoadingDialog.showLoadingDialog(context);
          final User? user = await signInWithGoogle1();
          final tokenId = await user?.getIdToken();
          debugPrint("登录结果 - 邮箱:${user?.email} - 是否游客:${user?.isAnonymous} - 展示名称:${user?.displayName}"
              " - photoURL:${user?.photoURL} - uid:${user?.uid} - refreshToken:${user?.refreshToken} - tenantId:${user?.tenantId}");
          if (user == null) {
            ToastUtil.showToast("登录失败");
            if (context.mounted) {
              LoadingDialog.hideLoadingDialog(context);
            }
            return;
          }

          // 存储登录的数据
          final loginDataJson = LoginData(
            email: user.email ?? "",
            isAnonymous: user.isAnonymous,
            displayName: user.displayName ?? "",
            photoURL: user.photoURL ?? "",
            uid: user.uid,
            refreshToken: user.refreshToken ?? "",
            tenantId: user.tenantId ?? "",
            emailVerified: user.emailVerified,
            phoneNumber: user.phoneNumber ?? "",
            tokenId: tokenId ?? "",
          ).toJson();
          await CommonManager.saveLoginData(loginDataJson);
          if (context.mounted) {
            LoadingDialog.hideLoadingDialog(context);
            Navigator.of(context).pop();
            Routes.router.navigateTo(context, Routes.homePath);
          }
        },
        child: Text("登陆", style: MyTextStyle.textStyle500Weight(MyColor.whiteColor, fontSize: 15)),
      ),
    );
  }

  /// 通过google邮箱账号和密码登录
  Future<User?> _newSignInWithGoogle(String email, String password) async {
    final googleUser = await _googleSignIn.signIn();
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  }

  /// 通过Google的凭证登录
  Future<User?> signInWithGoogle1() async {
    try {
      // 启动 Google 登录
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // 用户取消了登录
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 从 Google 用户令牌创建凭证
      final OAuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      debugPrint("登录44 - accessToken:${credential.accessToken} - secret:${credential.secret} - serverAuthCode:${credential.serverAuthCode}");

      // 使用 Firebase 登录
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      // 用户成功登录
      debugPrint("用户登录成功: ${userCredential.user?.displayName}");
      return userCredential.user;
    } catch (e) {
      debugPrint("Google 登录错误: $e");
    }
    return null;
  }

  Future<User?> signInWithGoogle() async {
    try {
      // 触发 Google 登录流程
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      debugPrint("登录11 - email:${googleUser?.email}  displayName:${googleUser?.displayName}");
      if (googleUser == null) {
        // 用户取消了登录
        return null;
      }
      // 获取 Google 登录凭证
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;
      debugPrint("登录22 - accessToken:$accessToken - idToken:${googleAuth.idToken}");

      if(accessToken != null) {
        final response = await http.get(
          Uri.parse('https://content-people.googleapis.com/v1/people/me?sources=READ_SOURCE_TYPE_PROFILE&personFields=photos,names,emailAddresses'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );
        debugPrint("请求用户数据的响应结果:${response.body}");
      }

      // 使用 Firebase 身份验证进行登录
      final OAuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      debugPrint("登录44 - accessToken:${credential.accessToken} - secret:${credential.secret} - serverAuthCode:${credential.serverAuthCode}");
      // 使用凭证进行 Firebase 登录
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint("登录55 - userEmail:${userCredential.user?.email} - username:${userCredential.additionalUserInfo?.username} - authorizationCode:${userCredential.additionalUserInfo?.authorizationCode}");
      return userCredential.user;
    } catch (e) {
      debugPrint("Error during Google sign-in: $e");
      return null;
    }
  }
}
