// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:vid_web/constant/my_color.dart';
// import 'package:vid_web/text_style.dart';
//
// class DragAndDropWidget extends StatefulWidget {
//   const DragAndDropWidget({super.key});
//
//   @override
//   State<DragAndDropWidget> createState() => _DragAndDropWidgetState();
// }
//
// class _DragAndDropWidgetState extends State<DragAndDropWidget> {
//   String _fileContent = "请拖动文件到此处";
//   late WebViewController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     if (WebView.platform is AndroidInAppWebViewPlatform) {
//       AndroidInAppWebViewPlatform.instance.setWebContentsDebuggingEnabled(true);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WebView(
//       initialUrl: 'asset://index.html',
//       javascriptMode: JavascriptMode.unrestricted,
//       javascriptChannels: {
//         JavascriptChannel(
//           name: 'FlutterWeb',
//           onMessageReceived: (JavascriptMessage message) {
//             final data = jsonDecode(message.message);
//             final fileContent = data['fileContent'];
//             final fileName = data['fileName'];
//             debugPrint("文件被接受 fileName:$fileName");
//             _readFileContent(fileContent);
//           },
//         ),
//       },
//       onWebViewCreated: (WebViewController webViewController) {
//         _controller = webViewController;
//       },
//     );
//   }
//
//   void _readFileContent(String fileContent) {
//     try {
//       final jsonData = jsonDecode(fileContent);
//       // 打印解析的 JSON 数据
//       debugPrint("解析后的 JSON 数据: ${jsonData.toString()}");
//       setState(() {
//         _fileContent = "File Content:\n${jsonData.toString()}";
//       });
//     } catch (e) {
//       // 捕获解析 JSON 时的错误
//       debugPrint("错误：$e");
//       setState(() {
//         _fileContent = "Error reading file.";
//       });
//     }
//   }
// }
