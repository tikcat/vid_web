import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobx/mobx.dart';
import 'package:vid_web/data/video_file_data.dart';
import 'package:vid_web/enum/home_list_block.dart';

part 'dailymotion_page_store.g.dart';

class DailymotionPageStore = _DailymotionPageStore with _$DailymotionPageStore;

abstract class _DailymotionPageStore with Store {

  @observable
  GoogleSignInAccount? googleUser;

  @action
  void setGoogleUser(GoogleSignInAccount? googleUser) {
    this.googleUser = googleUser;
  }

  /// 该集的名称
  @observable
  String name = "";

  @action
  void setName(String name) {
    this.name = name;
  }

  /// 剧名
  @observable
  String playName = "";

  @action
  void setPlayName(String playName) {
    this.playName = playName;
  }

  /// 封面名称
  @observable
  String videoCoverName = "";

  @action
  void updateVideoCoverName(String value) {
    videoCoverName = value;
  }

  @observable
  bool videoCoverQuerying = false;

  @action
  void updateVideoCoverQuerying(bool value) {
    videoCoverQuerying = value;
  }

  @observable
  String videoCoverUrl = "";

  @action
  void updateVideoCoverUrl(String value) {
    videoCoverUrl = value;
  }

  @observable
  HomeListBlock? currentVideoType;

  @action
  void updateCurrentVideoType(HomeListBlock? value) {
    currentVideoType = value;
  }

  @observable
  bool isAvailable = false;

  @action
  void updateIsAvailable(bool newAvailable) {
    isAvailable = newAvailable;
  }

  @observable
  bool isFree = false;

  @action
  void updateIsFree(bool newFree) {
    isFree = newFree;
  }

  /// 当前视频文件的语言国家
  @observable
  String currentVideoFileLanguage = 'en_US';

  @action
  void updateCurrentVideoFileLanguage(String newLanguage) {
    currentVideoFileLanguage = newLanguage;
  }

  @observable
  bool videoUploading = false;

  @action
  void updateVideoUploading(bool value) {
    videoUploading = value;
  }

  @observable
  bool isUpload = false;

  @action
  void updateIsUpload(bool value) {
    isUpload = value;
  }

  @observable
  String videoCover = "";

  @action
  void updateVideoCover(String value) {
    videoCover = value;
  }

  @observable
  bool showReadVideoJson = false;

  @action
  void updateShowReadVideoJson(bool value) {
    showReadVideoJson = value;
  }

  @observable
  bool showUploadVideo = false;

  @action
  void updateShowUploadVideo(bool value) {
    showUploadVideo = value;
  }

  @observable
  List<VideoFileData> videoFileDataList = [];

  @action
  void updateVideoFileDataList(List<VideoFileData> value) {
    videoFileDataList = value;
  }

  @observable
  bool videoFileDataListQuerying = false;

  @action
  void updateVideoFileDataListQuerying(bool value) {
    videoFileDataListQuerying = value;
  }

  @observable
  double progress = 0.0;

  @action
  void updateProgress(double newProgress) {
    progress = newProgress;
  }

  @observable
  String documentId = "";

  @action
  void updateDocumentId(String value) {
    documentId = value;
  }
}