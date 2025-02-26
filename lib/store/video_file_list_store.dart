import 'package:mobx/mobx.dart';
import 'package:vid_web/data/video_file_data.dart';

part 'video_file_list_store.g.dart';

class VideoFileListStore = _VideoFileListStore with _$VideoFileListStore;

abstract class _VideoFileListStore with Store {

  @observable
  List<VideoFileData> videoFileDataList = [];

  @action
  void updateVideoFileList(List<VideoFileData> newVideoFileList) {
    videoFileDataList = newVideoFileList;
  }

  @observable
  bool isLoading = false;

  @action
  void updateLoading(bool newLoading) {
    isLoading = newLoading;
  }

  @observable
  double progress = 0.0;

  @action
  void updateProgress(double newProgress) {
    progress = newProgress;
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

  /// 视频简介
  @observable
  String videoIntro = '';

  @action
  void updateVideoIntro(String newIntro) {
    videoIntro = newIntro;
  }

}