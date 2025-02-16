import 'package:flutter/material.dart';
import 'package:vid_web/constant/data_callback.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/pages/video_type_page.dart';
import 'package:vid_web/store/dailymotion_page_store.dart';
import 'package:vid_web/text_style.dart';

class MyDialog {

  /// 视频类型弹窗
  static void showVideoTypeDialog(BuildContext context, DailymotionPageStore dailymotionPageStore, HomeTypeCallback homeTypeCallback) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return VideoTypePage(dailymotionPageStore: dailymotionPageStore, onTap: homeTypeCallback);
        });
  }

  static void showLogoutDialog(BuildContext context, LogoutCallback logoutCallback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MyColor.whiteColor,
        title: Text('退出登录'),
        content: Text('退出当前账号?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              logoutCallback.call();
              Navigator.of(context).pop();
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  static void showRemoveAccountDialog(BuildContext context, VoidCallback removeCallback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MyColor.whiteColor,
        title: Text('移除账号'),
        content: Text('要移除当前账号?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              removeCallback.call();
              Navigator.of(context).pop();
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 退出登录
  static void showLogoutDialog2(
    BuildContext context, {
    required LogoutCallback logoutCallback,
    String title = "",
    String tip = "",
    String cancelText = "",
    String sureText = "",
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MyColor.whiteColor,
        title: Text(title, style: MyTextStyle.textStyle500Weight(MyColor.blackColor, fontSize: 16)),
        content: Text(
          tip,
          style: MyTextStyle.textStyle500Weight(MyColor.blackColor, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText, style: MyTextStyle.textStyle500Weight(MyColor.blackColor, fontSize: 16)),
          ),
          TextButton(
            onPressed: () async {
              logoutCallback.call();
              Navigator.of(context).pop();
            },
            child: Text(sureText, style: MyTextStyle.textStyle500Weight(MyColor.blackColor, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
