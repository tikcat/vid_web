import 'package:flutter/material.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/enum/support_vid_platform.dart';
import 'package:vid_web/manager/media_source_manage.dart';
import 'package:vid_web/routes.dart';
import 'package:vid_web/text_style.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: MyColor.whiteColor),
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
