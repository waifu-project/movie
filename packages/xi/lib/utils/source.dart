import 'package:flutter/material.dart';
import 'package:xi/xi.dart';

class SourceUtils {
  /// [rawString] 从输入框拿到值
  /// 1. 去除`\n`行
  /// 2. 如果不是 `url` 也不需要
  static List<String> getSources(String rawString) {
    var spList = rawString.split("\n");
    return spList.map((e) => e.trim()).toList().where((item) {
      var flag = (item.isNotEmpty && isURL(item));
      return flag;
    }).toList();
  }

  static ISpiderAdapter? parse(Map<String, dynamic> rawData) {
    List<dynamic> tryData = tryParseData(rawData);
    bool status = tryData[0];
    if (status) {
      var data = tryData[1] as Map<String, dynamic>;
      var sourceType = _getSourceType(data);
      Map<String, dynamic> extraMap = {
        'jiexiUrl': data['jiexiUrl'] ?? '',
        'gfw': data['gfw'] ?? false,
        'searchLimit': _getSearchLimit(data, sourceType),
      };

      // 如果有 template 配置，添加到 extra 中
      if (data['template'] != null) {
        extraMap['template'] = data['template'];
      }

      // 如果有 JS 配置，添加到 extra 中
      if (data['js'] != null) {
        extraMap['js'] = data['js'];
      }

      var meta = SourceMeta(
        id: data['id'] ?? Xid().toString(),
        name: data['name'] ?? "",
        type: sourceType,
        api: data['api'] ?? "",
        logo: data['logo'] ?? "",
        desc: data['desc'] ?? "",
        status: data['status'] ?? true,
        isNsfw: data['nsfw'] ?? false,
        extra: extraMap,
      );

      switch (sourceType) {
        case SourceType.universal:
          return UniversalSpider(meta);
        case SourceType.maccms:
          return MacCMSSpider(meta);
      }
    } else {
      return null;
    }
  }

  static int _getSearchLimit(Map<String, dynamic> data, SourceType sourceType) {
    // 如果数据中明确指定了 searchLimit，使用指定值
    if (data.containsKey('searchLimit') && data['searchLimit'] is int) {
      return data['searchLimit'] as int;
    }
    // 根据源类型设置默认值
    return sourceType == SourceType.universal ? 10 : 20;
  }

  static SourceType _getSourceType(Map<String, dynamic> data) {
    if (data.containsKey('type')) {
      var typeStr = data['type'].toString().toLowerCase();
      if (typeStr == 'universal' || typeStr == '1') {
        return SourceType.universal;
      }
    }
    return SourceType.maccms;
  }

  /// 返回一个数组
  ///
  /// ```js
  /// [
  ///   status: bool,
  ///   data: Map<String, dynamic>
  /// ]
  /// ```
  static List<dynamic> tryParseData(Map<String, dynamic> rawData) {
    String? name = rawData['name'];
    bool hasName = name != null;
    var api = rawData['api'];
    String id = rawData['id'] ?? Xid().toString();

    // 从 extra 中获取 jiexiUrl、gfw、searchLimit 和 template
    var extra = rawData['extra'] as Map<String, dynamic>? ?? {};
    var jiexiUrl = extra['jiexiUrl'];
    var gfw = extra['gfw'];
    var searchLimit = extra['searchLimit'];
    var template = extra['template'];
    var js = extra['js'];

    String apiUrl = '';
    if (api is String) {
      apiUrl = api;
    } else if (api is Map<String, dynamic>) {
      apiUrl = '${api['root'] ?? ''}${api['path'] ?? ''}';
    }
    if (apiUrl.isEmpty) return [false, null];

    if (hasName) {
      bool isNsfw = false;
      if ((rawData['group'] ?? "") == "18禁") {
        isNsfw = true;
      }
      if (rawData['nsfw'] ?? false) {
        isNsfw = true;
      }
      var data = {
        'id': id,
        'name': name,
        'logo': rawData["logo"] ?? "",
        'desc': rawData["desc"] ?? "",
        'nsfw': isNsfw,
        'jiexiUrl': jiexiUrl,
        'gfw': gfw,
        'searchLimit': searchLimit,
        'template': template,
        'api': apiUrl,
        'status': rawData['status'] ?? true,
        'type': rawData['type'],
        'js': js,
      };
      return [true, data];
    }
    return [false, null];
  }

  /// 解析数据
  ///
  /// [data] 为 [String] 转为
  ///
  /// [List<Map<String, dynamic>>] (并递归解析)
  ///
  /// [<Map<String, dynamic>>] (并递归解析)
  ///
  /// 返回值
  ///
  /// => [null]
  ///
  /// => [List<ISpiderAdapter>]
  ///
  /// => [ISpiderAdapter?]
  static dynamic tryParseDynamic(dynamic data) {
    if (data is String) {
      bool isJSON = verifyStringIsJSON(data);
      if (!isJSON) return null;
      var typeAs = getJSONBodyType(data);
      if (typeAs == null) return null;
      dynamic jsonData = jsonc.decode(data);
      if (typeAs == JSONBodyType.array) {
        List<dynamic> cache = jsonData as List<dynamic>;
        List<Map<String, dynamic>> cacheAsMap = cache.map((item) {
          return item as Map<String, dynamic>;
        }).toList();
        return tryParseDynamic(cacheAsMap);
      } else {
        // 如果是对象, 则尝试解析 .data / .mirrors 节点
        var _rootKeys = ['mirrors', 'data'];
        var jsonDataAsMap = jsonData as Map<String, dynamic>;
        for (var key in _rootKeys) {
          if (jsonDataAsMap.containsKey(key)) {
            var cache = jsonDataAsMap[key];
            if (cache is List) {
              List<Map<String, dynamic>> cacheAsMapList = cache
                  .map((item) {
                    if (item is Map<String, dynamic>) return item;
                    return null;
                  })
                  .toList()
                  .where((element) {
                    return element != null;
                  })
                  .toList()
                  .map((e) {
                    return e as Map<String, dynamic>;
                  })
                  .toList();
              return tryParseDynamic(cacheAsMapList);
            }
          }
        }
        return tryParseDynamic(jsonDataAsMap);
      }
    } else if (data is List<Map<String, dynamic>>) {
      return data.map((item) {
        return tryParseDynamic(item);
      }).toList();
    } else if (data is Map<String, dynamic>) {
      var _tryData = parse(data);
      return _tryData;
    } else if (data is List) {
      return tryParseDynamic(data.map((e) {
        return e as Map<String, dynamic>;
      }).toList());
    }
    return null;
  }

  /// 加载网络源
  static Future<List<ISpiderAdapter>> runTaks(List<String> sources) async {
    List<ISpiderAdapter> result = [];
    await Future.forEach(sources, (String element) async {
      debugPrint("加载网络源: $element");
      try {
        var time = const Duration(seconds: 9 /* 秒 */);
        var resp = await XHttp.dio.get(
          element,
          options: Options(
            responseType: ResponseType.plain,
            receiveTimeout: time,
            sendTimeout: time,
          ).withNoCache(),
        );
        dynamic respData = resp.data;
        var data = tryParseDynamic(respData);
        if (data == null) return;
        if (data is ISpiderAdapter) {
          result.add(data);
        } else if (data is List) {
          var append = data
              .where((element) {
                return element != null;
              })
              .toList()
              .map((ele) {
                return ele as ISpiderAdapter;
              })
              .toList();
          result.addAll(append);
        }
      } catch (e) {
        debugPrint("获取网络源失败: $e");
        return null;
      }
    });
    return result;
  }

  /// 合并资源
  ///
  /// [diff] 时返回
  ///
  /// => [len, List<Map<String, dynamic>>]
  ///
  /// => [List<Map<String, dynamic>>]
  @Deprecated("REMOVE THIS")
  static dynamic mergeMirror(
    List<ISpiderAdapter> extend,
    List<ISpiderAdapter> newSourceData, {
    /// diff 是为了返回增加的源源量
    bool diff = false,

    /// cover 是为了覆盖
    bool cover = false,
  }) {
    int len = extend.length;

    if (!cover) {
      for (var element in newSourceData) {
        var newDataApi = element.meta.api;
        extend.removeWhere(
          (element) => element.meta.api == newDataApi,
        );
      }
      extend.addAll(newSourceData);
    } else {
      extend.clear();
      extend.addAll(newSourceData);
    }

    int newLen = extend.length;

    /// 如果比对之后发现没有改变, 则返回 [0, []]
    if (newLen <= 0 && diff) return [0, []];

    var copyData = extend.map(
      (e) {
        return {
          'name': e.meta.name,
          'logo': e.meta.logo,
          'desc': e.meta.desc,
          'nsfw': e.meta.isNsfw,
          'jiexiUrl': e.meta.extra['jiexiUrl'] ?? '',
          'gfw': e.meta.extra['gfw'] ?? false,
          'api': e.meta.api,
          'id': e.meta.id,
          'status': e.meta.status,
          'type': e.meta.type.name,
        };
      },
    ).toList();
    if (diff) {
      return [newLen - len, copyData];
    }
    return copyData;
  }
}
