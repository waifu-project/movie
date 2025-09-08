// https://github.com/cuiocean/ZY-Player-APP/blob/main/utils/request.js

// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:xi/xi.dart';
import '../models/mac_cms/xml_data.dart';
import '../models/mac_cms/xml_search_data.dart';
import 'package:xml2json/xml2json.dart';
import 'package:path/path.dart' as path;

/// m3u8 | mp4 都会抓取到
final kIframeParseRegex = RegExp("[\"']([^\"']+.(m3u8|mp4))[\"']");

/// 请求返回的内容
enum ResponseCustomType {
  xml,

  json,

  /// 未知
  unknow
}

class MacCMSSpider extends ISpiderAdapter {
  final bool nsfw;
  final String jiexiUrl;
  final String name;
  final String logo;
  final String desc;
  final String root_url;
  final String api_path;
  final String id;
  final bool status;
  MacCMSSpider({
    this.nsfw = false,
    this.name = "",
    this.logo = "",
    this.desc = "",
    this.jiexiUrl = "",
    this.status = true,
    required this.id,
    required this.root_url,
    required this.api_path,
  });

  String createUrl({
    required String suffix,
  }) {
    return root_url + suffix;
  }

  Options ops = Options(responseType: ResponseType.plain);

  bool get hasJiexiUrl {
    return jiexiUrl.isNotEmpty;
  }

  String _normalDesc(String raw) {
    return kUnescape.convert(raw);
  }

  /// 简单获取视频链接类型
  static VideoType easyGetVideoType(String rawUrl) {
    var ext = path.extension(rawUrl);
    switch (ext) {
      case '.m3u8':
      case '.m3u':
        return VideoType.m3u8;
      case '.mp4':
        return VideoType.mp4;
      default:
        return VideoType.iframe;
    }
  }

  /// 尽可能的拿到视频链接
  ///
  /// 规则:
  /// => `在线播放$https://vod3.jializyzm3u8.com/20210819/9VhEvIhE/index.m3u8`
  ///
  String easyGetVideoURL(dynamic raw) {
    if (raw == null) return "";
    var _raw = raw.toString().trim();
    if (isURL(_raw)) return _raw;
    var _block = _raw.split("\$");
    if (_block.length >= 3) return _raw;
    var sybIndex = _raw.indexOf("\$");
    if (sybIndex >= 0) {
      return _raw.substring(sybIndex + 1);
    }
    return "";
  }

  String get _responseParseFail => "接口返回值解析错误 :(";

  /// 获取结构类型并且检测一下请求之后返回的内容
  ///
  /// 如果是内容为 [ResponseCustomType.unknow] 则抛出异常
  ResponseCustomType getResponseTypeAndCheck(dynamic data) {
    ResponseCustomType _type = getResponseType(data);
    if (_type == ResponseCustomType.unknow) {
      throw AsyncError(
        _responseParseFail,
        StackTrace.fromString(_responseParseFail),
      );
    }
    return _type;
  }

  @override
  Future<VideoDetail> getDetail(String movieId) async {
    var resp = await XHttp.dio.post(
      createUrl(suffix: api_path),
      queryParameters: {
        "ac": "videolist",
        "ids": movieId,
      },
      options: ops,
    );
    var _type = getResponseTypeAndCheck(resp.data);
    if (_type == ResponseCustomType.json) {
      return _parseDetailJSON(resp.data);
    }
    return _parseDetailXML(resp.data);
  }

  @override
  Future<List<VideoDetail>> getHome({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    var qs = {
      "ac": "videolist",
      "pg": page,
    };
    if (category != null && category.isNotEmpty) {
      qs['t'] = category;
    }
    var resp = await XHttp.dio.get(
      createUrl(suffix: api_path),
      queryParameters: qs,
      options: ops,
    );
    dynamic data = resp.data;
    var _type = getResponseTypeAndCheck(data);
    if (_type == ResponseCustomType.json) {
      return _parseHomeJSON(data);
    }
    return _parseHomeXML(data);
  }

  /// 匹配的规则:
  ///   https://www.88zy.net/upload/vod/2020-10-26/202010261603727118.jpg\r\\n
  String normalizeCoverImage(String rawString) {
    String syb = r'\r\\n';
    var index = rawString.lastIndexOf(syb);
    var _offset = rawString.length - syb.length;
    if (index == _offset) return rawString.substring(0, index);
    return rawString;
  }

  ///   返回值比对 [kv]
  final Map<String, ResponseCustomType> _RespCheckkv = {
    "{\"": ResponseCustomType.json,
    "<?xml": ResponseCustomType.xml,
  };

  /// 获取返回内容的类型
  /// return [ResponseCustomType]
  ///
  /// 通过判断内容的首部分字符
  ///
  /// `json` 参考:
  /// ```markdown
  ///   `{"`
  /// ```
  ///
  /// `xml` 参考:
  /// ```makrdown
  ///   `<?xml`
  /// ```
  ResponseCustomType getResponseType(String checkText) {
    if (checkText.length < 2) return ResponseCustomType.unknow;
    var _k = _RespCheckkv.keys.where((_key) {
      int _len = _key.length;
      var _sub = checkText.substring(0, _len);
      bool _if = _sub.contains(_key, 0);
      return _if;
    }).toList();

    if (_k.isNotEmpty) {
      return _RespCheckkv[_k[0]] as ResponseCustomType;
    }

    return ResponseCustomType.unknow;
  }

  @override
  Future<List<VideoDetail>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    var resp = await XHttp.dio.post(
      createUrl(suffix: api_path),
      queryParameters: {
        "ac": "videolist",
        // "t": limit,
        "pg": page,
        "wd": keyword,
      },
      options: ops,
    );
    dynamic data = resp.data;
    var _type = getResponseTypeAndCheck(data);
    if (_type == ResponseCustomType.json) {
      return _parseSearchJSON(data);
    }
    return _parseSearchXML(data);
  }

  @override
  bool get isNsfw => nsfw;

  @override
  SourceItemMeta get meta => SourceItemMeta(
        name: name,
        logo: logo,
        desc: desc,
        domain: root_url,
        id: id,
        status: status,
      );

  @override
  Future<List<SourceSpiderQueryCategory>> getCategory() async {
    var path = createUrl(suffix: api_path);
    var resp = await XHttp.dio.get(path);
    dynamic data = resp.data;
    var _type = getResponseTypeAndCheck(data);
    if (_type == ResponseCustomType.json) {
      return _parseCategoryJSON(data);
    }
    return _parseCategoryXML(data);
  }

  dynamic _parseDetailJSON(dynamic data) {
    if (data is! String) {
      throw AsyncError(
        _responseParseFail,
        StackTrace.fromString(_responseParseFail),
      );
    }
    var list = _getJSONList(data);
    if (list.isEmpty) {
      throw AsyncError(
        _responseParseFail,
        StackTrace.fromString(_responseParseFail),
      );
    }
    return list[0];
  }

  VideoDetail _parseDetailXML(dynamic data) {
    var x2j = Xml2Json();
    x2j.parse(data);
    var _json = x2j.toBadgerfish();
    var cx = json.decode(_json);
    KBaseMovieXmlData xml = KBaseMovieXmlData.fromJson(cx);
    var video = xml.rss.list.video;
    var cards = video.map(
      (e) {
        var __dd = e.dl.dd;
        List<VideoInfo> videos = __dd.map((item) {
          return VideoInfo(
            url: easyGetVideoURL(item.cData),
            name: item.flag,
            type: easyGetVideoType(item.cData),
          );
        }).toList();
        var pic = normalizeCoverImage(e.pic);
        return VideoDetail(
          id: e.id,
          smallCoverImage: pic,
          title: e.name,
          videos: videos,
          desc: _normalDesc(e.des),
          updateTime: e.last,
          remark: e.note,
          extra: {},
        );
      },
    ).toList();
    if (cards.isEmpty) {
      throw UnimplementedError();
    }
    return cards[0];
  }

  dynamic _parseSearchJSON(dynamic data) {
    if (data is! String) {
      throw AsyncError(
        _responseParseFail,
        StackTrace.fromString(_responseParseFail),
      );
    }
    return _getJSONList(data);
  }

  List<VideoDetail> _parseSearchXML(dynamic data) {
    var x2j = Xml2Json();
    x2j.parse(data);
    var _json = x2j.toBadgerfish();
    KBaseMovieSearchXmlData searchData = kBaseMovieSearchXmlDataFromJson(_json);
    var defaultCoverImage = meta.logo;
    List<VideoDetail> result = searchData.rss?.list?.video!
            .map(
              (e) => VideoDetail(
                id: e.id ?? "",
                smallCoverImage: defaultCoverImage,
                title: e.name?.cdata ?? "",
                updateTime: e.last == null ? "" : e.last!.toIso8601String(),
                remark: e.note?.cdata ?? "",
                extra: {},
              ),
            )
            .toList() ??
        [];
    return result;
  }

  List<SourceSpiderQueryCategory> _parseCategoryJSON(dynamic data) {
    if (data is! String) {
      throw AsyncError(
        _responseParseFail,
        StackTrace.fromString(_responseParseFail),
      );
    }
    var json = jsonDecode(data);
    List<Map<String, dynamic>> cx = json['class'].cast<Map<String, dynamic>>();
    var result = <SourceSpiderQueryCategory>[];
    for (var item in cx) {
      var name = item['type_name'] ?? "";
      var _id = item['type_id'];
      late String id;
      if (_id is int) {
        id = _id.toString();
      } else {
        id = _id;
      }
      result.add(SourceSpiderQueryCategory(name, id));
    }
    return result;
  }

  List<SourceSpiderQueryCategory> _parseCategoryXML(dynamic data) {
    var x2j = Xml2Json();
    x2j.parse(data);
    var _json = x2j.toBadgerfish();
    var cx = json.decode(_json);
    KBaseMovieXmlData xml = KBaseMovieXmlData.fromJson(cx);
    return xml.rss.category;
  }

  List<VideoDetail> _parseHomeXML(dynamic data) {
    var x2j = Xml2Json();
    x2j.parse(data);
    var _json = x2j.toBadgerfish();
    var cx = json.decode(_json);
    KBaseMovieXmlData xml = KBaseMovieXmlData.fromJson(cx);
    return xml.rss.list.video.map(
      (e) {
        var __dd = e.dl.dd;
        List<VideoInfo> videos = __dd.map((item) {
          return VideoInfo(
            url: easyGetVideoURL(item.cData),
            name: item.flag,
            type: easyGetVideoType(item.cData),
          );
        }).toList();
        var pic = normalizeCoverImage(e.pic);
        return VideoDetail(
          id: e.id,
          smallCoverImage: pic,
          title: e.name,
          videos: videos,
          desc: _normalDesc(e.des),
          updateTime: e.last,
          remark: e.note,
          extra: {},
        );
      },
    ).toList();
  }

  List<VideoDetail> _parseHomeJSON(dynamic data) {
    if (data is! String) {
      throw AsyncError(
        _responseParseFail,
        StackTrace.fromString(_responseParseFail),
      );
    }
    return _getJSONList(data);
  }

  List<VideoDetail> _getJSONList(dynamic jsonData) {
    var json = jsonDecode(jsonData);
    var list = json['list']; //;
    var result = <VideoDetail>[];
    if (list is Map) {
      var cx = list as Map<String, dynamic>;
      result.add(__parseListItem(cx));
    } else if (list is List) {
      for (var item in list.cast<Map<String, dynamic>>()) {
        result.add(__parseListItem(item));
      }
    }
    return result;
  }

  // [0] => episode(name)
  // [1] => url
  List<String> __parseVideoInfo(String input) {
    // 第一集$https://x.dev/1.m3u8
    if (input.contains("\$")) {
      return input.split("\$");
    }
    // 第一集https://x.dev/1.m3u8
    // 第二集https://x.dev/2.m3u8
    const String httpsPrefix = 'https://';
    const String httpPrefix = 'http://';
    int urlStartIndex = input.indexOf(httpsPrefix);
    if (urlStartIndex == -1) {
      urlStartIndex = input.indexOf(httpPrefix);
    }
    if (urlStartIndex == -1) {
      return []; // throw error
    }
    String episode = input.substring(0, urlStartIndex).trim();
    String url = input.substring(urlStartIndex).trim();
    return [episode, url];
  }

  VideoDetail __parseListItem(dynamic item) {
    var videos = <VideoInfo>[];
    // 参考格式: vod_play_from":"ukyun$$$ukm3u8","vod_play_server":"no$$$no","vod_play_note":"$$$","vod_play_url": "xxxx$$$xxxxx"
    String vodFrom = item["vod_play_from"];
    String vodNote = item['vod_play_note'];
    String _vodURL = (item['vod_play_url'] ?? "");
    late List<String> tags;
    if (vodNote.isNotEmpty) {
      tags = vodFrom.split(vodNote /* $$$ */);
    } else {
      tags = [vodFrom];
    }
    String vodURL = _vodURL.replaceAll(RegExp(r'#$'), '');
    List<String> _t = vodURL.split(vodNote /* $$$ */);
    if (tags.length >= 2) {
      Map<String, List<VideoInfo>> _cx = {};
      for (final (index, subItem) in _t.indexed) {
        var _nameKey = tags[index];
        List<VideoInfo> _map =
            subItem.split("#").where((e) => e.trim().isNotEmpty).map((item) {
          List<String> items = __parseVideoInfo(item);
          if (items.length == 1) {}
          return VideoInfo(
            name: items[0],
            url: items[1],
            type: easyGetVideoType(items[1]),
          );
        }).toList();
        _cx[_nameKey] = _map;
      }
      _cx.forEach((key, value) {
        var url = value
            .map((item) {
              /// 这里转成 [videoInfo2PlayListData] 需要的格式
              return "${item.name}\$${item.url}";
            })
            .toList()
            .join("#");
        var video = VideoInfo(name: key, url: url);
        videos.add(video);
      });
    } else if (tags.length == 1) {
      videos.add(VideoInfo(name: tags[0], url: _vodURL));
    }
    var _id = item['vod_id'];
    late String id;
    if (_id is int) {
      id = _id.toString();
    } else {
      id = _id;
    }
    var detail = VideoDetail(
      id: id,
      title: item['vod_name'] ?? "",
      desc: _normalDesc(item['vod_blurb'] ?? ""),
      updateTime: item["vod_time"] ?? "",
      remark: item["vod_remarks"] ?? "",
      smallCoverImage: item['vod_pic'] ?? "",
      videos: videos,
      extra: {},
    );
    return detail;
  }

  @override
  String toString() {
    var output = "\n";
    output += "name: $name\n";
    output += " url: $root_url$api_path";
    return output;
  }

  List<String> _parseIframe(String iframe, String body) {
    var url = Uri.tryParse(iframe);
    if (url == null) return [];
    var domain = "${url.scheme}://${url.host}";
    final List<String> m3u8Links = [];
    for (final Match match in kIframeParseRegex.allMatches(body)) {
      if (match.groupCount >= 1) {
        String? link = match.group(1);
        if (link != null && link.isNotEmpty) {
          if (!(link.startsWith("http://") || link.startsWith("https://"))) {
            /// 如果 $link 前缀不是 /xx/xx.m3u8 那就惨了!
            link = "$domain$link";
          }
          m3u8Links.add(link);
        }
      }
    }
    return m3u8Links;
  }

  @override
  // TODO(d1y): 这个应该交由原配置去解析, 这里的通用解析只是为了乐呵乐呵(某些估计解析不了?)
  Future<List<String>> parseIframe(String iframe) async {
    try {
      var resp = await XHttp.dio.get<String>(iframe);
      var htmlText = resp.data ?? "";
      return _parseIframe(iframe, htmlText);
    } catch (e) {
      return []; // catch error
    }
  }
}
