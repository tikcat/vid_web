import 'package:flutter/material.dart';
import 'package:vid_web/pages/login_page.dart';
import 'package:vid_web/pages/manage_home_page.dart';
import 'package:vid_web/r.dart';
import 'package:vid_web/size.dart';
import 'package:vid_web/util/image_loader.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
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
