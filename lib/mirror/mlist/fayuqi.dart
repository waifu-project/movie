import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:movie/impl/movie.dart';
import 'package:movie/mirror/mirror_serialize.dart';
import 'package:movie/utils/http.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'fayuqi_models/vod_case.dart';
import 'fayuqi_models/vod_detail.dart';
import 'fayuqi_models/vod_movie.dart';
import 'fayuqi_models/vod_play.dart';

String createVodTypeURLAsObj(VodType _type) {
  return createVodTypeURL(_type.id);
}

String createVodTypeURL(int id) {
  return "/vodtype/$id.html";
}

/// [vodType] 为类型 `id`
/// [action] 为空则为全部
/// [page] 页数
///
/// 不要🙅🏻‍♀️使用 [createVodTypeURL] 函数来生成线路操作
String createVodTypeAndTypeURL({
  required int vodType,
  String action = "",
  int page = 1,
}) {
  return "/vodshow/$vodType---$action-----$page---.html";
}

String createVodDetailURL(String detailID) {
  return "/voddetail/$detailID.html";
}

String createArtDetailURL(String id) {
  return "/artdetail-$id.html";
}

String createSearchURL(String keyword) {
  return "/vodsearch/----$keyword---------.html";
}

String createVodPlayURL(String id) {
  return "/vodplay/$id.html";
}

/// 查询字段类型
enum PageQueryStringType {
  /// 搜索
  search,

  /// 线路
  vodtype,
}

extension SelfToString on PageQueryStringType {
  String get action {
    switch (this) {
      case PageQueryStringType.search:
        return "vodsearch";
      case PageQueryStringType.vodtype:
        return "vodtype";
      default:
        return "";
    }
  }
}

class PageQueryStringUtils {
  PageQueryStringUtils({
    required this.data,
    this.page = 1,
    this.type = PageQueryStringType.search,
  });

  int page;
  String data;
  final PageQueryStringType type;

  /// 根据 [page] 是否 `<=` 1
  bool get isPrev => page <= 1;

  @override
  String toString() {
    return "/${type.action}/$data----------$page---.html";
  }
}

RespPageData getRespPageData(DocumentFragment document) {
  int total = -1;
  int current = -1;
  int totalPage = -1;

  var pageTip = document.querySelector(".page_tip")?.text.trim() ?? "";
  if (pageTip == "共0条数据,当前/页") {
    debugPrint("搜索的内容为空");
  } else {
    // 共1443条数据,当前1/145页
    var _pageCache = pageTip.split("条数据");
    total = int.tryParse(_pageCache[0].substring(1)) ?? 0;
    var _pageNumberCache1 = _pageCache[1].split(",当前")[1];
    var _pageNumberCache = _pageNumberCache1.substring(
      0,
      _pageNumberCache1.length - 1,
    );
    var _pageNumberTarget = _pageNumberCache.split("/");
    current = int.tryParse(_pageNumberTarget[0]) ?? 0;
    totalPage = int.tryParse(_pageNumberTarget[1]) ?? 0;
    debugPrint("total: $total\n");
    debugPrint("current: $current\n");
    debugPrint("total_page: $totalPage\n");
  }
  return RespPageData(
    total: total,
    current: current,
    totalPage: totalPage,
  );
}

/// 获取 `vod-type`
List<VodType> getVodType(DocumentFragment $) {
  var _tags = $.querySelectorAll(".resou a");
  var tags = _tags.map((item) {
    var id = int.parse(item.attributes['href']!.split("/")[2].split(".")[0]);
    var text = item.text;
    return VodType(id: id, title: text);
  }).toList();
  return tags;
}

/// 获取 `vod-card`
List<VodCard> getVodCard(Element? $alias) {
  var _ = _commonParseCard($alias)
      .map(
        (e) => VodCard(
          id: e['id'] ?? "",
          cover: e['image'] ?? "",
          title: e['title'] ?? "",
        ),
      )
      .toList();
  return _;
}

List<Map<String, String?>> _commonParseCard(Element? ele) {
  var data = ele!.querySelectorAll("li").map((item) {
    var ele = item.querySelector("a");
    var eleAttr = ele?.attributes;
    var link = eleAttr?["href"]?.trim();
    var title = eleAttr?["title"]?.trim();
    var id = link?.split("/voddetail/")[1].split(".html")[0];
    var image = ele!.querySelector("img")?.attributes["src"]?.trim();
    return {
      "id": id,
      "image": image,
      "title": title,
    };
  }).toList();
  return data;
}

class FayuQiMirror extends MovieImpl {
  String root_url = "https://www.fayuqi2.xyz";

  String createUrl({
    String path = '/',
  }) {
    return root_url + path;
  }

  Future<MovieVodPlay> getVodPlayURL(String id) async {
    var resp = await XHttp.dio.get(
      createUrl(
        path: createVodPlayURL(id),
      ),
    );
    var data = resp.data;
    var $ = parseFragment(data);
    var select = $.querySelector("#bofang_box script");
    var text = select!.text.trim();
    var fristIndex = text.indexOf("{");
    var parseTarget = "";
    if (fristIndex >= 0) {
      var _idl = text[fristIndex - 1];
      if (_idl == " " || _idl == "=") {
        parseTarget = text.substring(fristIndex);
      }
    }
    if (parseTarget.isEmpty) {
      throw AsyncError(
        "parse error",
        StackTrace.fromString("解析失败"),
      );
    }
    List<VodCard> vodCard = $.querySelectorAll(".img-list li").map((e) {
      var title = e.querySelector("h2")?.text.trim() ?? "";
      var cover = e.querySelector("img")?.attributes["src"]?.trim() ?? "";
      var id = e
          .querySelector("a")
          ?.attributes["href"]
          ?.split("/")[2]
          .split(".html")[0]
          .trim();
      return VodCard(
        id: id ?? "",
        cover: cover,
        title: title,
      );
    }).toList();
    var _data = movieVodPlayCodeDataFromMap(parseTarget);
    return MovieVodPlay(
      player: VodPlayer(
        url: _data.url,
        title: '在线播放',
      ),
      recommend: vodCard,
    );
  }

  @override
  Future<MirrorOnceItemSerialize> getDetail(String id) async {
    var url = createUrl(path: createVodDetailURL(id));
    var resp = await XHttp.dio.get(url);
    var data = resp.data;
    var $ = parseFragment(data);
    var cover = $.querySelector(".detail-pic img")!.attributes["src"] ?? "";
    var title = $.querySelector(".detail-title")!.text.trim();
    var descHtml = $.getElementById("juqing")?.innerHtml.trim() ?? "";
    List<VodPlayer> player = $.querySelectorAll(".video_list a").map((e) {
      var title = e.text.trim();
      var url = e.attributes["href"]!.split("/")[2].split(".html")[0].trim();
      return VodPlayer(title: title, url: url);
    }).toList();
    var futures = await Future.wait(player.map((e) async {
      var data = await getVodPlayURL(e.url);
      var _player = data.player;
      return MirrorSerializeVideoInfo(
        url: _player.url,
        type: MirrorSerializeVideoType.m3u8,
        name: _player.title,
      );
    }).toList());
    return MirrorOnceItemSerialize(
      smallCoverImage: cover,
      title: title,
      id: id,
      desc: descHtml,
      videos: futures,
    );
  }

  @override
  Future<List<MirrorOnceItemSerialize>> getHome({
    int page = 1,
    int limit = 10,
  }) async {
    var resp = await XHttp.dio.get(createUrl());
    var data = resp.data;
    var $ = parseFragment(data);
    var cards = $
        .querySelectorAll(".box")
        .sublist(0, 2)
        .map((e) => HomeCard(vodCards: getVodCard(e)))
        .toList();
    List<MirrorOnceItemSerialize> result = [];
    cards.forEach((element) {
      element.vodCards.forEach((vodCard) {
        result.add(
          MirrorOnceItemSerialize(
            id: vodCard.id,
            smallCoverImage: vodCard.cover,
            title: vodCard.title,
          ),
        );
      });
    });
    return result;
  }

  @override
  Future<List<MirrorOnceItemSerialize>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    var _page = PageQueryStringUtils(
      data: keyword,
      page: page,
    );
    var _url = createUrl(
      path: _page.toString(),
    );
    var resp = await XHttp.dio.get(_url);
    var document = parseFragment(resp.data);
    var listNode = document.querySelectorAll("#list-focus li");

    List<VodCard> cards = listNode.map((e) {
      var playIMG = e.querySelector(".play-img");
      var img = playIMG?.querySelector("img");
      var title = img?.attributes["alt"]?.trim() ?? "";
      var id =
          playIMG?.attributes["href"]?.split("/")[2].split(".html")[0] ?? "";
      var image = img?.attributes["src"]?.trim() ?? "";
      return VodCard(
        cover: image,
        id: id,
        title: title,
      );
    }).toList();
    return cards.map((e) {
      return MirrorOnceItemSerialize(
        id: e.id,
        smallCoverImage: e.cover,
        title: e.title,
      );
    }).toList();
  }

  @override
  bool get isNsfw => true;

  @override
  MovieMetaData get meta => MovieMetaData(
        name: '发育期',
        domain: root_url,
        logo: 'https://www.fayuqi2.xyz/favicon.ico',
      );
}
