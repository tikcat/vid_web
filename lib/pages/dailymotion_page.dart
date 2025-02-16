import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/data/video_file_data.dart';
import 'package:vid_web/dialog/loading_dialog.dart';
import 'package:vid_web/dialog/my_dialog.dart';
import 'package:vid_web/enum/home_list_block.dart';
import 'package:vid_web/manager/fire_store_manager.dart';
import 'package:vid_web/manager/google_drive_service.dart';
import 'package:vid_web/manager/google_sign_in_provider.dart';
import 'package:vid_web/r.dart';
import 'package:vid_web/size.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vid_web/store/dailymotion_page_store.dart';
import 'package:vid_web/text_style.dart';
import 'package:vid_web/util/image_loader.dart';
import 'package:vid_web/util/my_logger.dart';
import 'package:vid_web/util/toast_util.dart';
import 'package:vid_web/widget/qr_app_bar.dart';

class UploadVideoFileToDailymotionPage extends StatefulWidget {
  const UploadVideoFileToDailymotionPage({super.key});

  @override
  State<UploadVideoFileToDailymotionPage> createState() => _UploadVideoFileToDailymotionPageState();
}

class _UploadVideoFileToDailymotionPageState extends State<UploadVideoFileToDailymotionPage> {
  final GoogleDriveService _googleDriveService = GoogleDriveService();
  TextEditingController? _videoLinkController;
  TextEditingController? _videoCoverController;
  TextEditingController? _videoIntroController;
  late DailymotionPageStore _dailymotionPageStore;
  late Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _videoLinkController = TextEditingController();
    _videoCoverController = TextEditingController();
    _videoIntroController = TextEditingController();

    _requestPermissions();
  }

  @override
  void dispose() {
    _dailymotionPageStore.updateVideoUploading(false);
    _dailymotionPageStore.updateVideoCoverUrl("");
    _dailymotionPageStore.updateIsAvailable(false);
    _dailymotionPageStore.updateCurrentVideoType(null);
    _dailymotionPageStore.updateIsFree(false);
    _dailymotionPageStore.updateCurrentVideoFileLanguage("");
    _dailymotionPageStore.updateVideoCoverQuerying(false);
    _dailymotionPageStore.updateVideoFileDataListQuerying(false);
    _dailymotionPageStore.updateShowUploadVideo(false);
    _dailymotionPageStore.updateShowReadVideoJson(false);
    _dailymotionPageStore.updateVideoFileDataList([]);
    _dailymotionPageStore.updateVideoCoverName("");
    _dailymotionPageStore.updateProgress(0.0);
    _videoLinkController?.dispose();
    _videoCoverController?.dispose();
    _videoIntroController?.dispose();
    super.dispose();
  }

  // 请求存储权限
  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      _loadJsonData();
    } else {
      mLogger.d("权限被拒绝");
    }
  }

  Future<void> _readAssetsJson() async {
    if (_dailymotionPageStore.currentVideoType == null) {
      ToastUtil.showToast("未选择视频类型");
      return;
    }
    String response = "";
    if (_dailymotionPageStore.currentVideoType?.type == HomeListBlock.cartoon.type) {
      response = await rootBundle.loadString('assets/data/cartoon.json');
    } else if (_dailymotionPageStore.currentVideoType?.type == HomeListBlock.movies.type) {
      response = await rootBundle.loadString('assets/data/movie.json');
    } else if (_dailymotionPageStore.currentVideoType?.type == HomeListBlock.series.type) {
      response = await rootBundle.loadString('assets/data/series.json');
    } else if (_dailymotionPageStore.currentVideoType?.type == HomeListBlock.dramas.type) {
      response = await rootBundle.loadString('assets/data/dramas.json');
    } else if (_dailymotionPageStore.currentVideoType?.type == HomeListBlock.homeShort.type) {
      response = await rootBundle.loadString('assets/data/home_short.json');
    }

    // 解析 JSON 数据
    if (response.isNotEmpty) {
      final data = jsonDecode(response);
      mLogger.d("读取的json文件  -  data:$data");
      var videoList = data["videos"];
      if (videoList.isNotEmpty) {
        List<VideoFileData> videoFileDataList = [];
        for (final video in videoList) {
          final videoFileData = VideoFileData.fromMap(video);
          videoFileDataList.add(videoFileData);
        }
        _dailymotionPageStore.updateVideoFileDataList(videoFileDataList);
        _dailymotionPageStore.updateShowUploadVideo(true);
      }
    } else {
      ToastUtil.showToast("解析 JSON 数据为空");
    }
  }

  // 读取 Documents 文件夹下的 JSON 文件
  Future<void> _loadJsonData() async {
    // 获取存储路径
    final directory = await getExternalStorageDirectory();
    if (directory == null) return;

    // 获取指定文件夹下的文件路径
    final folderPath = "${directory.path}/Documents"; // 假设你的JSON文件在 Documents 文件夹下
    final folder = Directory(folderPath);

    // 检查文件夹是否存在
    if (await folder.exists()) {
      // 获取文件夹下所有文件
      final files = folder.listSync();
      for (var file in files) {
        if (file.path.endsWith('.json')) {
          // 检查是否是 .json 文件
          String content = await File(file.path).readAsString();
          // 解析 JSON 数据
          var jsonData = jsonDecode(content);
          setState(() {
            _data = jsonData; // 假设JSON文件的内容是列表格式
          });
        }
      }
    } else {
      mLogger.e("文件夹不存在");
    }
  }

  /// 查询封面
  Future<void> _readVideoFileList(String videoCoverName) async {
    final user = GoogleSignInProvider.instance.user;
    if (user == null) {
      ToastUtil.showToast("用户未登录");
      return;
    }
    if (_dailymotionPageStore.currentVideoType == null) {
      ToastUtil.showToast("未选择视频类型");
      return;
    }
    _dailymotionPageStore.updateVideoCoverQuerying(true);
    final videoCoverFile = await _googleDriveService.findFileByNameInFolder(user,
        folderName: _dailymotionPageStore.currentVideoType!.collectionName, fileName: videoCoverName);
    if (videoCoverFile != null) {
      if (videoCoverFile.mimeType!.startsWith('image/')) {
        final videoCover = _googleDriveService.getDriveImageUrl(videoCoverFile) ?? "";
        _dailymotionPageStore.updateVideoCoverUrl(videoCover);
        _dailymotionPageStore.updateDocumentId(videoCoverFile.id ?? "");
        _dailymotionPageStore.updateShowReadVideoJson(true);
      }
    } else {
      ToastUtil.showToast("未找到封面");
    }
    _dailymotionPageStore.updateVideoCoverQuerying(false);
  }

  @override
  Widget build(BuildContext context) {
    _dailymotionPageStore = Provider.of<DailymotionPageStore>(context);

    return Scaffold(
      appBar: QRAppBar(
        appbarHeight: 90,
        leftWidgetMargin: 10,
        backgroundColor: const Color(0xFFFFFFFF),
        leftWidget: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: ImageLoader.loadIcon(R.assetsImagesBack, iconColor: Colors.black, size: 20),
        ),
        centerWidget: Text("Dailymotion", style: MyTextStyle.textStyle500Weight(MyColor.blackColor, fontSize: 17)),
        rightWidget: Observer(builder: (_) {
          return Visibility(
              visible: _dailymotionPageStore.showUploadVideo,
              child: InkWell(
                onTap: () {
                  _reset();
                },
                child: ImageLoader.loadIcon(R.assetsImagesReset, size: 22, iconColor: MyColor.blackColor),
              ));
        }),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              _buildConfigWidget(context),
              Row(
                children: [
                  _buildCoverTextField(),
                  w8,
                  Observer(builder: (_) {
                    return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColor.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        onPressed: () {
                          if (_dailymotionPageStore.currentVideoType?.type == HomeListBlock.homeShort.type) {
                            _readVideoFileList(_dailymotionPageStore.videoCoverName);
                          } else {
                            if (_dailymotionPageStore.videoCoverName.isEmpty) {
                              ToastUtil.showToast("请填写封面名称");
                              return;
                            }
                            _readVideoFileList(_dailymotionPageStore.videoCoverName);
                          }
                        },
                        child: _dailymotionPageStore.videoCoverQuerying
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: MyColor.whiteColor),
                              )
                            : Text("查询", style: MyTextStyle.textStyle500Weight(MyColor.whiteColor, fontSize: 14)));
                  }),
                ],
              ),
              _buildReadVideoSourceButton(),
              _buildUploadButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigWidget(BuildContext context) {
    return Row(
      children: [
        w10,
        Observer(builder: (_) {
          return Visibility(
            visible: _dailymotionPageStore.videoCoverUrl.isNotEmpty,
            child: IntrinsicWidth(
              child: ImageLoader.loadNetImageCache(
                _dailymotionPageStore.videoCoverUrl,
                ltCornerRadius: 2,
                rtCornerRadius: 2,
                lbCornerRadius: 2,
                rbCornerRadius: 2,
                width: 35,
                height: 47,
              ),
            ),
          );
        }),
        w10,
        InkWell(
          onTap: () {
            MyDialog.showVideoTypeDialog(context, _dailymotionPageStore, (homeListBlock) {
              if (homeListBlock.type == HomeListBlock.homeShort.type) {
                _dailymotionPageStore.updateShowReadVideoJson(true);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: MyColor.primaryColor, width: 1),
            ),
            child: Observer(builder: (_) {
              return Text(
                _dailymotionPageStore.currentVideoType == null ? "视频类型" : _dailymotionPageStore.currentVideoType!.name,
                style: MyTextStyle.textStyle500Weight(MyColor.blackColor, fontSize: 14),
              );
            }),
          ),
        ),
        Observer(builder: (_) {
          return Column(
            children: [
              Text(
                !_dailymotionPageStore.isFree ? "收费" : "免费",
                style: MyTextStyle.textStyle500Weight(MyColor.blackColor, fontSize: 12),
              ),
              Transform.scale(
                scale: 0.5,
                alignment: Alignment.topCenter,
                child: Observer(builder: (context) {
                  return Switch(
                    value: _dailymotionPageStore.isFree,
                    activeColor: MyColor.colorFFFF3D00,
                    activeTrackColor: MyColor.colorFFFF9E80,
                    inactiveThumbColor: MyColor.colorFF546E7A,
                    inactiveTrackColor: MyColor.colorFFEEEEEE,
                    onChanged: (value) {
                      if (_dailymotionPageStore.currentVideoType != null && _dailymotionPageStore.videoCoverName.isNotEmpty) {
                        final videoCoverName = _dailymotionPageStore.videoCoverName.substring(_dailymotionPageStore.videoCoverName.indexOf("."));
                        final languageCodeStartIndex = videoCoverName.lastIndexOf("_");
                        var playName = videoCoverName.substring(0, languageCodeStartIndex);
                        if (playName.contains("(")) {
                          playName = playName.substring(0, playName.indexOf("("));
                        }

                        FireStoreManager.updateEpisodeIsFreeStatus(
                          rootCollectionName: _dailymotionPageStore.currentVideoType!.collectionName,
                          childCollectionName: playName,
                          isFree: value,
                        );
                        _dailymotionPageStore.updateIsFree(value);
                      }
                    },
                  );
                }),
              ),
            ],
          );
        }),
        Observer(builder: (_) {
          return Column(
            children: [
              Text(
                _dailymotionPageStore.isAvailable ? "已上架" : "未上架",
                style: MyTextStyle.textStyle500Weight(MyColor.blackColor, fontSize: 13),
              ),
              Transform.scale(
                scale: 0.5,
                alignment: Alignment.topCenter,
                child: Observer(builder: (context) {
                  return Switch(
                    value: _dailymotionPageStore.isAvailable,
                    activeColor: MyColor.colorFFFF3D00,
                    activeTrackColor: MyColor.colorFFFF9E80,
                    inactiveThumbColor: MyColor.colorFF546E7A,
                    inactiveTrackColor: MyColor.colorFFEEEEEE,
                    onChanged: (value) async {
                      if (_dailymotionPageStore.currentVideoType?.sourceType == HomeListBlock.homeShort.sourceType) {
                        if (context.mounted) {
                          LoadingDialog.showLoadingDialog(context);
                        }
                        await FireStoreManager.updateEpisodeAvailableStatus(
                          rootCollectionName: _dailymotionPageStore.currentVideoType!.collectionName,
                          isAvailable: value,
                        );
                        if (context.mounted) {
                          LoadingDialog.hideLoadingDialog(context);
                        }
                        _dailymotionPageStore.updateIsAvailable(value);
                      } else {
                        if (_dailymotionPageStore.currentVideoType != null && _dailymotionPageStore.videoCoverName.isNotEmpty) {
                          final videoCoverName = _dailymotionPageStore.videoCoverName.substring(0, _dailymotionPageStore.videoCoverName.lastIndexOf("."));
                          final languageCodeStartIndex = videoCoverName.lastIndexOf("_");
                          var playName = videoCoverName.substring(0, languageCodeStartIndex);
                          if (playName.contains("(")) {
                            playName = playName.substring(0, playName.indexOf("("));
                          }

                          if (context.mounted) {
                            LoadingDialog.showLoadingDialog(context);
                          }
                          await FireStoreManager.updateEpisodeAvailableStatus(
                            rootCollectionName: _dailymotionPageStore.currentVideoType!.collectionName,
                            isAvailable: value,
                          );
                          if (context.mounted) {
                            LoadingDialog.hideLoadingDialog(context);
                          }
                          _dailymotionPageStore.updateIsAvailable(value);
                        }
                      }
                    },
                  );
                }),
              ),
            ],
          );
        }),
        w10,
      ],
    );
  }

  Widget _buildCoverTextField() {
    return Observer(builder: (_) {
      _videoCoverController?.text = _dailymotionPageStore.videoCoverName;
      return Expanded(
        child: TextField(
          controller: _videoCoverController,
          style: MyTextStyle.textStyle500Weight(MyColor.blackColor, fontSize: 14),
          decoration: InputDecoration(
            labelText: '请填写视频封面名称',
            suffixIcon: _dailymotionPageStore.videoCoverName.isNotEmpty
                ? InkWell(
                    onTap: () {
                      _videoCoverController?.clear();
                      _dailymotionPageStore.updateVideoCoverName("");
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 20, left: 12, right: 12, bottom: 4),
                      child: ImageLoader.loadIcon(R.assetsImagesClear, iconColor: MyColor.blackColor, size: 8),
                    ),
                  )
                : null,
          ),
          onChanged: (_) {
            _dailymotionPageStore.updateVideoCoverName(_videoCoverController?.text ?? "");
          },
        ),
      );
    });
  }

  Widget _buildReadVideoSourceButton() {
    return Observer(builder: (_) {
      return Visibility(
        visible: _dailymotionPageStore.showReadVideoJson,
        child: Column(
          children: [
            h10,
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primaryColor,
                minimumSize: Size(150, 42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              onPressed: () async {
                _readAssetsJson();
              },
              child: _dailymotionPageStore.videoFileDataListQuerying
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: MyColor.whiteColor),
                    )
                  : Text("查询视频资源", style: MyTextStyle.textStyle500Weight(MyColor.whiteColor, fontSize: 15)),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildUploadButton(BuildContext context) {
    return Observer(builder: (_) {
      return Visibility(
        visible: _dailymotionPageStore.showUploadVideo,
        child: Column(
          children: [
            h10,
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primaryColor,
                minimumSize: Size(
                  150,
                  42,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              onPressed: () async {
                if (_dailymotionPageStore.currentVideoType?.type == HomeListBlock.homeShort.type) {
                  LoadingDialog.showDailymotionLoadingProgressDialog(context, dailymotionPageStore: _dailymotionPageStore);
                  final total = _dailymotionPageStore.videoFileDataList.length;
                  for (int i = 0; i < total; i++) {
                    final videoFile = _dailymotionPageStore.videoFileDataList[i];
                    if (total > 3 && i < 2) {
                      videoFile.isFree = true;
                    }
                    videoFile.isUploaded = true;
                    videoFile.documentId = _dailymotionPageStore.documentId;
                    videoFile.position = i;
                    videoFile.timestamp = DateTime.now().millisecondsSinceEpoch;
                    await FireStoreManager.createCollectionAndAddDocument(
                      rootCollectionName: _dailymotionPageStore.currentVideoType!.collectionName,
                      childCollectionName: videoFile.playName,
                      childCollectionData: videoFile.toMap(),
                    );
                    final currentProgress = (i + 1) / total;
                    _dailymotionPageStore.updateProgress(currentProgress);
                  }
                  if (context.mounted) {
                    LoadingDialog.hideLoadingDialog(context);
                  }
                } else {
                  if (_dailymotionPageStore.videoCoverName.isEmpty == true ||
                      _dailymotionPageStore.currentVideoType == null ||
                      _dailymotionPageStore.videoCoverUrl.isEmpty) {
                    ToastUtil.showToast("请填写完整信息");
                    return;
                  }
                  LoadingDialog.showDailymotionLoadingProgressDialog(context, dailymotionPageStore: _dailymotionPageStore);
                  final videoCoverName = _dailymotionPageStore.videoCoverName.substring(0, _dailymotionPageStore.videoCoverName.lastIndexOf("."));
                  final sourceType = _dailymotionPageStore.currentVideoType!.sourceType;
                  final languageCodeStartIndex = videoCoverName.lastIndexOf("_");
                  String languageCode = videoCoverName.substring(languageCodeStartIndex + 1).toString().trim();
                  _dailymotionPageStore.updateCurrentVideoFileLanguage(languageCode);
                  final languageCountry = languageCode.split("-");

                  final total = _dailymotionPageStore.videoFileDataList.length;
                  for (int i = 0; i < total; i++) {
                    final videoFile = _dailymotionPageStore.videoFileDataList[i];

                    /// 总集数大于3，前两集免费
                    // todo 所有的旅行博主vLog全部免费
                    if (total >= 3 && i < 2) {
                      videoFile.isFree = true;
                    }
                    videoFile.isUploaded = true;
                    videoFile.isAvailable = _dailymotionPageStore.isAvailable;
                    videoFile.sourceType = sourceType;
                    videoFile.country = languageCountry[1];
                    videoFile.languageCode = languageCode;
                    videoFile.documentId = _dailymotionPageStore.documentId;
                    videoFile.cover = _dailymotionPageStore.videoCoverUrl;
                    videoFile.position = i;
                    videoFile.timestamp = DateTime.now().millisecondsSinceEpoch;
                    await FireStoreManager.createCollectionAndAddDocument(
                      rootCollectionName: _dailymotionPageStore.currentVideoType!.collectionName,
                      childCollectionName: videoFile.playName,
                      childCollectionData: videoFile.toMap(),
                    );
                    final currentProgress = (i + 1) / total;
                    _dailymotionPageStore.updateProgress(currentProgress);
                  }
                  if (context.mounted) {
                    LoadingDialog.hideLoadingDialog(context);
                  }
                }
              },
              child: _dailymotionPageStore.videoUploading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: MyColor.whiteColor),
                    )
                  : Text(_dailymotionPageStore.isUpload ? "已上传" : "上传", style: MyTextStyle.textStyle500Weight(MyColor.whiteColor, fontSize: 15)),
            ),
          ],
        ),
      );
    });
  }

  void _reset() {
    _dailymotionPageStore.updateVideoCover("");
    _dailymotionPageStore.updateVideoCoverName("");
    _dailymotionPageStore.updateCurrentVideoType(null);
    _dailymotionPageStore.updateIsFree(false);
    _dailymotionPageStore.updateIsAvailable(false);
    _dailymotionPageStore.updateShowUploadVideo(false);
    _dailymotionPageStore.updateShowReadVideoJson(false);
  }
}
