import 'package:flutter/material.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/data/video_file_data.dart';
import 'package:vid_web/manager/fire_store_manager.dart';
import 'package:vid_web/size.dart';
import 'package:vid_web/text_style.dart';
import 'package:vid_web/util/image_loader.dart';
import 'package:vid_web/util/my_logger.dart';

class VideoFileItem extends StatefulWidget {
  final VideoFileData? videoFileData;
  final String cover;
  /// 是否上架
  final bool isAvailable;
  /// 是否免费
  final bool isFree;
  final String collectionName;
  final String subCollectionName;

  const VideoFileItem({
    super.key,
    this.videoFileData,
    required this.cover,
    required this.isAvailable,
    required this.isFree,
    required this.collectionName,
    required this.subCollectionName,
  });

  @override
  State<VideoFileItem> createState() => _VideoFileItemState();
}

class _VideoFileItemState extends State<VideoFileItem> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    mLogger.d("封面图片:${widget.videoFileData?.cover}");
    if (widget.videoFileData == null) {
      return Center(
        child: Text("文件数据为空", style: MyTextStyle.textStyle400Weight(MyColor.blackColor, fontSize: 15)),
      );
    } else {
      return Container(
        padding: const EdgeInsets.only(top: 17, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            w10,
            if (widget.videoFileData!.cover.isNotEmpty)
              IntrinsicWidth(
                child: ImageLoader.loadNetImageCache(
                  widget.videoFileData!.cover,
                  ltCornerRadius: 2,
                  rtCornerRadius: 2,
                  lbCornerRadius: 2,
                  rbCornerRadius: 2,
                  width: 27,
                  height: 37,
                ),
              ),
            if (widget.videoFileData!.cover.isEmpty)
              Icon(
                Icons.insert_drive_file,
                size: 44,
                color: MyColor.colorFFBDBDBD,
              ),
            w5,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.videoFileData!.fileName,
                    style: MyTextStyle.textStyle600Weight(MyColor.blackColor, fontSize: 14),
                  ),
                  h2,
                  // Text(videoFileData.videoUrl, style: MyTextStyle.textStyle400Weight(MyColor.blackColor, fontSize: 11)),
                ],
              ),
            ),
            w6,
            // _buildDeleteButton(),
            // _buildUploadButton(),
            w10,
          ],
        ),
      );
    }
  }

  _excUpload() async {
    _uploadVideoFile();
  }

  _excDelete() async {
    setState(() {
      _isLoading = true;
    });
    final result = await FireStoreManager.deleteChildDocument(
      rootCollectionName: widget.collectionName,
      childCollectionName: widget.subCollectionName,
      childDocumentId: widget.videoFileData!.documentId,
    );
    setState(() {
      _isLoading = false;
      if (result) {
        widget.videoFileData!.isUploaded = false;
      }
    });
    mLogger.d("文件删除的结果 result:$result");
  }

  _uploadVideoFile() async {
    setState(() {
      _isLoading = true;
    });
    // 向子集合里边添加数据
    final result = await FireStoreManager.uploadData(
      rootCollectionName: widget.collectionName,
      childCollectionName: widget.subCollectionName,
      childCollectionData: widget.videoFileData!.toMap(),
    );
    setState(() {
      _isLoading = false;
      widget.videoFileData!.isUploaded = result;
    });
    mLogger.d("文件上传的结果 result:$result");
  }

  Widget _buildDeleteButton() {
    return Visibility(
        visible: widget.videoFileData!.isUploaded,
        child: InkWell(
          onTap: () {
            _excDelete();
          },
          child: Container(
            width: 57,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isLoading ? MyColor.transparentColor : MyColor.colorFF4CAF50,
                width: _isLoading ? 0 : 1.0,
              ),
              color: _isLoading ? MyColor.transparentColor : MyColor.colorFF4CAF50,
              borderRadius: BorderRadius.circular(5),
            ),
            child: _isLoading
                ? Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: MyColor.colorFF4CAF50,
                        strokeWidth: 2.0,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      widget.videoFileData!.isUploaded ? "删除" : "",
                      style: MyTextStyle.textStyle400Weight(MyColor.whiteColor, fontSize: 13),
                    ),
                  ),
          ),
        ));
  }

  /// 上传按钮
  Widget _buildUploadButton() {
    return Visibility(
      visible: !widget.videoFileData!.isUploaded,
      child: InkWell(
        onTap: () {
          _excUpload();
        },
        child: Container(
          width: 57,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(
              color: _isLoading ? MyColor.transparentColor : (widget.videoFileData!.isUploaded ? MyColor.colorFF4CAF50 : MyColor.primaryColor),
              width: _isLoading ? 0 : 1.0,
            ),
            color: _isLoading
                ? MyColor.transparentColor
                : widget.videoFileData!.isUploaded
                    ? MyColor.colorFF4CAF50
                    : MyColor.primaryColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: _isLoading
              ? Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: MyColor.primaryColor,
                      strokeWidth: 2.0,
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    widget.videoFileData!.isUploaded ? "已上传" : "未上传",
                    style: MyTextStyle.textStyle400Weight(MyColor.whiteColor, fontSize: 13),
                  ),
                ),
        ),
      ),
    );
  }
}
