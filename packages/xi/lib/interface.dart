import 'package:equatable/equatable.dart';

/// 视频类型
enum VideoType {
  /// 内嵌的 html 链接
  /// 有两个类型:
  ///  1. 真实的内嵌了播放器的 html 链接, 这种需要直接喂给 `webview` 播放
  ///  2. 真实的平台播放链接(比如说爱奇艺链接), 这种一般需要 vip 链接解析才能播放
  iframe,

  /// m3u8 格式的链接 `iOS`/`macOS` 平台原生支持播放
  /// > `macOS` 平台也可以使用第三方播放, 比如说 `iiNA` 或者 `mpv`
  m3u8,

  /// mp4 播放链接大部分都支持, 但一些需要鉴权的就播放不了
  mp4,
}

/// 视频大小
/// 这里基本上没用过, 没有特定解析过
class VideoSize {
  /// 宽
  final double x;

  /// 高
  final double y;

  /// 视频长度
  final double duration;

  /// 视频大小
  /// 视频大小应该在 [VideoInfo] 中包含
  final double size;

  /// 格式化视频大小
  void get humanSize {}

  /// 格式化视频时间
  void get humanDuration {}

  const VideoSize({
    this.x = 0,
    this.y = 0,
    this.duration = 0,
    this.size = 0,
  });
}

// 视频信息
class VideoInfo {
  /// 名称
  final String name;

  /// 视频类型
  final VideoType type;

  /// 视频链接
  final String url;

  VideoInfo({
    this.name = "未命名",
    this.type = VideoType.iframe,
    required this.url,
  });
}

// 视频详情
class VideoDetail {
  /// id
  final String id;

  /// 标题
  final String title;

  /// 介绍
  final String desc;

  /// 更新时间
  final String updateTime;

  /// 备注
  final String remark;

  /// 喜欢
  final int likeCount;

  /// 访问人数
  final int viewCount;

  /// 不喜欢
  final int dislikeCount;

  /// 小封面图(必须要有)
  final String smallCoverImage;

  /// 大封面图
  final String bigCoverImage;

  /// 视频列表
  final List<VideoInfo> videos;

  /// 视频信息
  /// 视频尺寸大小
  /// 视频长度大小
  final VideoSize videoInfo;

  Map<String, dynamic> extra;

  SourceItemMeta? getContext() {
    return extra['source'];
  }

  void setContext(SourceItemMeta value) {
    extra['source'] = value;
  }

  VideoDetail({
    required this.id,
    required this.title,
    required this.extra,
    this.desc = "",
    this.updateTime = "",
    this.remark = "",
    this.likeCount = 0,
    this.viewCount = 0,
    this.dislikeCount = 0,
    this.bigCoverImage = "",
    required this.smallCoverImage,
    this.videoInfo = kDefaultVideoSize,
    this.videos = const [],
  });
}

class SourceItemMeta extends Equatable {
  /// 图标, 默认为空将使用本地资源图标
  final String logo;

  /// 域名, 用来去重
  final String domain;

  /// 资源名称
  final String name;

  /// 开发者
  final String developer;

  /// 开发者邮箱
  /// 用于联系维护者
  final String developerMail;

  /// 介绍
  final String desc;

  final String id;

  /// 是否可用
  final bool status;

  const SourceItemMeta({
    this.logo = "",
    this.developer = "",
    this.developerMail = "",
    this.desc = "",
    this.status = true,
    required this.id,
    required this.name,
    required this.domain,
  });

  @override
  List<Object?> get props =>
      [logo, domain, name, developer, developerMail, desc, id];
}

class SourceSpiderQueryCategory {
  final String name;
  final String id;

  SourceSpiderQueryCategory(this.name, this.id);

  @override
  bool operator ==(Object other) {
    if (other is SourceSpiderQueryCategory) {
      return other.name == name;
    }
    return false;
  }

  @override
  String toString() {
    return '$id: $name';
  }

  @override
  int get hashCode => name.hashCode;
}

//=====================================

abstract class ISpiderAdapter {
  /// 是否为R18资源
  /// **Not Safe For Work**
  bool get isNsfw;

  /// 源信息
  SourceItemMeta get meta;

  /// 获取分类
  Future<List<SourceSpiderQueryCategory>> getCategory();

  /// 获取首页
  Future<List<VideoDetail>> getHome({
    int page = 1,
    int limit = 10,
    String? category,
  });

  /// 搜索
  Future<List<VideoDetail>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  });

  /// 获取视频详情
  Future<VideoDetail> getDetail(String movieId);

  /// 解析 iframe 链接
  Future<List<String>> parseIframe(String iframe);
}

/// 基本上它就是一个空的占位符
class EmptySpiderAdapter implements ISpiderAdapter {
  @override
  Future<List<SourceSpiderQueryCategory>> getCategory() async {
    return [];
  }

  @override
  Future<VideoDetail> getDetail(String movieId) async {
    return VideoDetail(id: '', title: '', smallCoverImage: '', extra: {});
  }

  @override
  Future<List<VideoDetail>> getHome(
      {int page = 1, int limit = 10, String? category}) async {
    return [];
  }

  @override
  Future<List<VideoDetail>> getSearch(
      {required String keyword, int page = 1, int limit = 10}) async {
    return [];
  }

  @override
  Future<List<String>> parseIframe(String iframe) async {
    return [];
  }

  @override
  bool get isNsfw => false;

  @override
  SourceItemMeta get meta => SourceItemMeta(id: '', name: '', domain: '');
}

const VideoSize kDefaultVideoSize = VideoSize();
