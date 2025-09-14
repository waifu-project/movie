import 'package:isar_community/isar.dart';

part 'video_history_schema.g.dart';

@embedded
class VideoHistoryContextIsardModel {
  VideoHistoryContextIsardModel({
    this.title = "",
    this.cover = "",
    this.pTabIndex = -1,
    this.pIndex = -1,
    this.pText = "",
    this.detailID = "",
  });

  /// 标题
  late String title;

  /// 封面
  late String cover;

  /// 播放列表当前Tab
  late int pTabIndex;

  /// 播放列表索引
  /// 如果被排序过这里的索引就不对了, 必须改为ID才正确
  late int pIndex;

  /// 播放列表文本
  late String pText;

  // TODO(d1y): impl this
  /// 总时长
  // late double duration;
  /// 播放进度
  // late double playProgress;

  /// 详情ID
  late String detailID;
}

@collection
class VideoHistoryIsarModel {
  VideoHistoryIsarModel({
    required this.isNsfw,
    required this.sid,
    required this.sourceName,
    required this.ctx,
  });

  Id id = Isar.autoIncrement;

  @Index()
  bool isNsfw;

  /// 源id
  String sid;

  /// 源名称
  /// > 通过 sid 去查名称太麻烦了
  String sourceName;

  VideoHistoryContextIsardModel ctx;
}
