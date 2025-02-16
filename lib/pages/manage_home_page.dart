import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:vid_web/constant/data_callback.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/dialog/loading_dialog.dart';
import 'package:vid_web/dialog/my_dialog.dart';
import 'package:vid_web/enum/home_list_block.dart';
import 'package:vid_web/manager/common_manager.dart';
import 'package:vid_web/manager/fire_store_manager.dart';
import 'package:vid_web/manager/google_sign_in_provider.dart';
import 'package:vid_web/manager/manage_users.dart';
import 'package:vid_web/manager/media_source_manage.dart';
import 'package:vid_web/r.dart';
import 'package:vid_web/routes.dart';
import 'package:vid_web/size.dart';
import 'package:vid_web/store/manage_settings_store.dart';
import 'package:vid_web/store/video_data_store.dart';
import 'package:vid_web/text_style.dart';
import 'package:vid_web/util/image_loader.dart';
import 'package:vid_web/util/my_logger.dart';
import 'package:vid_web/util/toast_util.dart';
import 'package:vid_web/widget/qr_app_bar.dart';

class ManageHomePage extends StatefulWidget {
  const ManageHomePage({super.key});

  @override
  State<ManageHomePage> createState() => _ManageHomePageState();
}

class _ManageHomePageState extends State<ManageHomePage> {
  final GoogleSignInProvider _googleSignInProvider = GoogleSignInProvider.instance;

  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  late VideoDataStore videoDataStore;

  BuildContext? _context;
  LoginFirebaseCallback? _loginFirebaseCallback;

  bool _initStatus = false;

  /// 初始化设置的一些状态
  _initSettingsStatus(ManageSettingsStore manageSettingStore) async {
    if (!_initStatus) {
      _initStatus = true;
      final autoAvailable = await CommonManager.getAutoUpload();
      manageSettingStore.updateAutoAvailable(autoAvailable ?? false);
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _googleSignInProvider.addListener(() {
      mLogger.d("登录成功");
      execLogin(_context!, _loginFirebaseCallback!);
    });
    _googleSignInProvider.currentUserListener((account) {
      videoDataStore.updateGoogleUser(account);
      mLogger.d("当前登陆的用户:${account?.displayName} :${account?.email} :${account?.photoUrl}");
    });
  }

  @override
  void dispose() {
    mLogger.d("执行dispose");
    videoDataStore.updateCurrentUserAccount("");
    videoDataStore.updateUserAccount("");
    videoDataStore.updateUserPassword("");
    _emailController?.dispose();
    _passwordController?.dispose();
    super.dispose();
  }

  void _buildLocalUserItem() async {
    final googleUsers = await getGoogleUsers();
    if (googleUsers != null) {
      final List<Widget> widgets = [];
      final List<ManageUser> manageGoogleUsers = ManageUsers.fromJson(googleUsers);
      for (int i = 0; i < manageGoogleUsers.length; i++) {
        final ManageUser manageUser = manageGoogleUsers[i];
        final userItem = buildUserItem(manageUser: manageUser);
        widgets.add(userItem);
      }
      videoDataStore.updateUserItemList(widgets);
    }
  }

  @override
  Widget build(BuildContext context) {
    videoDataStore = Provider.of<VideoDataStore>(context);
    final manageSettingStore = Provider.of<ManageSettingsStore>(context);
    final buttonWidth = MediaQuery.sizeOf(context).width - 30;
    if (!videoDataStore.initLoadUser) {
      videoDataStore.updateUserAccount("");
      videoDataStore.updateUserPassword("");
      _buildLocalUserItem();
      videoDataStore.updateInitLoadUser(true);
    }
    _initSettingsStatus(manageSettingStore);

    return Scaffold(
      appBar: QRAppBar(
        appbarHeight: 90,
        leftWidgetMargin: 10,
        backgroundColor: const Color(0xFFFFFFFF),
        leftSecondWidget: Observer(builder: (_) {
          return Visibility(
            visible: videoDataStore.signed,
            child: Column(
              children: [
                h3,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    w3,
                    ImageLoader.loadAssetImage(R.assetsImagesGoogleDrive, width: 13, height: 13),
                    w2,
                    Text(videoDataStore.googleUser?.email ?? "", style: MyTextStyle.textStyle400Weight(MyColor.blackColor, fontSize: 11.0))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    w3,
                    ImageLoader.loadAssetImage(R.assetsImagesFirebase, width: 13, height: 13),
                    w2,
                    Text(videoDataStore.currentUserAccount, style: MyTextStyle.textStyle400Weight(MyColor.blackColor, fontSize: 11.0))
                  ],
                )
              ],
            ),
          );
        }),
        centerWidget: Observer(builder: (_) {
          return Visibility(
            visible: !videoDataStore.signed,
            child: Text(
              videoDataStore.signed ? "管理" : "登陆",
              style: MyTextStyle.textStyle700Weight(MyColor.blackColor, fontSize: 18),
            ),
          );
        }),
        rightSecondWidget: Observer(builder: (_) {
          return Visibility(
            visible: videoDataStore.signed,
            child: InkWell(
                onTap: () async {
                  Routes.router.navigateTo(context, Routes.dailymotionPagePath);
                },
                child: ImageLoader.loadAssetImage(R.assetsImagesDailymotion, width: 20, height: 20)),
          );
        }),
        rightSecondWidgetMargin: 8,
        rightWidget: Observer(builder: (_) {
          return Visibility(
            visible: videoDataStore.signed,
            child: InkWell(
                onTap: () {
                  MyDialog.showLogoutDialog(context, () {
                    _logout();
                  });
                },
                child: ImageLoader.loadAssetImage(R.assetsImagesLogout, width: 20, height: 20)
                // Text(
                //   "退出登录",
                //   style: MyTextStyle.textStyle500Weight(MyColor.blackColor, fontSize: 15.0),
                // ),
                ),
          );
        }),
      ),
      body: Observer(builder: (_) {
        return videoDataStore.signed
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: MediaSourceManage.homeBlockList.length,
                  itemBuilder: (context, index) {
                    return _buildSeriesBlock(MediaSourceManage.homeBlockList[index], MediaSourceManage.homeBlockList[index].name);
                  },
                ),
              )
            : Column(
                children: [
                  /// 本地存储的Google账号，这个账号应该具备FireStore Database的操作权限，两者一一对应，否则整个过程无法贯通
                  Observer(builder: (_) {
                    return SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: videoDataStore.userItemList.length,
                        itemBuilder: (context, index) {
                          return videoDataStore.userItemList[index];
                        },
                      ),
                    );
                  }),
                  h25,
                  buildLoginWidget(),
                  buildLoginButton(context, width: buttonWidth, (user) async {
                    _onReceiveSignInResult(user);
                  }),
                ],
              );
      }),
    );
  }

  Widget _buildSeriesBlock(HomeListBlock homeListBlock, String title) {
    return InkWell(
      onTap: () {
        final path = '${Routes.dataFolderListPath}?collectionName=${homeListBlock.collectionName}';
        Routes.router.navigateTo(context, path);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1),
        ),
        child: Center(
          child: Text(
            title,
            style: MyTextStyle.textStyle500Weight(Colors.black, fontSize: 15),
          ),
        ),
      ),
    );
  }

  _updateLocalGoogleUsers() {
    ManageUsers.addUser(
      ManageUser(
        googleAccount: _emailController?.text ?? "",
        googlePassword: _passwordController?.text ?? "",
      ),
    );
    final usersJson = ManageUsers.toJson();
    updateGoogleUsers(usersJson);
  }

  /// 登录验证账户，获取数据库的操作权限
  Widget buildLoginWidget() {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(horizontal: 150),
      child: Column(
        children: [
          Observer(builder: (_) {
            // _emailController?.text = videoDataStore.userAccount;
            return TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: '请输入登录邮箱账号',
                suffixIcon: videoDataStore.userAccount.isNotEmpty
                    ? InkWell(
                        onTap: () {
                          _emailController?.clear();
                          _passwordController?.clear();
                          videoDataStore.updateUserAccount("");
                          videoDataStore.updateUserPassword("");
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: ImageLoader.loadIcon(R.assetsImagesClear, size: 10, iconColor: MyColor.blackColor),
                        ),
                      )
                    : null,
              ),
              onChanged: (_) {
                videoDataStore.updateUserAccount(_emailController?.text ?? "");
              },
            );
          }),
          h20,
          Observer(builder: (_) {
            return TextField(
              controller: _passwordController,
              obscureText: videoDataStore.isObscure,
              decoration: InputDecoration(
                labelText: '请输入登录邮箱密码',
                suffixIcon: videoDataStore.userPassword.isNotEmpty
                    ? InkWell(
                        onTap: () {
                          videoDataStore.updateIsObscure(!videoDataStore.isObscure);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: ImageLoader.loadIcon(
                            videoDataStore.isObscure ? R.assetsImagesInvisible : R.assetsImagesVisible,
                            size: 10,
                            iconColor: MyColor.blackColor,
                          ),
                        ),
                      )
                    : null,
              ),
              onChanged: (_) {
                videoDataStore.updateUserPassword(_passwordController?.text ?? "");
              },
            );
          }),
          h20,
        ],
      ),
    );
  }

  Widget buildUserItem({required ManageUser manageUser}) {
    return InkWell(
      onTap: () {
        videoDataStore.updateUserAccount(manageUser.googleAccount);
        videoDataStore.updateUserPassword(manageUser.googlePassword);
        videoDataStore.updateCurrentUserAccount(manageUser.googleAccount);
      },
      child: Observer(builder: (_) {
        debugPrint("更新选中的用户:${videoDataStore.currentUserAccount}");

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(color: manageUser.googleAccount == videoDataStore.currentUserAccount ? MyColor.colorFFEEEEEE : MyColor.whiteColor),
          child: Row(
            children: [
              Text(
                manageUser.googleAccount,
                style: MyTextStyle.textStyle400Weight(MyColor.blackColor, fontSize: 15),
              ),
              Spacer(),
              (manageUser.googleAccount == videoDataStore.currentUserAccount)
                  ? ImageLoader.loadAssetImage(R.assetsImagesCheckbook, width: 20, height: 20)
                  : InkWell(
                      onTap: () {
                        MyDialog.showRemoveAccountDialog(context, () {
                          ManageUsers.removeUser(manageUser);
                          final manageUsersJson = ManageUsers.toJson();
                          updateGoogleUsers(manageUsersJson);
                          _buildLocalUserItem();
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

  Widget buildLoginButton(
    BuildContext context,
    LoginFirebaseCallback loginFirebaseCallback, {
    double width = 80,
    double height = 35,
  }) {
    _context = context;
    _loginFirebaseCallback = loginFirebaseCallback;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 165),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColor.colorFF546E7A,
          foregroundColor: MyColor.whiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          elevation: 5,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          minimumSize: Size(width, height),
        ),
        onPressed: () async {
          if (_emailController?.text == null || _emailController?.text == "" || _passwordController?.text == null || _passwordController?.text == "") {
            ToastUtil.showToast("请填写登陆账户和密码");
            return;
          }
          _loginGoogle();
        },
        child: Text("登陆", style: MyTextStyle.textStyle500Weight(MyColor.whiteColor, fontSize: 15)),
      ),
    );
  }

  void execLogin(BuildContext context, LoginFirebaseCallback loginFirebaseCallback) async {
    mLogger.d("执行登陆 数据  _email:${_emailController?.text} - password:${_passwordController?.text}");
    final user = await FireStoreManager.signInWithEmailPassword(_emailController?.text ?? "", _passwordController?.text ?? "");
    if (context.mounted) {
      LoadingDialog.hideLoadingDialog(context);
    }
    loginFirebaseCallback.call(user);
  }

  /// 每次进入这个页面
  void _loginGoogle() {
    if (_googleSignInProvider.user == null) {
      LoadingDialog.showLoadingDialog(context);
      _googleSignInProvider.googleLogin();
    } else {
      execLogin(_context!, _loginFirebaseCallback!);
    }
  }

  /// 退出登陆
  void _logout() {
    _googleSignInProvider.handleSignOut((account) {});
    CommonManager.updateFirebaseUId("");
    videoDataStore.updateUserAccount("");
    videoDataStore.updateUserPassword("");
    videoDataStore.updateCurrentUserAccount("");
    videoDataStore.updateGoogleUser(null);
    videoDataStore.updateSigned(false);
  }

  Future<void> _onReceiveSignInResult(User? user) async {
    ToastUtil.showToast((user != null) ? "登录成功" : "登录失败", toastGravity: ToastGravity.CENTER);
    if (user != null) {
      final localGoogleUserJson = await getGoogleUsers();
      if (localGoogleUserJson != null) {
        final List<ManageUser> localGoogleUsers = ManageUsers.fromJson(localGoogleUserJson);
        final localManageUsers = localGoogleUsers.map((user) => user.googleAccount).toList();
        if (!localManageUsers.contains(_emailController?.text)) {
          _updateLocalGoogleUsers();
          _buildLocalUserItem();
        }
      } else {
        _updateLocalGoogleUsers();
        _buildLocalUserItem();
      }
      CommonManager.updateFirebaseUId(user.uid);
      videoDataStore.updateSigned(true);
    } else {
      CommonManager.updateFirebaseUId("");
    }
  }
}
