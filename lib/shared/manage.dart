import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/builtin/maccms/maccms.dart';
import 'package:xi/xi.dart';
import 'package:catmovie/isar/repo.dart';
import 'package:catmovie/isar/schema/mirror_schema.dart';
import 'package:catmovie/shared/enum.dart';



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
      var meta = SourceMeta(
        id: item.sid,
        name: item.name,
        type: SourceType.maccms,
        api: item.api,
        logo: item.logo,
        desc: item.desc,
        status: item.status == MirrorStatus.available,
        isNsfw: item.nsfw,
        extra: {'jiexiUrl': item.jiexiUrl ?? ''},
      );
      return MacCMSSpider(meta);
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
          return $item.meta.api == item.meta.api;
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
    List<Map<String, dynamic>> to = extend.map(
      (e) {
        return {
          "name": e.meta.name,
          "logo": e.meta.logo,
          "desc": e.meta.desc,
          "nsfw": e.meta.isNsfw,
          "api": e.meta.api,
          "id": e.meta.id,
          "status": e.meta.status,
          "jiexiUrl": e.meta.extra['jiexiUrl'] ?? '',
        };
      },
    ).toList();
    if (!full) {
      to = to.where((element) {
        return !(element['nsfw'] ?? false);
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
    List<SourceMeta> newData = extend
        .map((e) {
          String id = e.meta.id;
          bool status = kvHash[id] ?? e.meta.status;
          return SourceMeta(
            id: id,
            name: e.meta.name,
            type: e.meta.type,
            api: e.meta.api,
            logo: e.meta.logo,
            desc: e.meta.desc,
            isNsfw: e.meta.isNsfw,
            status: status,
            extra: e.meta.extra,
          );
        })
        .toList()
        .where((item) {
          String id = item.id;
          bool status = item.status;
          if (!status) {
            result.add(id);
          }
          return status;
        })
        .toList();
    extend.removeWhere((e) => result.contains(e.meta.id));
    mergeSpiderFromMeta(newData);
    return result;
  }

  /// 删除所有源
  static void cleanAll({bool saveToCahe = false}) {
    extend = [];
    if (saveToCahe) {
      mergeSpiderFromMeta([]);
    }
  }

  /// 保存缓存
  /// [该方法只可用来保存第三方源]
  /// 只适用于 [MacCMSSpider]
  static void saveToCache(List<ISpiderAdapter> saves) {
    List<SourceMeta> to = saves.map((e) => e.meta).toList();
    mergeSpiderFromMeta(to);
  }

  static void mergeSpiderFromMeta(List<SourceMeta> data) {
    var output = data.map((item) {
      return MirrorIsarModel(
        sid: item.id,
        name: item.name,
        logo: item.logo,
        api: item.api,
        desc: item.desc,
        nsfw: item.isNsfw,
        status: item.status ? MirrorStatus.available : MirrorStatus.unavailable,
        jiexiUrl: item.extra['jiexiUrl'],
      );
    }).toList();
    IsarRepository().safeWrite(() {
      IsarRepository().mirrorAs.clearSync();
      IsarRepository().mirrorAs.putAllSync(output);
    });
  }


}
