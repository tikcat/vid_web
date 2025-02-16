import 'dart:convert';

class WebPageData {
  String title = "";
  String url = "";
  String webType = "";

  WebPageData({this.title = "", this.url = "", this.webType = ""});

  // 将对象转化为Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'webType': webType,
    };
  }

  factory WebPageData.fromMap(Map<String, dynamic> jsonMap) {
    return WebPageData(
      title: jsonMap['title'],
      url: jsonMap['url'],
      webType: jsonMap['webType'],
    );
  }

  // 将对象转换为 JSON 字符串
  String toJson() => jsonEncode({
        'title': title,
        'url': url,
        'webType': webType,
      });

  // 从 JSON 字符串解析对象
  factory WebPageData.fromJson(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return WebPageData(
      title: jsonMap['title'],
      url: jsonMap['url'],
      webType: jsonMap['webType'],
    );
  }
}
