import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/enum/support_vid_platform.dart';
import 'package:vid_web/manager/media_source_manage.dart';
import 'package:vid_web/routes.dart';
import 'package:vid_web/size.dart';
import 'package:vid_web/store/login_page_store.dart';
import 'package:vid_web/text_style.dart';
import 'package:vid_web/util/image_loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final loginPageStore = Provider.of<LoginPageStore>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: MyColor.whiteColor),
        child: Column(
          children: [
            Visibility(
              visible: loginPageStore.user != null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                decoration: BoxDecoration(color: MyColor.whiteColor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ImageLoader.loadNetImageCache(
                      loginPageStore.user?.photoURL ?? "",
                      width: 36,
                      height: 36,
                      ltCornerRadius: 20,
                      rtCornerRadius: 20,
                      lbCornerRadius: 20,
                      rbCornerRadius: 20,
                    ),
                    w8,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loginPageStore.user?.displayName ?? "", style: MyTextStyle.textStyle600Weight(Colors.black, fontSize: 15)),
                        h3,
                        Text(loginPageStore.user?.email ?? "", style: MyTextStyle.textStyle500Weight(Colors.grey[850]!, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: MediaSourceManage.supportVidPlatformList.length,
                itemBuilder: (context, index) {
                  return _buildSeriesBlock(MediaSourceManage.supportVidPlatformList[index]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesBlock(SupportVidPlatform supportVidPlatform) {
    return InkWell(
      onTap: () {
        Routes.routeUploadPlatformPage(context, supportVidPlatform);
      },
      child: Container(
        decoration: BoxDecoration(color: MyColor.colorFFFAFAFA, borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: Text(supportVidPlatform.name, style: MyTextStyle.textStyle500Weight(Colors.black, fontSize: 15)),
        ),
      ),
    );
  }
}
