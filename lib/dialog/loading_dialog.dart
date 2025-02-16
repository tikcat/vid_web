import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/store/dailymotion_page_store.dart';
import 'package:vid_web/store/video_file_list_store.dart';
import 'package:vid_web/text_style.dart';

class LoadingDialog {

  static void showLoadingProgressDialog(
      BuildContext context, {
        required VideoFileListStore videoFileListStore,
        bool barrierDismissible = false,
        double strokeWidth = 3.0,
      }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible, // 点击对话框外部不能关闭
      builder: (BuildContext context) {
        return UnconstrainedBox(
          child: SizedBox(
            width: 200,
            child: Dialog(
                backgroundColor: Colors.transparent, // 设置透明背景
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white, // 设置白色背景
                    borderRadius: BorderRadius.circular(10.0), // 圆角
                  ),
                  child: Center(
                    child: Observer(builder: (_) {
                      return Stack(
                        children: [
                          Align(alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: videoFileListStore.progress,
                            valueColor: AlwaysStoppedAnimation<Color>(MyColor.primaryColor),
                            strokeWidth: strokeWidth,
                          ),),
                          Align(
                            alignment: Alignment.center,
                            child: Text("${(videoFileListStore.progress * 100).toStringAsFixed(0)}%", style: MyTextStyle.textStyle500Weight(MyColor.primaryColor, fontSize: 13),),
                          ),
                        ],
                      );
                    }), // 显示加载进度条
                  ),
                )),
          ),
        );
      },
    );
  }

  static void showDailymotionLoadingProgressDialog(
      BuildContext context, {
        required DailymotionPageStore dailymotionPageStore,
        bool barrierDismissible = false,
        double strokeWidth = 3.0,
      }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return UnconstrainedBox(
          child: SizedBox(
            width: 200,
            child: Dialog(
                backgroundColor: Colors.transparent, // 设置透明背景
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white, // 设置白色背景
                    borderRadius: BorderRadius.circular(10.0), // 圆角
                  ),
                  child: Center(
                    child: Observer(builder: (_) {
                      return Stack(
                        children: [
                          Align(alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              value: dailymotionPageStore.progress,
                              valueColor: AlwaysStoppedAnimation<Color>(MyColor.primaryColor),
                              strokeWidth: strokeWidth,
                            ),),
                          Align(
                            alignment: Alignment.center,
                            child: Text("${(dailymotionPageStore.progress * 100).toStringAsFixed(0)}%", style: MyTextStyle.textStyle500Weight(MyColor.primaryColor, fontSize: 13),),
                          ),
                        ],
                      );
                    }), // 显示加载进度条
                  ),
                )),
          ),
        );
      },
    );
  }

  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不能关闭
      builder: (BuildContext context) {
        return UnconstrainedBox(
          child: SizedBox(
            width: 200,
            child: Dialog(
                backgroundColor: Colors.transparent, // 设置透明背景
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white, // 设置白色背景
                    borderRadius: BorderRadius.circular(10.0), // 圆角
                  ),
                  child: Center(
                    child: CircularProgressIndicator(), // 显示加载进度条
                  ),
                )),
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop(); // 关闭对话框
  }
}