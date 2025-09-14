import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/builtin/maccms/maccms.dart';
import 'package:xi/xi.dart';
import 'package:catmovie/isar/repo.dart';
import 'package:catmovie/isar/schema/mirror_schema.dart';
import 'package:catmovie/shared/enum.dart';

import 'package:xi/models/mac_cms/source_data.dart';

class SpiderManage {
  SpiderManage._internal();

  /// 扩展的源
  static List<ISpiderAdapter> extend = [];

  /// 内建支持的源
  /// 一般是需要自己去实现的源
  static List<ISpiderAdapter> builtin = list$;

  /// 合并之后的数据
  static List<ISpiderAdapter> get data {
    return [...extend, ...builtin];
  }

  /// 初始化
  static Future<void> init() async {
    final data = IsarRepository().mirrorAs.where(distinct: false).findAllSync();
    var result = data.map((item) {
      return MacCMSSpider(
        logo: item.logo,
        name: item.name,
        desc: item.desc,
        api_path: item.api.path,
        root_url: item.api.root,
        nsfw: item.nsfw,
        id: item.sid,
        status: item.status == MirrorStatus.available,
      );
    }).toList();
    extend = result;
  }

  /// 添加源
  ///
  /// 返回 false 可能是源已经存在过
  static bool addItem(ISpiderAdapter item) {
    var wasAdd = true;
    if (item is MacCMSSpider) {
      var isExist = [...extend, ...builtin].any(($item) {
        if ($item is MacCMSSpider) {
          // FIXME: 如果 name 相同了怎么办👀?
          return $item.root_url == item.root_url &&
              $item.api_path == item.api_path;
        }
        return false;
      });
      if (isExist) {
        wasAdd = false;
      } else {
        extend.add(item);
      }
    } else {
      extend.add(item);
    }
    saveToCache(extend);
    return wasAdd;
  }

  /// 删除单个源
  static void removeItem(ISpiderAdapter item) {
    extend.remove(item);
    saveToCache(extend);
  }

  /// 删除 [List<String> id] 中的源
  static void remoteItemFromIDS(List<String> id) {
    extend.removeWhere((e) => id.contains(e.meta.id));
    saveToCache(extend);
  }

  /// 导出文件
  ///
  /// [full] 是否全量导出(nsfw 是否导出)
  static String export({bool full = false}) {
    // bool isNsfw = local.read(ConstDart.is_nsfw) ?? false;
    List<SourceJsonData> to = extend
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
      to = to.where((element) {
        return !(element.nsfw ?? false);
      }).toList();
    }
    String result = jsonEncode(to);
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
  static void cleanAll({bool saveToCahe = false}) {
    extend = [];
    if (saveToCahe) {
      mergeSpider([]);
    }
  }

  /// 保存缓存
  /// [该方法只可用来保存第三方源]
  /// 只适用于 [MacCMSSpider]
  static void saveToCache(List<ISpiderAdapter> saves) {
    List<SourceJsonData> to = saves
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
    mergeSpider(to);
  }

  static void mergeSpider(List<SourceJsonData> data) {
    var output = data.map((item) {
      var api = MirrorApiIsardModel();
      api.root = item.api?.root ?? "";
      api.path = item.api?.path ?? "";
      var status = item.status ?? true;
      return MirrorIsarModel(
        sid: item.id ?? Xid().toString(),
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
