import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vid_web/constant/my_color.dart';
import 'package:vid_web/text_style.dart';

class DragAndDropWidget extends StatefulWidget {
  const DragAndDropWidget({super.key});

  @override
  State<DragAndDropWidget> createState() => _DragAndDropWidgetState();
}

class _DragAndDropWidgetState extends State<DragAndDropWidget> {
  String _fileContent = "请拖动文件到此处";
  bool _fileEnter = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // This can be used to update drag position or styling, if needed.
      },
      child: MouseRegion(
        onEnter: (_) {
          // Optional: Add some visual feedback when dragging over the area.
          setState(() {
            _fileEnter = true;
          });
        },
        onExit: (_) {
          // Optional: Reset visual feedback when dragging out of the area.
          setState(() {
            _fileEnter = false;
          });
        },
        child: DragTarget<html.File>(
          onWillAccept: (data) {
            debugPrint("onWillAccept: $data");
            return true;
          },
          onAcceptWithDetails: (details) {
            debugPrint("文件拖动到目标区域  data:${details.data.toString()} - DataName:${details.data.name}");
            _readFile(details.data);
          },
          onAccept: (file) {
            debugPrint("文件被接受 fileName:${file.name}");
            _readFile(file);
          },
          builder: (context, candidateData, rejectedData) {
            return Listener(
              onPointerDown: (event) {
                final dataTransfer = (event as html.PointerEvent).dataTransfer;
                if (dataTransfer != null) {
                  dataTransfer.dropEffect = 'copy';
                }
              },
              onPointerUp: (event) {
                final dataTransfer = (event as html.PointerEvent).dataTransfer;
                if (dataTransfer.files?.isNotEmpty == true) {
                  final file = dataTransfer.files?.first;
                  if (file != null) {
                    debugPrint("文件被接受 fileName:${file.name}");
                    _readFile(file);
                  } else {
                    debugPrint("文件拖动到目标区域失败22");
                  }
                } else {
                  debugPrint("文件拖动到目标区域失败11");
                }
              },
              child: Container(
                height: 250,
                width: 300,
                decoration: BoxDecoration(
                  color: _fileEnter ? MyColor.colorFFFF9E80 : MyColor.colorFFF5F5F5,
                  border: Border.all(color: MyColor.colorFFE64A19, width: 2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: MyColor.colorFFFAFAFA, blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 0)),
                  ],
                ),
                child: Center(
                  child: Text(_fileContent,
                      style: MyTextStyle.textStyle500Weight(_fileEnter ? MyColor.whiteColor : MyColor.blackColor, fontSize: 16),
                      textAlign: TextAlign.center),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _readFile(html.File file) {
    final reader = html.FileReader();

    reader.onLoadEnd.listen((e) {
      final fileContent = reader.result as String;
      // 打印文件内容，以便调试
      debugPrint("文件内容：$fileContent");
      try {
        final jsonData = jsonDecode(fileContent);
        // 打印解析的 JSON 数据
        debugPrint("解析后的 JSON 数据: ${jsonData.toString()}");
        setState(() {
          _fileContent = "File Content:\n${jsonData.toString()}";
        });
      } catch (e) {
        // 捕获解析 JSON 时的错误
        debugPrint("错误：$e");
        setState(() {
          _fileContent = "Error reading file.";
        });
      }
    });

    reader.readAsText(file);
  }
}
