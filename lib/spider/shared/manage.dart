import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:movie/app/extension.dart';
import 'package:movie/spider/abstract/spider_movie.dart';
import 'package:movie/isar/repo.dart';
import 'package:movie/isar/schema/mirror_schema.dart';
import 'package:movie/shared/enum.dart';

import '../impl/mac_cms.dart';
import '../models/mac_cms/source_data.dart';

// 唉, 懒得改了, 又不是不能跑, 代码丑点怎么了?

class SpiderManage {
  SpiderManage._internal();

  /// 扩展的源
  static List<SpiderImpl> extend = [];

  /// 内建支持的源
  /// 一般是需要自己去实现的源
  static List<SpiderImpl> builtin = [];

  /// 合并之后的数据
  static List<SpiderImpl> get data {
    return [...extend, ...builtin];
  }

  /// 初始化
  static init() async {
    final data = IsarRepository().mirrorAs.where(distinct: false).findAllSync();
    var result = data.map((item) {
      return MacCMSSpider(
        logo: item.logo,
        name: item.name,
        desc: item.desc,
        api_path: item.api.path,
        root_url: item.api.root,
        nsfw: item.nsfw,
        id: item.id.toString(),
        status: item.status == MirrorStatus.available,
      );
    }).toList();
    extend = result;
  }

  /// 删除单个源
  static removeItem(SpiderImpl item) {
    debugPrint("删除该源: $item");
    extend.remove(item);
    saveToCache(extend);
  }

  /// 删除 [List<String> id] 中的源
  static remoteItemFromIDS(List<String> id) {
    extend.removeWhere((e) => id.contains(e.meta.id));
    saveToCache(extend);
  }

  /// 导出文件
  ///
  /// [full] 是否全量导出(nsfw 是否导出)
  static String export({
    bool full = false,
  }) {
    // bool isNsfw = local.read(ConstDart.is_nsfw) ?? false;
    List<SourceJsonData> _to = extend
        .map(
          (e) => SourceJsonData(
            name: e.meta.name,
            logo: e.meta.logo,
            desc: e.meta.desc,
            nsfw: e.isNsfw,
            api: Api(
              root: e.meta.domain,
              path: (e as MacCMSSpider).api_path,
            ),
            id: e.id,
            status: e.status,
          ),
        )
        .toList();
    if (!full) {
      _to = _to.where((element) {
        return !(element.nsfw ?? false);
      }).toList();
    }
    String result = jsonEncode(_to);
    return result;
  }

  /// 删除不可用源
  /// [kvHash] 映射的缓存
  /// 返回被删除的 [List<String> ids]
  static List<String> removeUnavailable(Map<String, bool> kvHash) {
    List<String> result = [];
    List<SourceJsonData> newData = extend
        .map((e) {
          String id = e.meta.id;
          bool status = kvHash[id] ?? e.meta.status;
          return SourceJsonData(
            name: e.meta.name,
            logo: e.meta.logo,
            desc: e.meta.desc,
            nsfw: e.isNsfw,
            api: Api(
              root: e.meta.domain,
              path: (e as MacCMSSpider).api_path,
            ),
            id: id,
            status: status,
          );
        })
        .toList()
        .where((item) {
          String id = item.id as String;
          bool status = item.status ?? true;
          if (!status) {
            result.add(id);
          }
          return status;
        })
        .toList();
    extend.removeWhere((e) => result.contains(e.meta.id));
    mergeSpider(newData);
    return result;
  }

  /// 删除所有源
  static cleanAll({
    bool saveToCahe = false,
  }) {
    extend = [];
    if (saveToCahe) {
      mergeSpider([]);
    }
  }

  /// 保存缓存
  /// [该方法只可用来保存第三方源]
  /// 只适用于 [MacCMSSpider]
  static saveToCache(List<SpiderImpl> saves) {
    List<SourceJsonData> _to = saves
        .map(
          (e) => SourceJsonData(
            name: e.meta.name,
            logo: e.meta.logo,
            desc: e.meta.desc,
            nsfw: e.isNsfw,
            api: Api(
              root: e.meta.domain,
              path: (e as MacCMSSpider).api_path,
            ),
            id: e.id,
            status: e.status,
          ),
        )
        .toList();
    mergeSpider(_to);
  }

  static Future<void> mergeSpider(List<SourceJsonData> data) async {
    var output = data.map((item) {
      var api = MirrorApiIsardModel();
      api.root = item.api?.root ?? "";
      api.path = item.api?.path ?? "";
      var status = item.status ?? true;
      return MirrorIsarModel(
        name: item.name ?? "",
        logo: item.name ?? "",
        api: api,
        desc: item.desc ?? "",
        nsfw: item.nsfw ?? false,
        status: status ? MirrorStatus.available : MirrorStatus.unavailable,
      );
    }).toList();
    IsarRepository().safeWrite(() {
      IsarRepository().mirrorAs.clearSync();
      IsarRepository().mirrorAs.putAllSync(output);
    });
  }
}
