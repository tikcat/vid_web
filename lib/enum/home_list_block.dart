enum HomeListBlock {
  banner(type: 0, collectionName: "Banner", name: "轮播", sourceType: "banner",),
  movies(type: 1, collectionName: "Movies", name: "电影", sourceType: "movie",),
  dramas(type: 2, collectionName: "Dramas", name: "短剧", sourceType: "drama",),
  series(type: 3, collectionName: "Series", name: "连续剧", sourceType: "series",),
  cartoon(type: 4, collectionName: "Cartoons", name: "动漫", sourceType: "cartoon",),
  music(type: 5, collectionName: "Musics", name: "音乐", sourceType: "music",),
  documentary(type: 6, collectionName: "Documentary", name: "纪录片", sourceType: "documentary",),
  homeShort(type: 7, collectionName: "HomeShort", name: "首页短剧", sourceType: "drama",),
  none(type: 99, collectionName: "None", name: "无数据");

  const HomeListBlock({required this.type, this.collectionName = "", this.name = "", this.sourceType = "",});

  final int type;
  final String collectionName;
  final String name;
  final String sourceType;
}