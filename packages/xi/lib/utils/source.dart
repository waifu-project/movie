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

  static MacCMSSpider? parse(Map<String, dynamic> rawData) {
    List<dynamic> tryData = tryParseData(rawData);
    bool status = tryData[0];
    if (status) {
      var data = tryData[1] as Map<String, dynamic>;
      var meta = SourceMeta(
        id: data['id'] ?? Xid().toString(),
        name: data['name'] ?? "",
        type: SourceType.maccms,
        api: data['api'] ?? "",
        logo: data['logo'] ?? "",
        desc: data['desc'] ?? "",
        status: data['status'] ?? true,
        isNsfw: data['nsfw'] ?? false,
        extra: {'jiexiUrl': data['jiexiUrl'] ?? ''},
      );
      return MacCMSSpider(meta);
    } else {
      return null;
    }
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
    var jiexiUrl = rawData['jiexiUrl'];

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
        'api': apiUrl,
        'status': rawData['status'] ?? true,
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
  /// => [List<SourceJsonData>]
  ///
  /// => [KBaseMirrorMovie?]
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
  static Future<List<MacCMSSpider>> runTaks(List<String> sources) async {
    List<MacCMSSpider> result = [];
    await Future.forEach(sources, (String element) async {
      debugPrint("加载网络源: $element");
      try {
        var time = const Duration(seconds: 9 /* 秒 */);
        var resp = await XHttp.dio.get(
          element,
          options: Options(
            responseType: ResponseType.json, // 暂未设计出 `.xv` 文件, 通过 `json` 导入
            receiveTimeout: time,
            sendTimeout: time,
          ),
        );
        dynamic respData = resp.data;
        var data = tryParseDynamic(respData);
        if (data == null) return;
        if (data is MacCMSSpider) {
          result.add(data);
        } else if (data is List) {
          var append = data
              .where((element) {
                return element != null;
              })
              .toList()
              .map((ele) {
                return ele as MacCMSSpider;
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
  /// [List<SourceJsonData>]
  ///
  /// [diff] 时返回
  ///
  /// => [len, List<KBaseMirrorMovie>]
  ///
  /// => [List<KBaseMirrorMovie>]
  @Deprecated("REMOVE THIS")
  static dynamic mergeMirror(
    List<ISpiderAdapter> extend,
    List<MacCMSSpider> newSourceData, {
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

    var inputData = extend;
    inputData = inputData.map((e) {
      return e as MacCMSSpider;
    }).toList();
    // return [0, []];
    var copyData = (inputData as List<MacCMSSpider>).map(
      (e) {
        return {
          'name': e.meta.name,
          'logo': e.meta.logo,
          'desc': e.meta.desc,
          'nsfw': e.meta.isNsfw,
          'jiexiUrl': e.meta.extra['jiexiUrl'] ?? '',
          'api': e.meta.api,
          'id': e.meta.id,
          'status': e.meta.status,
        };
      },
    ).toList();
    if (diff) {
      return [newLen - len, copyData];
    }
    return copyData;
  }
}
