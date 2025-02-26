import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/manager/common_manager.dart';
import 'package:vid_web/r.dart';
import 'package:vid_web/size.dart';
import 'package:vid_web/store/manage_settings_store.dart';
import 'package:vid_web/text_style.dart';
import 'package:vid_web/util/image_loader.dart';
import 'package:vid_web/widget/qr_app_bar.dart';

class ManageSettingsPage extends StatefulWidget {
  const ManageSettingsPage({super.key});

  @override
  State<ManageSettingsPage> createState() => _ManageSettingsPageState();
}

class _ManageSettingsPageState extends State<ManageSettingsPage> {


  @override
  Widget build(BuildContext context) {
    final manageSettingStore = Provider.of<ManageSettingsStore>(context);

    return Scaffold(
      appBar: QRAppBar(
        backgroundColor: MyColor.whiteColor,
        leftWidget: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: ImageLoader.loadIcon(R.assetsImagesBack, iconColor: Colors.black, size: 19.5),
        ),
        centerWidget: Text(
          "设置",
          style: MyTextStyle.textStyle500Weight(MyColor.blackColor, fontSize: 17),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: MyColor.whiteColor
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  w10,
                  Text(
                    "自动上架",
                    style: MyTextStyle.textStyle500Weight(MyColor.blackColor, fontSize: 14),
                  ),
                  const Spacer(),
                  Transform.scale(
                    scale: 0.7,
                    child: Observer(builder: (context) {
                      return Switch(
                        value: manageSettingStore.autoAvailable,
                        activeColor: MyColor.colorFFFF3D00,
                        activeTrackColor: MyColor.colorFFFF9E80,
                        inactiveThumbColor: MyColor.colorFF546E7A,
                        inactiveTrackColor: MyColor.colorFFEEEEEE,
                        onChanged: (value) {
                          CommonManager.updateAutoUpload(value);
                          manageSettingStore.updateAutoAvailable(value);
                        },
                      );
                    }),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
