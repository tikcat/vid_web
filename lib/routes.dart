import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:vid_web/data/video_file_data.dart';
import 'package:vid_web/data/web_page_data.dart';
import 'package:vid_web/enum/home_list_block.dart';
import 'package:vid_web/pages/dailymotion_page.dart';
import 'package:vid_web/pages/home_page.dart';
import 'package:vid_web/pages/login_page.dart';
import 'package:vid_web/pages/manage_settings_page.dart';
import 'package:vid_web/pages/not_found_page.dart';
import 'package:vid_web/pages/splash_page.dart';

class Routes {
  static final FluroRouter router = FluroRouter();
  static final List<String> routeNameList = [];

  static const String rootPath = "/";
  static const String notFoundPath = "/not_found";
  static const String loginPath = "/login";
  static const String homePath = "/home";
  static const String shortDetailPath = "/short_detail_page";
  static const String appWebPath = "/app_web_path";
  static const String settingPath = "/setting_page";
  static const String dataFolderListPath = "/data_folder_list_page";
  static const String dailymotionPagePath = "/upload_data_dailymotion_page";

  static const String manageSettingsPagePath = "/manage_settings_page";
  static bool _initRoute = false;

  static void defineRoutes() {
    if (!_initRoute) {
      _initRoute = true;

      router.define(
        rootPath,
        transitionType: TransitionType.inFromRight,
        handler: Handler(handlerFunc: (context, parameters) => const SplashPage()),
      );
      router.define(
        loginPath,
        transitionType: TransitionType.inFromRight,
        handler: Handler(handlerFunc: (context, parameters) => const LoginPage()),
      );
      router.define(
        homePath,
        transitionType: TransitionType.inFromRight,
        handler: Handler(handlerFunc: (context, parameters) => const HomePage()),
      );
      router.define(
        notFoundPath,
        transitionType: TransitionType.inFromRight,
        handler: Handler(handlerFunc: (context, parameters) => const NotFoundPage()),
      );
      router.define(
        manageSettingsPagePath,
        transitionType: TransitionType.inFromRight,
        handler: Handler(handlerFunc: (context, parameters) => const ManageSettingsPage()),
      );
      router.define(
        dailymotionPagePath,
        transitionType: TransitionType.inFromRight,
        handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<dynamic>> parameters) {
          return UploadVideoFileToDailymotionPage();
        }),
      );
      /// 配置拦截器
      router.notFoundHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<dynamic>> params) {
        return const NotFoundPage();
      });
    }
  }

  static void routeAppWebPage(BuildContext context, WebPageData webPageData) {
    final encodedParam = Uri.encodeComponent(webPageData.toJson());
    final path = '${Routes.appWebPath}?data=$encodedParam';
    Routes.router.navigateTo(context, path);
  }

  static void routePlayDetailPage(BuildContext context, VideoFileData videoFileData) {
    if (videoFileData.sourceType == HomeListBlock.movies.sourceType
        || videoFileData.sourceType == HomeListBlock.music.sourceType
        || videoFileData.sourceType == HomeListBlock.series.sourceType
        || videoFileData.sourceType == HomeListBlock.documentary.sourceType
        || videoFileData.sourceType == HomeListBlock.cartoon.sourceType
        || videoFileData.sourceType == HomeListBlock.dramas.sourceType) {
      routeShortDetailPage(context, videoFileData);
    } else {
      Routes.router.navigateTo(context, notFoundPath);
    }
  }

  static void routeShortDetailPage(BuildContext context, VideoFileData videoFileData) {
    final encodedParam = Uri.encodeComponent(videoFileData.toJson());
    final path = '${Routes.shortDetailPath}?data=$encodedParam';
    Routes.router.navigateTo(context, path);
  }

}
