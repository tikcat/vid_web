import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/r.dart';
import 'package:vid_web/text_style.dart';
import 'package:vid_web/util/image_loader.dart';
import 'package:vid_web/widget/qr_app_bar.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QRAppBar(
        centerWidget: Text(tr("no content"), style: MyTextStyle.textStyle500Weight(MyColor.blackColor, fontSize: 18)),
        leftWidget: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: ImageLoader.loadIcon(R.assetsImagesBack, size: 20.0, iconColor: MyColor.blackColor),
        ),
        backgroundColor: MyColor.whiteColor,
      ),
      body: Center(
        child: Text(tr("no content"), style: MyTextStyle.textStyle400Weight(MyColor.blackColor, fontSize: 18)),
      ),
    );
  }
}
