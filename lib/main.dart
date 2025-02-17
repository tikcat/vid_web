import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/routes.dart';
import 'package:vid_web/store/dailymotion_page_store.dart';
import 'package:vid_web/store/login_page_store.dart';
import 'package:vid_web/store/manage_settings_store.dart';
import 'package:vid_web/store/video_data_store.dart';
import 'package:vid_web/store/video_file_list_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDSXuugJPTQOSaxmJLKu2UNnJTIKhT_pkQ",
      appId: "1:997863883560:web:693e58a63585335746461d",
      messagingSenderId: "997863883560",
      projectId: "cattv-9c0b0",
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<DailymotionPageStore>(create: (_) => DailymotionPageStore()),
        Provider<ManageSettingsStore>(create: (_) => ManageSettingsStore()),
        Provider<VideoDataStore>(create: (_) => VideoDataStore()),
        Provider<VideoFileListStore>(create: (_) => VideoFileListStore()),
        Provider<LoginPageStore>(create: (_) => LoginPageStore()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final _router = Routes.router;

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Routes.defineRoutes();
    return MaterialApp(
      title: 'VidScape',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: MyColor.primaryColor), useMaterial3: true),
      navigatorObservers: [
        FlutterSmartDialog.observer,
      ],
      builder: FlutterSmartDialog.init(),
      themeMode: ThemeMode.light,
      onGenerateRoute: _router.generator,
    );
  }
}
