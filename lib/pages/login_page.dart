import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:provider/provider.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/data/login_account_data.dart';
import 'package:vid_web/data/login_data.dart';
import 'package:vid_web/dialog/loading_dialog.dart';
import 'package:vid_web/dialog/my_dialog.dart';
import 'package:vid_web/manager/common_manager.dart';
import 'package:vid_web/r.dart';
import 'package:vid_web/routes.dart';
import 'package:vid_web/size.dart';
import 'package:vid_web/store/dailymotion_page_store.dart';
import 'package:vid_web/store/login_page_store.dart';
import 'package:vid_web/text_style.dart';
import 'package:vid_web/util/image_loader.dart';
import 'package:vid_web/util/toast_util.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  late LoginPageStore _loginPageStore;
  late DailymotionPageStore _dailymotionPageStore;
  bool isAccountEmpty = true;
  bool isPasswordEmpty = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController?.addListener(() {
      if (isAccountEmpty) {
        if (_emailController?.text.isNotEmpty == true) {
          setState(() {
            isAccountEmpty = false;
          });
        }
      }

      if (!isAccountEmpty) {
        if (_emailController?.text.isEmpty == true) {
          setState(() {
            isAccountEmpty = true;
          });
        }
      }
    });

    _passwordController?.addListener(() {
      if (isPasswordEmpty) {
        if (_passwordController?.text.isNotEmpty == true) {
          setState(() {
            isPasswordEmpty = false;
          });
        }
      }

      if (!isPasswordEmpty) {
        if (_passwordController?.text.isEmpty == true) {
          setState(() {
            isPasswordEmpty = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController?.dispose();
    _passwordController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _loginPageStore = Provider.of<LoginPageStore>(context);
    _dailymotionPageStore = Provider.of<DailymotionPageStore>(context);
    debugPrint("登录页面");

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLocalAccountListView(),
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

  Widget _buildLocalAccountListView() {
    return Observer(builder: (_) {
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _loginPageStore.loginDataList.length,
          itemBuilder: (context, index) {
            return _buildUserItem(_loginPageStore.loginDataList[index]);
          },
        ),
      );
    });
  }

  Widget _buildUserItem(LoginAccountData loginAccountData) {
    return InkWell(
      onTap: () {
        _loginPageStore.setCurrentAccount(loginAccountData);
        _emailController?.text = loginAccountData.account;
        _passwordController?.text = loginAccountData.password;
      },
      child: Observer(builder: (_) {
        debugPrint("更新选中的用户:${loginAccountData.account}");
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: loginAccountData.account == _loginPageStore.currentAccount?.account ? MyColor.colorFFEEEEEE : MyColor.whiteColor,
          ),
          child: Row(
            children: [
              Text(loginAccountData.account, style: MyTextStyle.textStyle400Weight(MyColor.blackColor, fontSize: 15)),
              Spacer(),
              (loginAccountData.account == _loginPageStore.currentAccount?.account)
                  ? ImageLoader.loadAssetImage(R.assetsImagesCheckbook, width: 20, height: 20)
                  : InkWell(
                      onTap: () {
                        MyDialog.showRemoveAccountDialog(context, () {
                          // _loginPageStore.loginDataList.remove(loginAccountData);
                          //
                          // ManageUsers.removeUser(manageUser);
                          // final manageUsersJson = ManageUsers.toJson();
                          // updateGoogleUsers(manageUsersJson);
                          // _buildLocalUserItem();
                        });
                      },
                      child: ImageLoader.loadAssetImage(R.assetsImagesCancel, width: 20, height: 20),
                    ),
            ],
          ),
        );
      }),
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
                  _emailController?.clear();
                  _passwordController?.clear();
                },
                child: Visibility(
                  visible: _emailController?.text.isNotEmpty == true,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: ImageLoader.loadIcon(R.assetsImagesClear, size: 10, iconColor: MyColor.blackColor),
                  ),
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
                onTap: () {
                  _emailController?.clear();
                  _passwordController?.clear();
                },
                child: Visibility(
                  visible: _passwordController?.text.isNotEmpty == true,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: ImageLoader.loadIcon(R.assetsImagesInvisible, size: 10, iconColor: MyColor.blackColor),
                  ),
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
          final User? user = await signInWithGoogle();

          if (user == null) {
            ToastUtil.showToast("登录失败");
            if (context.mounted) {
              LoadingDialog.hideLoadingDialog(context);
            }
            return;
          }
          _loginPageStore.setUser(user);
          /// firebase登陆
          // final firebaseUser = await FireStoreManager.signInWithEmailPassword(_emailController?.text ?? "", _passwordController?.text ?? "");

          // if (firebaseUser == null) {
          //   ToastUtil.showToast("登录失败");
          //   if (context.mounted) {
          //     LoadingDialog.hideLoadingDialog(context);
          //   }
          //   return;
          // }

          final tokenId = await user.getIdToken();
          debugPrint("登录结果 - 邮箱:${user.email} - 是否游客:${user.isAnonymous} - 展示名称:${user.displayName}"
              " - photoURL:${user.photoURL} - uid:${user.uid} - refreshToken:${user.refreshToken} - tenantId:${user.tenantId}\n");

          /// 存储登录的数据
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

          /// 存储账号
          // final loginAccounts = LoginAccountData(
          //   account: _emailController?.text ?? "",
          //   password: _passwordController?.text ?? "",
          //   displayName: user.displayName ?? "",
          //   photoURL: user.photoURL ?? "",
          //   uid: user.uid,
          // );
          // await CommonManager.saveLoginAccountsData(loginAccounts.toJson());

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

  /// 通过Google的凭证登录
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '997863883560-0rlhh2h7l33p9lfsov6a703nn0e3r7nb.apps.googleusercontent.com',
        scopes: ['https://www.googleapis.com/auth/userinfo.profile', 'https://www.googleapis.com/auth/userinfo.email', drive.DriveApi.driveScope,],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // 用户取消了登录
        return null;
      }
      _loginPageStore.setGoogleUser(googleUser);
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 从 Google 用户令牌创建凭证
      final OAuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      debugPrint("登录44 - accessToken:${credential.accessToken} - secret:${credential.secret} - serverAuthCode:${credential.serverAuthCode}");

      // 使用 Firebase 登录
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      // 用户成功登录
      debugPrint("用户登录成功: ${userCredential.user?.displayName}  photo:${userCredential.user?.photoURL}");
      return userCredential.user;
    } catch (e) {
      debugPrint("Google 登录错误: $e");
    }
    return null;
  }

}
