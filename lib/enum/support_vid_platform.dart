enum SupportVidPlatform {
  dailymotion(type: 1, name: "Dailymotion"),
  youtube(type: 2, name: "Youtube"),
  bilibili(type: 3, name: "Bilibili"),
  tiktok(type: 4, name: "Tiktok"),
  vimeo(type: 5, name: "Vimeo");

  const SupportVidPlatform({required this.type, this.name = "",});

  final int type;
  final String name;
}
