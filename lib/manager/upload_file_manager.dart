import 'dart:html' as html;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/cupertino.dart';
import 'package:vid_web/constant/data_callback.dart';

class UploadFileManager {

  void clearFile() {
    FilePicker.platform.clearTemporaryFiles();
  }



  /// 选择单个文件
  Future<void> pickFile(PicFileCallback callback) async {
    // 使用 file_picker 选择文件
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      callback.call(file);
    } else {
      // 用户取消了选择
      debugPrint('No file selected');
    }
  }

  /// 选择多个文件
  Future<void> pickMultipleFiles(MultiplyPicFileCallback callback) async {
    // 允许用户选择多个文件
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      // 选择到的文件信息
      List<PlatformFile> files = result.files;
      callback.call(files);
    } else {
      debugPrint('No files selected');
    }
  }

  /// 选择特定类型的文件
  Future<void> pickFilesWithFilter(PicFileCallback callback) async {
    // 选择特定类型的文件（例如文本文件）
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,  // 使用自定义文件类型
      allowedExtensions: ['txt', 'pdf', 'json'],  // 允许选择的文件扩展名
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      callback.call(file);
    } else {
      debugPrint('No file selected');
    }
  }


  void readJsonFile() async {
    if (kIsWeb) {
      // 打开文件选择器
      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = '.json'; // 限定为只允许选择 JSON 文件
      uploadInput.click();

      // 监听文件选择事件
      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files!.isEmpty) return;

        final file = files[0];
        final reader = html.FileReader();

        // 读取文件内容
        reader.readAsText(file);
        reader.onLoadEnd.listen((e) {
          // 读取完成后解析 JSON
          final jsonContent = jsonDecode(reader.result as String);
          debugPrint(jsonContent);
          // 你可以在这里处理 jsonContent 数据
        });
      });
    }
  }
}
