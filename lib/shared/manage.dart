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
      Map<String, dynamic> extraMap = {
        'jiexiUrl': item.extra.jiexiUrl ?? '',
        'gfw': item.extra.gfw ?? false,
      };

      // 添加 searchLimit
      if (item.extra.searchLimit != null) {
        extraMap['searchLimit'] = item.extra.searchLimit;
      }

      // 添加 template
      if (item.extra.template != null) {
        extraMap['template'] = item.extra.template;
      }

      // 如果有 JS 配置，添加到 extra 中
      if (item.extra.js != null) {
        extraMap['js'] = {
          'category': item.extra.js!.category,
          'home': item.extra.js!.home,
          'search': item.extra.js!.search,
          'detail': item.extra.js!.detail,
          'parseIframe': item.extra.js!.parseIframe,
        };
      }

      var meta = SourceMeta(
        id: item.sid,
        name: item.name,
        type: item.type,
        api: item.api,
        logo: item.logo,
        desc: item.desc,
        status: item.status == MirrorStatus.available,
        isNsfw: item.nsfw,
        extra: extraMap,
      );

      switch (item.type) {
        case SourceType.universal:
          return UniversalSpider(meta);
        case SourceType.maccms:
        default:
          return MacCMSSpider(meta);
      }
    }).toList();
    extend = result;
  }

  /// 添加源
  ///
  /// 返回 false 可能是源已经存在过
  static bool addItem(ISpiderAdapter item) {
    var wasAdd = true;
    var isExist = [...extend, ...builtin].any(($item) {
      // Check for duplicate by API URL
      return $item.meta.api == item.meta.api;
    });

    if (isExist) {
      wasAdd = false;
    } else {
      extend.add(item);
    }

    if (wasAdd) {
      saveToCache(extend);
    }
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
          "type": e.meta.type.name,
          "extra": e.meta.extra,
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
  /// 适用于所有 ISpiderAdapter 实现
  static void saveToCache(List<ISpiderAdapter> saves) {
    List<SourceMeta> to = saves.map((e) => e.meta).toList();
    mergeSpiderFromMeta(to);
  }

  static void mergeSpiderFromMeta(List<SourceMeta> data) {
    var output = data.map((item) {
      var extra = MirrorExtra()
      ..jiexiUrl = item.extra['jiexiUrl']
      ..gfw = item.extra['gfw']
      ..searchLimit = item.extra['searchLimit']
      ..template = item.extra['template'];

      // 如果有 JS 配置，保存到 MirrorExtra 中
      if (item.extra.containsKey('js') && item.extra['js'] is Map) {
        var jsMap = item.extra['js'] as Map<String, dynamic>;
        String category = "";
        var _category = jsMap['category'];
        if (_category is String) {
          category = _category;
        } else if (_category is List) {
          category = jsonEncode(_category);
        }
        extra.js = MirrorExtraJS()
          ..category = category
          ..home = jsMap['home'] ?? ''
          ..search = jsMap['search'] ?? ''
          ..detail = jsMap['detail'] ?? ''
          ..parseIframe = jsMap['parseIframe'] ?? '';
      }

      return MirrorIsarModel(
        sid: item.id,
        name: item.name,
        logo: item.logo,
        api: item.api,
        desc: item.desc,
        nsfw: item.isNsfw,
        status: item.status ? MirrorStatus.available : MirrorStatus.unavailable,
        type: item.type,
        extra: extra,
      );
    }).toList();
    IsarRepository().safeWrite(() {
      IsarRepository().mirrorAs.clearSync();
      IsarRepository().mirrorAs.putAllSync(output);
    });
  }
}
