import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movie/spider/shared/manage.dart';
import 'package:movie/spider/models/mac_cms/source_data.dart';
import 'package:movie/utils/helper.dart';
import 'package:movie/utils/http.dart';
import 'package:movie/utils/json.dart';
import 'package:movie/utils/xid.dart';

import '../impl/mac_cms.dart';

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

  /// TODO
  /// [url] 需要测试的链接
  /// 支持类型
  ///   github.com/d1y/1/2.json
  ///   d1y/repo/1/2.json
  static bool isGithubUrl(String url) {
    return false;
  }

  /// TODO
  /// 通过 [isGithubUrl] 判断
  /// 如果是 `github` 链接的话就通过这个方法
  /// 生成一个 `jsdelivr` cdn 链接用于下载
  static String shortToGithubCDNURL() {
    return "";
  }

  static MacCMSSpider? parse(Map<String, dynamic> rawData) {
    List<dynamic> tryData = tryParseData(rawData);
    bool status = tryData[0];
    if (status) {
      var data = tryData[1] as SourceJsonData;
      var id = data.id;
      if (id == null || id.isEmpty) {
        id = Xid().toString();
      }
      return MacCMSSpider(
        logo: data.logo ?? "",
        name: data.name ?? "",
        desc: data.desc ?? "",
        api_path: data.api!.path ?? "",
        root_url: data.api!.root ?? "",
        nsfw: data.nsfw ?? false,
        id: id,
        status: data.status ?? true,
        jiexiUrl: data.jiexiUrl ?? "",
      );
    } else {
      return null;
    }
  }

  /// 校验数据处理边界情况
  ///
  /// ```markdown
  /// 1. 必须存在 `name`
  /// 2. 必须有 `api` => `root` + `path`
  /// ```
  ///
  /// 返回一个数组
  ///
  /// ```js
  /// [
  ///   status: bool,
  ///   data: SourceJsonData
  /// ]
  /// ```
  static List<dynamic> tryParseData(Map<String, dynamic> rawData) {
    String? name = rawData['name'];
    bool hasName = name != null;
    var api = rawData['api'];
    var id = rawData['id'];
    var jiexiUrl = rawData['jiexiUrl'];

    /// => zy-player 源
    if (id != null) {
      Uri? url;
      if (api is String) {
        url = Uri.parse(api);
      } else if (api is Map<String, dynamic>) {
        url = Uri.parse(api['root'] + api['path']);
      }
      if (url == null) return [false, null];

      if (hasName) {
        bool isNsfw = (rawData['group'] ?? "") == "18禁";
        var data = SourceJsonData(
          name: name,
          logo: "",
          desc: "",
          nsfw: isNsfw,
          jiexiUrl: jiexiUrl,
          api: Api(
            path: url.path,
            root: url.origin,
          ),
        );
        return [true, data];
      }
      return [false, null];
    }
    if (api == null) return [false, null];
    var apiStru = Api.fromJson(api);
    var root = apiStru.root;
    if (!isURL(root)) return [false, null];
    var normalizedData = SourceJsonData(
      name: name,
      logo: rawData["logo"],
      desc: rawData["desc"],
      nsfw: rawData["nsfw"],
      jiexiUrl: jiexiUrl,
      api: apiStru,
    );
    return [true, normalizedData];
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
      dynamic jsonData = jsonDecode(data);
      if (typeAs == JSONBodyType.array) {
        List<dynamic> cache = jsonData as List<dynamic>;
        List<Map<String, dynamic>> cacheAsMap = cache.map((item) {
          return item as Map<String, dynamic>;
        }).toList();
        return tryParseDynamic(cacheAsMap);
      } else {
        var bindKey = 'mirrors';
        var jsonDataAsMap = jsonData as Map<String, dynamic>;
        if (jsonDataAsMap.containsKey(bindKey)) {
          var cache = jsonDataAsMap[bindKey];
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
      try {
        var time = const Duration(seconds: 1);
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
  static dynamic mergeMirror(
    List<MacCMSSpider> newSourceData, {
    bool diff = false,
  }) {
    int len = SpiderManage.extend.length;

    for (var element in newSourceData) {
      var newDataDomain = element.meta.domain;
      SpiderManage.extend.removeWhere(
        (element) => element.meta.domain == newDataDomain,
      );
    }

    SpiderManage.extend.addAll(newSourceData);

    int newLen = SpiderManage.extend.length;

    /// 如果比对之后发现没有改变, 则返回 [0, []]
    if (newLen <= 0 && diff) return [0, []];

    var inputData = SpiderManage.extend;
    inputData = inputData.map((e) {
      return e as MacCMSSpider;
    }).toList();
    // return [0, []];
    var copyData = (inputData as List<MacCMSSpider>).map(
      (e) {
        var id = e.meta.id;
        var status = e.meta.status;
        return SourceJsonData(
          name: e.meta.name,
          logo: e.meta.logo,
          desc: e.meta.desc,
          nsfw: e.isNsfw,
          jiexiUrl: e.jiexiUrl,
          api: Api(
            root: e.meta.domain,
            path: e.api_path,
          ),
          id: id,
          status: status,
        );
      },
    ).toList();
    if (diff) {
      return [newLen - len, copyData];
    }
    return copyData;
  }
}
