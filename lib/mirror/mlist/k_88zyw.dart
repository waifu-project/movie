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

import 'dart:convert';
import 'package:movie/mirror/mlist/base_models/xml_search_data.dart';
import 'package:movie/utils/http.dart';
import 'package:path/path.dart' as path;

import 'package:dio/dio.dart';
import 'package:movie/impl/movie.dart';
import 'package:movie/mirror/mirror_serialize.dart';
import 'package:movie/mirror/mlist/base_models/xml_data.dart';
import 'package:xml2json/xml2json.dart';

/// 该资源不支持 `limit` 参数
class K88zyw extends MovieImpl {
  // <dd flag="88zy">
  //   <![CDATA[https://v2.88zy.site/share/k2m2IGr4C53EFGWK]]>
  // </dd>
  // <dd flag="88zym3u8">
  //   <![CDATA[https://v2.88zy.site/20201102/jqc3ZIZJ/index.m3u8]]>
  // </dd>
  /// 简单获取视频链接类型
  MirrorSerializeVideoType easyGetVideoType(String rawUrl) {
    var ext = path.extension(rawUrl);
    switch (ext) {
      case '.m3u8':
      case '.m3u':
        return MirrorSerializeVideoType.m3u8;
      case '.mp4':
        return MirrorSerializeVideoType.mp4;
      default:
        return MirrorSerializeVideoType.iframe;
    }
  }

  createUrl({suffix = "/inc/api.php"}) {
    return "http://www.88zyw.net" + suffix;
  }

  Options ops = Options(
    responseType: ResponseType.plain,
  );

  @override
  Future<MirrorOnceItemSerialize> getDetail(String movie_id) async {
    var resp = await XHttp.dio.post(
      createUrl(),
      queryParameters: {
        "ac": "videolist",
        "ids": movie_id,
      },
      options: ops,
    );
    var x2j = Xml2Json();
    x2j.parse(resp.data);
    var _json = x2j.toBadgerfish();
    var _ = json.decode(_json);
    KBaseMovieXmlData xml = KBaseMovieXmlData.fromJson(_);
    var video = xml.rss.list.video;
    var cards = video.map(
      (e) {
        var __dd = e.dl.dd;
        List<MirrorSerializeVideoInfo> videos = __dd.map((item) {
          return MirrorSerializeVideoInfo(
            url: item.cData,
            name: item.flag,
            type: easyGetVideoType(item.cData),
          );
        }).toList();
        return MirrorOnceItemSerialize(
          id: e.id,
          smallCoverImage: e.pic,
          title: e.name,
          videos: videos,
          desc: e.des,
        );
      },
    ).toList();
    if (cards.isEmpty) {
      throw UnimplementedError();
    }
    return cards[0];
  }

  @override
  Future<List<MirrorOnceItemSerialize>> getHome({
    int page = 1,
    int limit = 10,
  }) async {
    var resp = await XHttp.dio.get(
      createUrl(),
      queryParameters: {
        "ac": "videolist",
        // "t": limit,
        "pg": page,
      },
      options: ops,
    );
    var x2j = Xml2Json();
    x2j.parse(resp.data);
    var _json = x2j.toBadgerfish();
    var _ = json.decode(_json);
    KBaseMovieXmlData xml = KBaseMovieXmlData.fromJson(_);
    var cards = xml.rss.list.video.map(
      (e) {
        var __dd = e.dl.dd;
        List<MirrorSerializeVideoInfo> videos = __dd.map((item) {
          return MirrorSerializeVideoInfo(
            url: item.cData,
            name: item.flag,
            type: easyGetVideoType(item.cData),
          );
        }).toList();
        return MirrorOnceItemSerialize(
          id: e.id,
          smallCoverImage: e.pic,
          title: e.name,
          videos: videos,
          desc: e.des,
        );
      },
    ).toList();
    return cards;
  }

  @override
  Future<List<MirrorOnceItemSerialize>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    var resp = await XHttp.dio.post(
      createUrl(),
      queryParameters: {
        // "t": limit,
        "pg": page,
        "wd": keyword,
      },
      options: ops,
    );
    var x2j = Xml2Json();
    x2j.parse(resp.data);
    var _json = x2j.toBadgerfish();
    KBaseMovieSearchXmlData searchData = kBaseMovieSearchXmlDataFromJson(_json);
    var defaultCoverImage = meta.logo;
    List<MirrorOnceItemSerialize> result = searchData.rss?.list?.video!
            .map(
              (e) => MirrorOnceItemSerialize(
                id: e.id ?? "",
                smallCoverImage: defaultCoverImage,
                title: e.name?.cdata ?? "",
              ),
            )
            .toList() ??
        [];
    return result;
  }

  @override
  bool get isNsfw => false;

  @override
  MovieMetaData get meta => MovieMetaData(
        name: "88电影资源网",
        logo: "http://www.88zyw.net/images/logo.gif",
        desc: "高清晰，高带宽，专业的电影视频资源采集！",
      );
}
