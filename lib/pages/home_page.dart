import 'package:flutter/material.dart';
import 'package:vid_web/constant/my_color.dart';

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
        child: Center(
          child: Text("首页"),

        ),
      ),
    );
  }
}
