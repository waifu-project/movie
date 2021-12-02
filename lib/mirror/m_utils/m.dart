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

// https://github.com/cuiocean/ZY-Player-APP/blob/main/utils/request.js

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:movie/impl/movie.dart';
import 'package:movie/mirror/mirror_serialize.dart';
import 'package:movie/mirror/mlist/base_models/xml_data.dart';
import 'package:movie/mirror/mlist/base_models/xml_search_data.dart';
import 'package:movie/utils/helper.dart';
import 'package:movie/utils/http.dart';
import 'package:xml2json/xml2json.dart';
import 'package:path/path.dart' as path;

class KBaseMirrorMovie extends MovieImpl {
  final bool nsfw;
  final String name;
  final String logo;
  final String desc;
  final String root_url;
  final String api_path;
  KBaseMirrorMovie({
    this.nsfw = false,
    this.name = "",
    this.logo = "",
    this.desc = "",
    required this.root_url,
    required this.api_path,
  });

  createUrl({
    required String suffix,
  }) {
    return root_url + suffix;
  }

  Options ops = Options(
    responseType: ResponseType.plain,
  );

  /// 简单获取视频链接类型
  static MirrorSerializeVideoType easyGetVideoType(String rawUrl) {
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

  @override
  Future<MirrorOnceItemSerialize> getDetail(String movie_id) async {
    var resp = await XHttp.dio.post(
      createUrl(suffix: api_path),
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
            url: easyGetVideoURL(item.cData),
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
      createUrl(suffix: api_path),
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
            url: easyGetVideoURL(item.cData),
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
      createUrl(suffix: api_path),
      queryParameters: {
        "ac": "videolist",
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
  bool get isNsfw => nsfw;

  @override
  MovieMetaData get meta => MovieMetaData(
        name: name,
        logo: logo,
        desc: desc,
        domain: root_url,
      );

  @override
  String toString() {
    var output = "\n";
    output += "name: $name\n";
    output += " url: $root_url$api_path";
    return output;
  }
}
