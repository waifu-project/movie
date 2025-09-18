import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:dart_qjson/dart_qjson.dart';
import 'package:xi/xi.dart';

const kEvalTimeout = Duration(seconds: 6);

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
      var text = item.get("text").toString();
      var id = item.get("id").toString();
      result.add(SourceSpiderQueryCategory(text, id));
    });
    return result;
  }

  List<VideoDetail> parseListWithJSResult(String _result) {
    var jsonList = JsonList.fromJsonString(_result);
    List<VideoDetail> result = [];
    jsonList.forEach((item) {
      var cover = item.get("cover").toString();
      var title = item.get("title").toString();
      var id = item.get("id").toString();
      var remark = item.get("remark").toString();
      var playlist = item.getList("playlist");
      List<Videos> realVideos = [];
      if (playlist != null && playlist.isNotEmpty) {
        var videoInfos = playlist.map((item) {
          return VideoInfo(
            name: item.get("text").toString(),
            url: item.get("id").toString(),
            type: VideoType.iframe,
          );
        }).toList();
        realVideos.add(
          Videos(
            title: "默认",
            datas: videoInfos,
          ),
        );
      }
      result.add(
        VideoDetail(
          id: id,
          title: title,
          remark: remark,
          extra: {},
          videos: realVideos,
          smallCoverImage: cover,
        ),
      );
    });
    return result;
  }

  Map<String, dynamic> get _jsMap => meta.extra['js'] ?? {};

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
    return _jsMap[type.name] ?? "";
  }

  String _realCode(JSCodeType type, {Map<String, dynamic>? params}) {
    var logic = _getLogicJSCode(type);
    return _generateJSCode(logic, params: params);
  }

  @override
  Future<List<SourceSpiderQueryCategory>> getCategory() async {
    var result = await js2.evalSync(
      _realCode(JSCodeType.category),
      timeout: kEvalTimeout,
    );
    return parseCategoryWithJSResult(result);
  }

  @override
  Future<List<VideoDetail>> getHome({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    var result = await js2.evalSync(
        _realCode(JSCodeType.home, params: {
          "category": category,
          "page": page,
          "limit": limit,
        }),
        timeout: kEvalTimeout);
    return parseListWithJSResult(result);
  }

  @override
  Future<VideoDetail> getDetail(String movieId) async {
    var result = await js2.evalSync(
        _realCode(JSCodeType.detail, params: {
          "movieId": movieId,
        }),
        timeout: kEvalTimeout);
    return parseListWithJSResult(result)[0];
  }

  @override
  Future<List<VideoDetail>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    var result = await js2.evalSync(
        _realCode(JSCodeType.search, params: {
          "page": page,
          "limit": limit,
          "keyword": keyword,
        }),
        timeout: kEvalTimeout);
    return parseListWithJSResult(result);
  }

  @override
  bool get isNsfw => meta.isNsfw;

  @override
  Future<List<String>> parseIframe(String iframe) async {
    var result = await js2.evalSync(
        _realCode(JSCodeType.parseIframe, params: {
          "iframe": iframe,
        }),
        timeout: kEvalTimeout);
    return [result];
  }
}
