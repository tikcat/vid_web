import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;

class VideoFileData {
  final String fileName;
  final String playName;
  final String episodeIndex;
  int position;
  String documentId;
  /// 是否已经上传到数据库
  bool isUploaded;
  /// 是否已经上架
  bool isAvailable;
  /// 视频地址
  final String videoUrl;
  String cover;
  /// 国家，剧的出品国
  String country;
  /// 剧的语言 localeCode
  String languageCode;
  drive.File? file;
  /// 视频类型
  String sourceType;

  /// 所有收费剧集前三级免费，三级后收费
  int likeCount = 0;
  int collectCount = 0;
  int shareCount = 0;

  /// 剧集是否是免费的
  bool isFree;

  /// 视频简介
  String videoIntro;

  /// 是否选中当前数据
  bool isSelected = false;
  /// 评分
  double score;
  /// 视频时长 HH:mm:ss
  String totalTime;
   bool isLike;
  int timestamp;

  VideoFileData({
    required this.fileName,
    required this.playName,
    required this.episodeIndex,
    required this.documentId,
    required this.isUploaded,
    required this.videoUrl,
    required this.cover,
    required this.sourceType,
    required this.isFree,
    required this.isAvailable,
    required this.country,
    required this.languageCode,
    required this.timestamp,
    this.position = 0,
    this.videoIntro = "",
    this.likeCount = 0,
    this.collectCount = 0,
    this.shareCount = 0,
    this.score = 0,
    this.totalTime = "",
    this.isLike = false,
    this.file,
  });

  // 将对象转化为Map
  Map<String, dynamic> toMap() {
    return {
      'name': fileName,
      'playName': playName,
      'index': episodeIndex,
      'documentId': documentId,
      'isUploaded': isUploaded,
      'videoUrl': videoUrl,
      'cover': cover,
      'sourceType': sourceType,
      'country': country,
      'languageCode': languageCode,
      'isFree': isFree,
      'isAvailable': isAvailable,
      'videoIntro': videoIntro,
      'likeCount': likeCount,
      'collectCount': collectCount,
      'shareCount': shareCount,
      'score': score,
      'totalTime': totalTime,
      'position': position,
      'isLike': isLike,
      'timestamp': timestamp,
    };
  }

  factory VideoFileData.fromMap(Map<String, dynamic> jsonMap) {
    return VideoFileData(
      fileName: jsonMap['name'],
      playName: jsonMap['playName'],
      episodeIndex: jsonMap['index'],
      documentId: jsonMap['documentId'],
      isUploaded: jsonMap['isUploaded'],
      videoUrl: jsonMap['videoUrl'],
      cover: jsonMap['cover'],
      sourceType: jsonMap['sourceType'],
      country: jsonMap['country'],
      languageCode: jsonMap['languageCode'],
      isFree: jsonMap['isFree'],
      isAvailable: jsonMap['isAvailable'],
      videoIntro: jsonMap['videoIntro'],
      likeCount: jsonMap['likeCount'],
      collectCount: jsonMap['collectCount'],
      shareCount: jsonMap['shareCount'],
      score: jsonMap['score'],
      totalTime: jsonMap['totalTime'],
      position: jsonMap['position'],
      isLike: jsonMap['isLike'],
      timestamp: jsonMap['timestamp'],
    );
  }

  // 将对象转换为 JSON 字符串
  String toJson() => jsonEncode({
        'fileName': fileName,
        'playName': playName,
        'episodeIndex': episodeIndex,
        'documentId': documentId,
        'isUploaded': isUploaded,
        'videoUrl': videoUrl,
        'cover': cover,
        'sourceType': sourceType,
        'country': country,
        'languageCode': languageCode,
        'isFree': isFree,
        'isAvailable': isAvailable,
        'videoIntro': videoIntro,
        'likeCount': likeCount,
        'collectCount': collectCount,
        'shareCount': shareCount,
        'score': score,
        'totalTime': totalTime,
        'position': position,
        'isLike': isLike,
        'timestamp': timestamp,
        'file': file,
      });

  // 从 JSON 字符串解析对象
  factory VideoFileData.fromJson(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return VideoFileData(
      fileName: jsonMap['fileName'],
      playName: jsonMap['playName'],
      episodeIndex: jsonMap['episodeIndex'],
      documentId: jsonMap['documentId'],
      isUploaded: jsonMap['isUploaded'],
      videoUrl: jsonMap['videoUrl'],
      cover: jsonMap['cover'],
      sourceType: jsonMap['sourceType'],
      country: jsonMap['country'],
      languageCode: jsonMap['languageCode'],
      isFree: jsonMap['isFree'],
      isAvailable: jsonMap['isAvailable'],
      videoIntro: jsonMap['videoIntro'],
      likeCount: jsonMap['likeCount'],
      collectCount: jsonMap['collectCount'],
      shareCount: jsonMap['shareCount'],
      score: jsonMap['score'],
      totalTime: jsonMap['totalTime'],
      position: jsonMap['position'],
      isLike: jsonMap['isLike'],
      timestamp: jsonMap['timestamp'],
      file: jsonMap['file'],
    );
  }
}
