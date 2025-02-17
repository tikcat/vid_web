import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/data/video_file_data.dart';
import 'package:vid_web/dialog/loading_dialog.dart';
import 'package:vid_web/dialog/my_dialog.dart';
import 'package:vid_web/enum/home_list_block.dart';
import 'package:vid_web/manager/fire_store_manager.dart';
import 'package:vid_web/manager/google_drive_service.dart';
import 'package:vid_web/manager/upload_file_manager.dart';
import 'package:vid_web/r.dart';
import 'package:vid_web/size.dart';
import 'package:vid_web/store/dailymotion_page_store.dart';
import 'package:vid_web/text_style.dart';
import 'package:vid_web/util/image_loader.dart';
import 'package:vid_web/util/my_logger.dart';
import 'package:vid_web/util/toast_util.dart';
import 'package:vid_web/widget/drag_and_drop_widget.dart';
import 'package:vid_web/widget/qr_app_bar.dart';

class UploadVideoFileToDailymotionPage extends StatefulWidget {
  const UploadVideoFileToDailymotionPage({super.key});

  @override
  State<UploadVideoFileToDailymotionPage> createState() => _UploadVideoFileToDailymotionPageState();
}

class _UploadVideoFileToDailymotionPageState extends State<UploadVideoFileToDailymotionPage> {
  final GoogleDriveService _googleDriveService = GoogleDriveService();
  final UploadFileManager _uploadFileManager = UploadFileManager();
  TextEditingController? _videoLinkController;
  TextEditingController? _videoIntroController;
  late DailymotionPageStore _dailymotionPageStore;
  late Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _videoLinkController = TextEditingController();
    _videoIntroController = TextEditingController();
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
    _videoIntroController?.dispose();
    super.dispose();
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

  /// 查询封面
  Future<void> _readVideoCover(String videoCoverName) async {
    if (_dailymotionPageStore.googleUser == null) {
      ToastUtil.showToast("用户未登录");
      return;
    }
    if (_dailymotionPageStore.currentVideoType == null) {
      ToastUtil.showToast("未选择视频类型");
      return;
    }
    _dailymotionPageStore.updateVideoCoverQuerying(true);
    final videoCoverFile = await _googleDriveService.findFileByNameInFolder(
      _dailymotionPageStore.googleUser!,
      folderName: _dailymotionPageStore.currentVideoType!.collectionName,
      fileName: videoCoverName,
    );
    if (videoCoverFile != null) {
      if (videoCoverFile.mimeType!.startsWith('image/')) {
        final videoCover = _googleDriveService.getDriveImageUrl(videoCoverFile) ?? "";
        debugPrint("封面地址 - videoCover:$videoCover");
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
      backgroundColor: MyColor.whiteColor,
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
              h20,
              _buildPicFileButton(),
              h20,
              DragAndDropWidget(),
              h20,
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
          return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              onPressed: () {
                if (_dailymotionPageStore.currentVideoType?.type == HomeListBlock.homeShort.type) {
                  _readVideoCover(_dailymotionPageStore.videoCoverName);
                } else {
                  if (_dailymotionPageStore.videoCoverName.isEmpty) {
                    ToastUtil.showToast("请填写封面名称");
                    return;
                  }
                  _readVideoCover(_dailymotionPageStore.videoCoverName);
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

  Widget _buildPicFileButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColor.primaryColor,
        minimumSize: Size(150, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onPressed: () async {
        _uploadFileManager.pickFile((file) async {
          if (file != null) {
            final reader = html.FileReader();
            debugPrint("读取的文件 path:${file.path} - name:${file.name}");
            reader.readAsText(html.File([file.bytes!], file.name));
            // 监听文件读取完成
            reader.onLoadEnd.listen((e) {
              String jsonString = reader.result as String;
              debugPrint("读取的 JSON 内容: $jsonString");

              try {
                // 解析 JSON 字符串
                Map<String, dynamic> videoFileMap = jsonDecode(jsonString);
                _dailymotionPageStore.setName(videoFileMap['name']);
                _dailymotionPageStore.setPlayName(videoFileMap['playName']);
                final videoCoverName = videoFileMap['coverName'];
                _dailymotionPageStore.updateVideoCover(videoCoverName);
                final videoList = videoFileMap["videos"];
                debugPrint("videoList: $videoList");
                if (videoList.isNotEmpty) {
                  List<VideoFileData> videoFileDataList = [];
                  for (final video in videoList) {
                    final videoFileData = VideoFileData.fromMap(video);
                    videoFileDataList.add(videoFileData);
                  }
                  _dailymotionPageStore.updateVideoFileDataList(videoFileDataList);
                  _dailymotionPageStore.updateShowUploadVideo(true);
                }
                _readVideoCover(videoCoverName);
              } catch (e) {
                debugPrint('错误: 无法解析 JSON 文件, 错误信息: $e');
              }
            });
          } else {
            ToastUtil.showToast("请重新选择Json文件");
          }
        });
      },
      child: Text("选择文件", style: MyTextStyle.textStyle500Weight(MyColor.whiteColor, fontSize: 15)),
    );
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
