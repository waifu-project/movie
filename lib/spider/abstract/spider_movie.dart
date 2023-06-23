import 'package:movie/spider/abstract/spider_serialize.dart';

class SpiderItemMetaData {
  /// 图标, 默认为空将使用本地资源图标
  String logo;

  /// 域名, 用来去重
  String domain;

  /// 资源名称
  String name;

  /// 开发者
  String developer;

  /// 开发者邮箱
  /// 用于联系维护者
  String developerMail;

  /// 介绍
  String desc;

  String id;

  /// 是否可用
  bool status;

  SpiderItemMetaData({
    this.logo = "",
    this.developer = "",
    this.developerMail = "",
    this.desc = "",
    this.status = true,
    required this.id,
    required this.name,
    required this.domain,
  });
}

class SpiderQueryCategory {
  final String name;
  final String id;

  SpiderQueryCategory(this.name, this.id);

  @override
  String toString() {
    return '$id: $name';
  }
}

abstract class ISpider {
  /// 是否为R18资源
  /// **Not Safe For Work**
  bool get isNsfw;

  /// 源信息
  SpiderItemMetaData get meta;

  /// 获取分类
  Future<List<SpiderQueryCategory>> getCategory();

  /// 获取首页
  Future<List<MirrorOnceItemSerialize>> getHome({
    int page = 1,
    int limit = 10,
    String? category,
  });

  /// 搜索
  Future<List<MirrorOnceItemSerialize>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  });

  /// 获取视频详情
  Future<MirrorOnceItemSerialize> getDetail(String movieId);
}
