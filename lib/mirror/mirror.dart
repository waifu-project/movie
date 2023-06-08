import 'dart:convert';

import 'package:movie/config.dart';
import 'package:movie/impl/movie.dart';

import 'm_utils/m.dart';
import 'mlist/base_models/source_data.dart';

class MirrorManage {
  MirrorManage._internal();

  /// 扩展的源
  static List<MovieImpl> extend = [];

  /// 内建支持的源
  /// 一般是需要自己去实现的源
  static List<MovieImpl> builtin = [];

  /// 合并之后的数据
  static List<MovieImpl> get data {
    return [...extend, ...builtin];
  }

  /// 初始化
  static init() async {
    // var cacheData = local.read<List<dynamic>>(ConstDart.mirror_list) ?? [];
    // var output = cacheData.map((e) => SourceJsonData.fromJson(e)).toList();
    // TODO: use isar reimpl this
    var output = [];
    var result = output.map((data) {
      return KBaseMirrorMovie(
        logo: data.logo ?? "",
        name: data.name ?? "",
        desc: data.desc ?? "",
        api_path: data.api!.path ?? "",
        root_url: data.api!.root ?? "",
        nsfw: data.nsfw ?? false,
        id: data.id ?? "",
        status: data.status ?? true,
      );
    }).toList();
    extend = result;
  }

  /// 删除单个源
  static removeItem(MovieImpl item) {
    print("删除该源: $item");
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
              path: (e as KBaseMirrorMovie).api_path,
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
              path: (e as KBaseMirrorMovie).api_path,
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
    mergeMirror(newData);
    return result;
  }

  /// 删除所有源
  static cleanAll({
    bool saveToCahe = false,
  }) {
    extend = [];
    if (saveToCahe) {
      mergeMirror([]);
    }
  }

  /// 保存缓存
  /// [该方法只可用来保存第三方源]
  /// 只适用于 [KBaseMirrorMovie]
  static saveToCache(List<MovieImpl> saves) {
    List<SourceJsonData> _to = saves
        .map(
          (e) => SourceJsonData(
            name: e.meta.name,
            logo: e.meta.logo,
            desc: e.meta.desc,
            nsfw: e.isNsfw,
            api: Api(
              root: e.meta.domain,
              path: (e as KBaseMirrorMovie).api_path,
            ),
            id: e.id,
            status: e.status,
          ),
        )
        .toList();
    mergeMirror(_to);
  }

  static Future<void> mergeMirror(List<SourceJsonData> data) async {
    // TODO: use isar reimpl this
    // await local.write(ConstDart.mirror_list, data);
  }
}
