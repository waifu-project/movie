import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:dart_qjson/dart_qjson.dart';
import 'package:xi/xi.dart';
import 'package:xi/adapters/template.dart';

const kEvalTimeout = Duration(seconds: 6);

var kJSEmptyException = Exception("JS 代码为空");

extension BetterJSONList on JsonList {
  void forEach(ValueChanged<JsonObject> cb) {
    for (var i = 0; i < length; i++) {
      JsonObject cx = getObject(i)!;
      cb(cx);
    }
  }

  List<T> map<T>(T Function(JsonObject value) cb) {
    List<T> result = [];
    forEach((item) {
      result.add(cb(item));
    });
    return result;
  }
}

extension BetterJsonObject on JsonObject {
  String $getString(String key, {String defaultValue = ""}) {
    var cx = get(key);
    if (cx == null || cx.isNull) return defaultValue;
    return cx.toString();
  }

  JsonList $getList(String key) {
    var cx = getList(key);
    if (cx == null || cx.isEmpty) return JsonList([]);
    return cx;
  }
}

enum JSCodeType {
  category,
  home,
  search,
  detail,
  parseIframe,
}

class UniversalSpider extends ISpiderAdapter {
  UniversalSpider(SourceMeta sourceMeta) {
    meta = sourceMeta;
  }

  String get url => meta.api;

  List<SourceSpiderQueryCategory> parseCategoryWithJSResult(String _result) {
    var jsonList = JsonList.fromJsonString(_result);
    List<SourceSpiderQueryCategory> result = [];
    jsonList.forEach((item) {
      var text = item.$getString("text", defaultValue: "默认");
      var id = item.$getString("id");
      result.add(SourceSpiderQueryCategory(text, id));
    });
    return result;
  }

  List<Videos> parsePlaylistWithJSONList(JsonList? cx) {
    if (cx == null || cx.isEmpty) return [];
    List<Videos> realVideos = [];
    cx.forEach((item) {
      var title = item.$getString("title", defaultValue: "默认");
      var videos = item.$getList("videos");
      var videoInfos = videos.map((subItem) {
        var name = subItem.$getString("text", defaultValue: "默认");
        var id = subItem.$getString("id"); // id => iframe
        var url = subItem.$getString("url"); // url => m3u8
        VideoType type = VideoType.m3u8;
        if (id.isNotEmpty) {
          type = VideoType.iframe;
          url = id;
        }
        return VideoInfo(
          name: name,
          url: url,
          type: type,
        );
      }).toList();
      realVideos.add(Videos(title: title, datas: videoInfos));
    });
    return realVideos;
  }

  List<VideoDetail> parseListWithJSResult(String _result) {
    var jsonList = JsonList.fromJsonString(_result);
    List<VideoDetail> result = [];
    jsonList.forEach((item) {
      var cover = item.$getString("cover");
      var title = item.$getString("title");
      var desc = item.$getString("desc");
      var id = item.$getString("id");
      var remark = item.$getString("remark");
      var playlist = item.$getList("playlist");
      var realVideos = parsePlaylistWithJSONList(playlist);
      result.add(
        VideoDetail(
          id: id,
          title: title,
          desc: desc,
          smallCoverImage: cover,
          remark: remark,
          videos: realVideos,
          extra: {},
        ),
      );
    });
    return result;
  }

  Map<String, dynamic> get _jsMap => meta.extra['js'] ?? {};

  String? get _templateId => meta.extra['template'];

  bool get _hasTemplate => _templateId != null && _templateId!.isNotEmpty;

  String _generateJSCode(String realCode, {Map<String, dynamic>? params}) {
    var ps = jsonEncode(params ?? {});
    var result = """
(async ()=> {
  const env = {
    get(key, defaultValue) {
      return this.params[key] ?? defaultValue
    },
    baseUrl: `$url`,
    params: $ps,
  };
  $realCode
})()""";
    return result;
  }

  String _getLogicJSCode(JSCodeType type) {
    // 如果有模板ID，优先使用模板中的JS代码
    if (_hasTemplate) {
      try {
        var template = jsTemplate.get(_templateId!);
        var code = template.get(type);
        if (code.isNotEmpty) {
          return code;
        }
      } catch (e) {
        // 模板不存在或获取失败，回退到原始逻辑
      }
    }
    
    // 使用原始的JS配置
    var code = _jsMap[type.name];
    if (code is! String) {
      return jsonEncode(code);
    }
    return _jsMap[type.name] ?? "";
  }

  String _realCode(JSCodeType type, {Map<String, dynamic>? params}) {
    var logic = _getLogicJSCode(type);
    if (logic.isEmpty) return "";
    return _generateJSCode(logic, params: params);
  }

  @override
  Future<List<SourceSpiderQueryCategory>> getCategory() async {
    var cates = _getLogicJSCode(JSCodeType.category);
    if (cates.isEmpty) return [];
    if (getJSONBodyType(cates) == JSONBodyType.array) {
      var result = JsonList.fromJsonString(cates).map((item) {
        return SourceSpiderQueryCategory(
          item.$getString("text"),
          item.$getString("id"),
        );
      });
      return result;
    }
    var code = _generateJSCode(cates);
    var result = await js2.evalSync(code, timeout: kEvalTimeout);
    return parseCategoryWithJSResult(result);
  }

  @override
  Future<List<VideoDetail>> getHome({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    var code = _realCode(JSCodeType.home, params: {
      "category": category,
      "page": page,
      "limit": limit,
    });
    if (code.isEmpty) throw kJSEmptyException;
    var result = await js2.evalSync(code, timeout: kEvalTimeout);
    return parseListWithJSResult(result);
  }

  @override
  Future<VideoDetail> getDetail(String movieId) async {
    var code = _realCode(JSCodeType.detail, params: {
      "movieId": movieId,
    });
    if (code.isEmpty) throw kJSEmptyException;
    var result = await js2.evalSync(code, timeout: kEvalTimeout);
    var resultWithArray = "[$result]";
    return parseListWithJSResult(resultWithArray)[0];
  }

  @override
  Future<List<VideoDetail>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    var code = _realCode(JSCodeType.search, params: {
      "page": page,
      "limit": limit,
      "keyword": keyword,
    });
    if (code.isEmpty) [];
    var result = await js2.evalSync(code, timeout: kEvalTimeout);
    return parseListWithJSResult(result);
  }

  @override
  bool get isNsfw => meta.isNsfw;

  @override
  Future<List<String>> parseIframe(String iframe) async {
    var code = _realCode(JSCodeType.parseIframe, params: {
      "iframe": iframe,
    });
    if (code.isEmpty) return [];
    var result = await js2.evalSync(code, timeout: kEvalTimeout);
    // 返回的貌似是 '"xx.m3u8"'
    // 所以可能还需要在解析一下
    String realResult = jsonDecode(result);
    return [realResult];
  }
}

class Template {
  Map<JSCodeType, String> jsCodeMap = {};
  Template(this.jsCodeMap);
  String get(JSCodeType type) {
    return jsCodeMap[type] ?? "";
  }
}

class Templates {
  Map<String, Template> templates = {};
  Templates(this.templates);
  Template get(String id) {
    return templates[id]!;
  }
}