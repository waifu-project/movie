// To parse this JSON data, do
//
//     final kBaseMovieSearchXmlData = kBaseMovieSearchXmlDataFromJson(jsonString);

import 'dart:convert';

KBaseMovieSearchXmlData kBaseMovieSearchXmlDataFromJson(String str) =>
    KBaseMovieSearchXmlData.fromJson(json.decode(str));

String kBaseMovieSearchXmlDataToJson(KBaseMovieSearchXmlData data) =>
    json.encode(data.toJson());

class KBaseMovieSearchXmlData {
  KBaseMovieSearchXmlData({
    this.rss,
  });

  Rss? rss;

  factory KBaseMovieSearchXmlData.fromJson(Map<String, dynamic> json) =>
      KBaseMovieSearchXmlData(
        rss: Rss.fromJson(json["rss"]),
      );

  Map<String, dynamic> toJson() => {
        "rss": rss?.toJson(),
      };
}

class Rss {
  Rss({
    this.list,
    this.rssClass,
    this.version,
  });

  ListClass? list;
  Class? rssClass;
  String? version;

  factory Rss.fromJson(Map<String, dynamic> json) {
    var _class = json['class'];
    return Rss(
      list: ListClass.fromJson(json["list"]),
      rssClass: Class.fromJson(_class ?? {
        "ty": [],
      }),
      version: json["_version"],
    );
  }

  Map<String, dynamic> toJson() => {
        "list": list?.toJson(),
        "class": rssClass?.toJson(),
        "_version": version,
      };
}

class ListClass {
  ListClass({
    this.video,
    this.page,
    this.pagecount,
    this.pagesize,
    this.recordcount,
  });

  List<Video>? video;
  String? page;
  String? pagecount;
  String? pagesize;
  String? recordcount;

  factory ListClass.fromJson(Map<String, dynamic> json) {
    var video = json["video"];
    List<Video> data = [];
    if (video is Map) {
      data.add(Video.fromJson(video.cast()));
    } else {
      if (video != null && video is List) {
        var cacheVideo = List<Video>.from(video.map((x) => Video.fromJson(x)));
        data.addAll(cacheVideo);
      }
    }
    return ListClass(
      video: data,
      page: json["_page"],
      pagecount: json["_pagecount"],
      pagesize: json["_pagesize"],
      recordcount: json["_recordcount"],
    );
  }

  Map<String, dynamic> toJson() => {
        "video": List<dynamic>.from(video!.map((x) => x.toJson())),
        "_page": page,
        "_pagecount": pagecount,
        "_pagesize": pagesize,
        "_recordcount": recordcount,
      };
}

/// NOTE:
///   => 该库默认行为会生成一个Map,
dynamic autoFix2String(dynamic raw, String rawKey) {
  try {
    if (raw == null) return "";
    if (raw is Map) {
      var r = raw[rawKey]['\$'];
      if (r == null) {
        var __r = raw[rawKey]['__cdata'];
        if (__r == null) return "";
        return __r;
      }
      return r;
    }
    return raw[rawKey];
  } catch (e) {
    return "";
  }
}

class Video {
  Video({
    this.last,
    this.id,
    this.tid,
    this.name,
    this.type,
    this.dt,
    this.note,
  });

  DateTime? last;
  String? id;
  String? tid;
  Name? name;
  String? type;
  String? dt;
  Name? note;

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        last: DateTime.parse(autoFix2String(json, "last")),
        id: autoFix2String(json, 'id'),
        tid: autoFix2String(json, 'tid'),
        name: Name.fromJson(json["name"]),
        type: autoFix2String(json, 'type'),
        dt: autoFix2String(json, 'dt'),
        note: Name.fromJson(json["note"]),
      );

  Map<String, dynamic> toJson() => {
        "last": last!.toIso8601String(),
        "id": id,
        "tid": tid,
        "name": name!.toJson(),
        "type": type,
        "dt": dt,
        "note": note!.toJson(),
      };
}

class Name {
  Name({
    this.cdata,
  });

  String? cdata;

  factory Name.fromJson(Map<String, dynamic> json) => Name(
        cdata: json["__cdata"],
      );

  Map<String, dynamic> toJson() => {
        "__cdata": cdata,
      };
}

class Class {
  Class({
    this.ty,
  });

  List<Ty>? ty;

  factory Class.fromJson(Map<String, dynamic> json) => Class(
        ty: List<Ty>.from(json["ty"].map((x) => Ty.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ty": List<dynamic>.from(ty!.map((x) => x.toJson())),
      };
}

class Ty {
  Ty({
    this.id,
    this.text,
  });

  String? id;
  String? text;

  factory Ty.fromJson(Map<String, dynamic> json) {
    var id = json["_id"];
    if (id == null) {
      id = json["@id"];
    }
    var text = json["__text"];
    if (text == null) {
      text = json["\$"];
    }
    return Ty(
      id: id,
      text: text,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "__text": text,
      };
}
