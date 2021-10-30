// Copyright (C) 2021 d1y <chenhonzhou@gmail.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:movie/impl/movie.dart';
import 'package:html/parser.dart' as html;
import 'package:movie/mirror/mirror_serialize.dart';
import 'package:movie/utils/http.dart';

class fetchMovieFrameURL {
  final String title;
  final String id;

  fetchMovieFrameURL({
    required this.id,
    required this.title,
  });
}

/// 不推荐使用该视频源
/// 该源部分资源都已失效
class NfmovieMirror extends MovieImpl {
  var header = {
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:93.0) Gecko/20100101 Firefox/93.0",
  };

  @override
  Future<MirrorOnceItemSerialize> getDetail(String movie_id) async {
    var detailURL = createURL(path: "/detail/" + movie_id);
    var resp = await XHttp.dio.get(
      detailURL,
      options: Options(
        headers: header,
      ),
    );
    var parse = html.parse(resp.data);
    var ele = parse.querySelector(".myui-panel_hd");
    if (ele == null) throw UnimplementedError();
    var mirrorList = ele.querySelectorAll('li');
    List<fetchMovieFrameURL> frames = [];
    mirrorList.map((e) {
      List<fetchMovieFrameURL> bat = [];
      var link = e.querySelector("a");
      var map = link!.attributes;
      var href = map['href'] ?? "";
      var targetID = href.split("#")[1];
      var _linkText = link.text;
      var mirrorTargetEle = parse.getElementById(targetID);
      if (mirrorTargetEle != null) {
        var list = mirrorTargetEle.querySelectorAll("li");
        List<fetchMovieFrameURL> mirrors = list.map((_e) {
          var subLink = _e.querySelector("a");
          var text = subLink!.text;
          var id = (subLink.attributes['href'] ?? "").split("/")[2];
          var title = _linkText + "-" + text;
          var r = fetchMovieFrameURL(id: id, title: title);
          return r;
        }).toList();
        frames.addAll(mirrors);
        bat = mirrors;
      }
      return bat;
    }).toList();
    var data = await Future.wait<MirrorSerializeVideoInfo>(frames.map(
      (e) async {
        var url = await findIframeM3u8URL(e.id);
        var title = e.title;
        var item = MirrorSerializeVideoInfo(
          url: url,
          type: MirrorSerializeVideoType.iframe,
          name: title,
        );
        return item;
      },
    ).toList());
    var infoEle = parse.querySelector(
      '.myui-vodlist__thumb.img-md-220.img-xs-130.picture',
    );
    var coverImage =
        infoEle!.querySelector("img")?.attributes['data-original'] ?? "";
    var title = infoEle.attributes['title'] ?? "";
    return MirrorOnceItemSerialize(
      id: movie_id,
      smallCoverImage: coverImage,
      title: title,
      videos: data,
    );
  }

  String root = "https://www.nfmovies.com";

  createURL({path = ""}) {
    if (Uri.parse(path).isAbsolute) {
      // print("绝对路径: $path");
      return path;
    }
    return root + path;
  }

  /// 查找类似于: https://www.nfmovies.com/video/${id} 的 `iframe` 播放链接
  /// [MirrorSerializeVideoType.iframe]
  Future<String> findIframeM3u8URL(String id) async {
    var m3u8URL = createURL(path: "/video/" + id);
    var cacheHTML = await XHttp.dio.get(
      m3u8URL,
      options: Options(
        headers: header,
      ),
    );
    var $ = html.parse(cacheHTML.data);
    var scriptEle = $.querySelector(".embed-responsive.clearfix");
    if (scriptEle == null) return "";
    var jscode = scriptEle.text;
    var codes = jscode.split(";");
    var find = codes
        .firstWhere(
          (element) => element.contains(
            "now=unescape",
          ),
        )
        .split("\"");
    if (codes.length >= 3) return find[1];
    return "";
  }

  @override
  Future<List<MirrorOnceItemSerialize>> getHome({
    int page = 1,
    int limit = 10,
  }) async {
    var resp = await XHttp.dio.get(
      root,
      options: Options(
        headers: header,
        responseType: ResponseType.plain,
      ),
    );
    var parse = html.parse(resp.data);
    var dataList = parse.querySelectorAll(
      '.col-lg-6.col-md-6.col-sm-4.col-xs-3',
    );
    List<MirrorOnceItemSerialize> data = dataList.map((ele) {
      return ele2MirrorSerialize(ele);
      // var coverImageElement = ele.querySelector(
      //   '.myui-vodlist__thumb.lazyload',
      // );

      // /// TODO id 未找到则为 `-1`, 需要设置一个常量
      // String id = "-1";
      // var attrs = coverImageElement!.attributes;
      // var detailString = (attrs['href'] as String).split("/");
      // if (detailString.length >= 3) {
      //   id = detailString[2];
      // }
      // String title = attrs['title'] ?? "";
      // String cover = attrs['data-original'] ?? "";
      // cover = createURL(path: cover);
      // var card = MirrorOnceItemSerialize(
      //   id: id,
      //   smallCoverImage: cover,
      //   title: title,
      // );
      // return card;
    }).toList();
    return data;
  }

  MirrorOnceItemSerialize ele2MirrorSerialize(Element e) {
    var coverImageElement = e.querySelector(
      '.myui-vodlist__thumb.lazyload',
    );

    /// TODO id 未找到则为 `-1`, 需要设置一个常量
    String id = "-1";
    var attrs = coverImageElement!.attributes;
    var detailString = (attrs['href'] as String).split("/");
    if (detailString.length >= 3) {
      id = detailString[2];
    }
    String title = attrs['title'] ?? "";
    String cover = attrs['data-original'] ?? "";
    cover = createURL(path: cover);
    var card = MirrorOnceItemSerialize(
      id: id,
      smallCoverImage: cover,
      title: title,
    );
    return card;
  }

  @override
  get isNsfw => false;

  @override
  MovieMetaData get meta => MovieMetaData(
        name: "奈非影视",
        logo: "https://i.loli.net/2021/10/28/iIJYx3uwpVqHBTf.png",
        desc: "永久免费的福利超清影视站，没有套路，完全免费！",
      );

  @override
  Future<List<MirrorOnceItemSerialize>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    var resp = await XHttp.dio.get(
      createURL(path: "/search.php"),
      options: Options(
        headers: header,
      ),
      queryParameters: {
        "searchword": keyword,
        "page": page,
      },
    );
    var $ = html.parse(resp.data);
    var cards = $.getElementById("searchList");
    if (cards == null) throw UnimplementedError();
    var lists = cards.querySelectorAll(".active");
    var movies = lists.map((e) {
      return ele2MirrorSerialize(e);
    }).toList();
    return movies;
  }
}
