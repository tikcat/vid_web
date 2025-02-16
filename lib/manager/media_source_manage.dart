import 'package:vid_web/enum/home_list_block.dart';

class MediaSourceManage {



  /// 视频类型映射
  static String getVideoTypeByCollectionName(String type) {
    if(type == HomeListBlock.movies.collectionName) {
      return HomeListBlock.movies.sourceType;
    } else if(type == HomeListBlock.dramas.collectionName) {
      return HomeListBlock.dramas.sourceType;
    } else if(type == HomeListBlock.series.collectionName) {
      return HomeListBlock.series.sourceType;
    } else if(type == HomeListBlock.cartoon.collectionName) {
      return HomeListBlock.cartoon.sourceType;
    } else if(type == HomeListBlock.documentary.collectionName) {
      return HomeListBlock.documentary.sourceType;
    } else if(type == HomeListBlock.music.collectionName) {
      return HomeListBlock.music.sourceType;
    } else {
      return '';
    }
  }

  /// 获取集合名称
  static String getCollectionNameByVideoType(String type) {
    if (type == HomeListBlock.movies.sourceType) {
      return HomeListBlock.movies.collectionName;
    } else if (type == HomeListBlock.dramas.sourceType) {
      return HomeListBlock.dramas.collectionName;
    } else if (type == HomeListBlock.series.sourceType) {
      return HomeListBlock.series.collectionName;
    } else if (type == HomeListBlock.cartoon.sourceType) {
      return HomeListBlock.cartoon.collectionName;
    } else if (type == HomeListBlock.documentary.sourceType) {
      return HomeListBlock.documentary.collectionName;
    } else if (type == HomeListBlock.music.sourceType) {
      return HomeListBlock.music.collectionName;
    } else {
      return '';
    }
  }

  /// 媒体资源模块
  static const List<HomeListBlock> homeBlockList = [
    HomeListBlock.movies,
    HomeListBlock.dramas,
    HomeListBlock.series,
    HomeListBlock.cartoon,
    HomeListBlock.documentary,
    HomeListBlock.homeShort,
    HomeListBlock.music,
  ];

  /// all page资源模块数据
  static const List<HomeListBlock> allPageBlockList = [
    HomeListBlock.banner,
    HomeListBlock.movies,
    HomeListBlock.dramas,
    HomeListBlock.series,
    HomeListBlock.cartoon,
    HomeListBlock.documentary,
    HomeListBlock.music,
    HomeListBlock.none,
  ];

  /// 支持的分类模块
  static const List<HomeListBlock> allHomeBlocklist = [
    HomeListBlock.movies,
    HomeListBlock.dramas,
    HomeListBlock.series,
    HomeListBlock.cartoon,
    HomeListBlock.documentary,
    HomeListBlock.music,
  ];

}
