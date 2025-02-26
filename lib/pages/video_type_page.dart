import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:vid_web/constant/data_callback.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/enum/home_list_block.dart';
import 'package:vid_web/manager/media_source_manage.dart';
import 'package:vid_web/r.dart';
import 'package:vid_web/store/dailymotion_page_store.dart';
import 'package:vid_web/text_style.dart';
import 'package:vid_web/util/image_loader.dart';

class VideoTypePage extends StatelessWidget {
  final DailymotionPageStore dailymotionPageStore;
  final HomeTypeCallback onTap;

  const VideoTypePage({
    super.key,
    required this.dailymotionPageStore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(child: Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: MyColor.whiteColor),
      padding: EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(children: _buildLocalUserItem(context)),
      ),
    ),);
  }

  List<Widget> _buildLocalUserItem(BuildContext context) {
    final videoTypeList = MediaSourceManage.homeBlockList;
    final List<Widget> itemList = [];
    for (var value in videoTypeList) {
      final item = buildUserItem(context, homeListBlock: value);
      itemList.add(item);
    }
    return itemList;
  }

  Widget buildUserItem(BuildContext context, {required HomeListBlock homeListBlock}) {
    return InkWell(
      onTap: () {
        dailymotionPageStore.updateCurrentVideoType(homeListBlock);
        onTap.call(homeListBlock);
        Navigator.of(context).pop();
      },
      child: Observer(builder: (_) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(color: homeListBlock == dailymotionPageStore.currentVideoType ? MyColor.colorFFEEEEEE : MyColor.whiteColor),
          child: Row(
            children: [
              Text(homeListBlock.name, style: MyTextStyle.textStyle400Weight(MyColor.blackColor, fontSize: 15)),
              Spacer(),
              (homeListBlock == dailymotionPageStore.currentVideoType)
                  ? ImageLoader.loadAssetImage(R.assetsImagesCheckbook, width: 20, height: 20)
                  : const SizedBox(),
            ],
          ),
        );
      }),
    );
  }
}
