import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
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
import 'package:vid_web/store/login_page_store.dart';
import 'package:vid_web/text_style.dart';
import 'package:vid_web/util/image_loader.dart';
import 'package:vid_web/util/my_logger.dart';
import 'package:vid_web/util/toast_util.dart';
import 'package:vid_web/widget/qr_app_bar.dart';
import 'package:vid_web/widget/video_file_item.dart';

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
  late LoginPageStore _loginPageStore;

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

  /// 查询封面
  Future<void> _readVideoCover(String videoCoverName) async {
    mLogger.d("视频封面的名称:$videoCoverName");
    if (_loginPageStore.googleUser == null) {
      ToastUtil.showToast("用户未登录");
      return;
    }
    if (_dailymotionPageStore.currentVideoType == null) {
      ToastUtil.showToast("未选择视频类型");
      return;
    }
    _dailymotionPageStore.updateVideoCoverQuerying(true);
    final videoCoverFile = await _googleDriveService.findFileByNameInFolder(
      _loginPageStore.googleUser!,
      folderName: _dailymotionPageStore.currentVideoType!.collectionName,
      fileName: videoCoverName,
    );
    mLogger.d("文件的封面 - name:${videoCoverFile?.name}  id:${videoCoverFile?.id}");
    if (videoCoverFile != null) {
      final videoCover = _googleDriveService.getImageUrl(videoCoverFile.id ?? "");
      _dailymotionPageStore.updateVideoCoverUrl(videoCover);
      _dailymotionPageStore.updateDocumentId(videoCoverFile.id ?? "");
      _dailymotionPageStore.updateShowReadVideoJson(true);

      final driveApi = await _googleDriveService.getDriveApi(_loginPageStore.googleUser!);
      final fileResponse = await driveApi.files.get(videoCoverFile.id!, downloadOptions: drive.DownloadOptions.fullMedia);
      if (fileResponse is http.Response) {
        if (fileResponse.statusCode == 200) {
          // 将文件的字节数据转换为 Uint8List
          mLogger.d("加载的封面数据  :${fileResponse.bodyBytes}");
        } else {
          debugPrint("Error fetching image from Google Drive: ${fileResponse.statusCode}");
          ToastUtil.showToast("Error fetching image from Google Drive: ${fileResponse.statusCode}");
        }
      } else {
        debugPrint("Error: Response is not of type http.Response.");
        ToastUtil.showToast("Error: Response is not of type http.Response.");
      }

      // if (videoCoverFile.mimeType!.startsWith('image/')) {
      //   final videoCover = _googleDriveService.getDriveImageUrl(videoCoverFile) ?? "";
      //   debugPrint("封面地址 - videoCover:$videoCover");
      //   _dailymotionPageStore.updateVideoCoverUrl(videoCover);
      //   _dailymotionPageStore.updateDocumentId(videoCoverFile.id ?? "");
      //   _dailymotionPageStore.updateShowReadVideoJson(true);
      // }
    } else {
      ToastUtil.showToast("未找到封面");
    }
    _dailymotionPageStore.updateVideoCoverQuerying(false);
  }

  @override
  Widget build(BuildContext context) {
    _dailymotionPageStore = Provider.of<DailymotionPageStore>(context);
    _loginPageStore = Provider.of<LoginPageStore>(context);
    debugPrint("视频封面地址:${_dailymotionPageStore.videoCoverUrl}");

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
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            _buildConfigWidget(context),
            // h20,
            // DragAndDropWidget(),
            h20,
            Expanded(
              child: Observer(builder: (_) {
                return ListView.builder(
                  itemCount: _dailymotionPageStore.videoFileDataList.length,
                  itemBuilder: (context, index) {
                    final file = _dailymotionPageStore.videoFileDataList[index];
                    return VideoFileItem(
                      videoFileData: file,
                      cover: "",
                      isAvailable: _dailymotionPageStore.isAvailable,
                      isFree: _dailymotionPageStore.isFree,
                      collectionName: "",
                      subCollectionName: "",
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigWidget(BuildContext context) {
    return Row(
      children: [
        // w10,
        // 不显示封面图片，暂时没钱付费解决
        // Observer(builder: (_) {
        //   mLogger.d("尝试显示视频封面:${_dailymotionPageStore.videoCoverUrl}");
        //   return Visibility(
        //     visible: _dailymotionPageStore.videoCoverUrl.isNotEmpty,
        //     child: IntrinsicWidth(
        //       child: ClipRRect(
        //         borderRadius: BorderRadius.only(
        //           topLeft: Radius.circular(5),
        //           topRight: Radius.circular(5),
        //           bottomLeft: Radius.circular(5),
        //           bottomRight: Radius.circular(5),
        //         ),
        //         child: Image.network(_dailymotionPageStore.videoCoverUrl, width: 35, height: 47, fit: BoxFit.cover),
        //       ),
        //     ),
        //   );
        // }),
        w10,
        _buildVideoTypeWidget(),
        _buildFreeWidget(),
        _buildAvailableWidget(),
        w10,
        _buildPicFileButton(),
        w10,
        _buildUploadButton(context),
        w10,
      ],
    );
  }

  Widget _buildVideoTypeWidget() {
    return InkWell(
      onTap: () {
        MyDialog.showVideoTypeDialog(context, _dailymotionPageStore, (homeListBlock) {
          if (homeListBlock.type == HomeListBlock.homeShort.type) {
            _dailymotionPageStore.updateShowReadVideoJson(true);
          }
        });
      },
      child: Container(
        width: 90,
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: MyColor.primaryColor, width: 1),
        ),
        child: Center(
          child: Observer(
            builder: (_) {
              return Text(
                _dailymotionPageStore.currentVideoType == null ? "视频类型" : _dailymotionPageStore.currentVideoType!.name,
                style: MyTextStyle.textStyle500Weight(MyColor.blackColor, fontSize: 14),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFreeWidget() {
    return Observer(builder: (_) {
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
    });
  }

  Widget _buildAvailableWidget() {
    return Observer(builder: (_) {
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
    });
  }

  Widget _buildPicFileButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColor.primaryColor,
        minimumSize: Size(150, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onPressed: () async {
        if (_dailymotionPageStore.currentVideoType == null) {
          ToastUtil.showToast("未选择视频类型");
          return;
        }
        _uploadFileManager.pickFile((file) async {
          if (file != null) {
            final reader = html.FileReader();
            reader.readAsText(html.File([file.bytes!], file.name));
            // 监听文件读取完成
            reader.onLoadEnd.listen((e) {
              String jsonString = reader.result as String;

              try {
                // 解析 JSON 字符串
                Map<String, dynamic> videoFileMap = jsonDecode(jsonString);
                final name = videoFileMap['name'];
                final playName = videoFileMap['playName'];
                final videoCoverName = videoFileMap['coverName'];
                debugPrint("视频的信息 name: $name - playName: $playName - videoCoverName: $videoCoverName");
                _dailymotionPageStore.setName(name);
                _dailymotionPageStore.setPlayName(playName);
                _dailymotionPageStore.updateVideoCoverName(videoCoverName);
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

  Widget _buildUploadButton(BuildContext context) {
    return Observer(builder: (_) {
      return Visibility(
        visible: _dailymotionPageStore.showUploadVideo,
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primaryColor,
                minimumSize: Size(
                  150,
                  42,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              onPressed: !_dailymotionPageStore.isUpload
                  ? () async {
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
                        mLogger.d(
                            "视频信息  videoCoverName:${_dailymotionPageStore.videoCoverName} - currentVideoType:${_dailymotionPageStore.currentVideoType} - videoCoverUrl:${_dailymotionPageStore.videoCoverUrl}");
                        if (_dailymotionPageStore.videoCoverName.isEmpty || _dailymotionPageStore.currentVideoType == null || _dailymotionPageStore.videoCoverUrl.isEmpty) {
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
                          _dailymotionPageStore.videoFileDataList[i] = videoFile;
                        }
                        if (context.mounted) {
                          _dailymotionPageStore.updateIsUpload(true);
                          LoadingDialog.hideLoadingDialog(context);
                        }
                      }
                    }
                  : null,
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
    _dailymotionPageStore.updateVideoCoverName("");
    _dailymotionPageStore.updateCurrentVideoType(null);
    _dailymotionPageStore.updateIsFree(false);
    _dailymotionPageStore.updateIsAvailable(false);
    _dailymotionPageStore.updateShowUploadVideo(false);
    _dailymotionPageStore.updateShowReadVideoJson(false);
  }
}
