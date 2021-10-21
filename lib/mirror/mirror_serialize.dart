enum MirrorSerializeVideoType {
  iframe,

  m3u8,

  mp4,
}

class MirrorSerializeVideoSize {
  /// 宽
  final double x;

  /// 高
  final double y;

  /// 视频长度
  final double duration;

  /// 视频大小
  final double size;

  /// TODO
  /// 格式化视频大小
  get humanSize {}

  /// TODO
  /// 格式化视频时间
  get humanDuration {}

  const MirrorSerializeVideoSize({
    this.x = 0,
    this.y = 0,
    this.duration = 0,
    this.size = 0,
  });
}

const MirrorSerializeVideoSize kDefaultVideoSiz = MirrorSerializeVideoSize();

class MirrorOnceItemSerialize {
  /// id
  final String? id;

  /// 标题
  final String? title;

  /// 喜欢
  final int likeCount;

  /// 访问人数
  final int viewCount;

  /// 不喜欢
  final int dislikeCount;

  /// 小封面图(必须要有)
  final String? smallCoverImage;

  /// 大封面图
  final String bigCoverImage;

  /// 视频类型
  final MirrorSerializeVideoType videoType;

  /// 视频链接
  final String? videoUrl;

  /// 视频信息
  /// 视频尺寸大小
  /// 视频长度大小
  final MirrorSerializeVideoSize videoInfo;

  MirrorOnceItemSerialize({
    required this.id,
    required this.title,
    this.likeCount = 0,
    this.viewCount = 0,
    this.dislikeCount = 0,
    this.bigCoverImage = "",
    required this.smallCoverImage,
    required this.videoType,
    required this.videoUrl,
    this.videoInfo = kDefaultVideoSiz,
  });
}

class MirrorCardSerialize {
  List<MirrorOnceItemSerialize> cards;

  String cardTitle;

  MirrorCardSerialize({
    this.cardTitle = "推荐",
    required this.cards,
  });
}
