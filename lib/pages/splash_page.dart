import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vid_web/data/login_account_list_data.dart';
import 'package:vid_web/manager/common_manager.dart';
import 'package:vid_web/pages/login_page.dart';
import 'package:vid_web/r.dart';
import 'package:vid_web/routes.dart';
import 'package:vid_web/size.dart';
import 'package:vid_web/store/login_page_store.dart';
import 'package:vid_web/util/image_loader.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  bool _initConfigData = false;

  Future<void> _initConfig(BuildContext context) async {
    if (!_initConfigData) {
      final loginPageStore = Provider.of<LoginPageStore>(context);
      final loginAccountListDataJson = await CommonManager.getLoginAccountsData();
      if(loginAccountListDataJson != null) {
        final loginAccountListData = LoginAccountListData.fromJson(loginAccountListDataJson);
        loginPageStore.setLoginDataList(loginAccountListData.loginDataList);
      }
      _initConfigData = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initConfig(context);
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Routes.router.navigateTo(context, Routes.loginPath);
        // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(20.0), child: ImageLoader.loadAssetImage(R.assetsImagesLogo, width: 100.0, height: 100.0)),
            ImageLoader.loadAssetImage(R.assetsImagesVidscape, width: 159, height: 64),
            h40,
          ],
        ),
      ),
    );
  }
}
