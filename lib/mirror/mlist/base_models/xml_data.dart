import 'package:movie/impl/movie.dart';

class KBaseMovieXmlData {
  KBaseMovieXmlData({
    required this.rss,
  });
  late final Rss rss;

  KBaseMovieXmlData.fromJson(Map<String, dynamic> json) {
    rss = Rss.fromJson(json['rss']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['rss'] = rss.toJson();
    return _data;
  }
}

class Rss {
  Rss({
    required this.list,
    required this.version,
    required this.category,
  });
  late final ListX list;
  late final String version;
  late final List<MovieQueryCategory> category;

  Rss.fromJson(Map<String, dynamic> json) {
    list = ListX.fromJson(json['list']);
    version = json['@version'];
    Map<String, dynamic> _category = json['class'] ?? {};
    dynamic ty = _category['ty'];
    List<dynamic> data = [];
    if (ty is List) {
      data = ty;
    } else if (ty is Map) {
      data.add(ty);
    }
    List<MovieQueryCategory> _categorys = data.map((e) {
      var map = Map<String, String>.from(e);
      var name = map['\$'] ?? "";
      var id = map['@id'] ?? "";
      return MovieQueryCategory(name, id);
    }).toList();
    category = _categorys;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['list'] = list.toJson();
    _data['_version'] = version;
    _data['category'] = category;
    return _data;
  }
}

class ListX {
  ListX({
    required this.video,
    required this.page,
    required this.pagecount,
    required this.pagesize,
    required this.recordcount,
  });
  late final List<Video> video;
  late final String page;
  late final String pagecount;
  late final String pagesize;
  late final String recordcount;

  ListX.fromJson(Map<String, dynamic> json) {
    var v = json['video'];
    List<Video> rv = [];
    if (v == null) {
      // ignore the line
    } else if (v is Map) {
      rv = [Video.fromJson(v.cast())];
    } else {
      rv = List.from(v).map((e) {
        return Video.fromJson(e);
      }).toList();
    }
    video = rv;
    page = json['@page'];
    pagecount = json['@pagecount'];
    pagesize = json['@pagesize'];
    recordcount = json['@recordcount'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['video'] = video.map((e) => e.toJson()).toList();
    _data['_page'] = page;
    _data['_pagecount'] = pagecount;
    _data['_pagesize'] = pagesize;
    _data['_recordcount'] = recordcount;
    return _data;
  }
}

class Video {
  Video({
    required this.last,
    required this.id,
    required this.tid,
    required this.name,
    required this.type,
    required this.pic,
    required this.lang,
    required this.area,
    required this.year,
    required this.state,
    required this.note,
    required this.actor,
    required this.director,
    required this.dl,
    required this.des,
  });
  late final String last;
  late final String id;
  late final String tid;
  late final String name;
  late final String type;
  late final String pic;
  late final String lang;
  late final String area;
  late final String year;
  late final String state;
  late final String note;
  late final String actor;
  late final String director;
  late final Dl dl;
  late final String des;

  /// NOTE:
  ///   => 该库默认行为会生成一个Map,
  dynamic autoFix2String(dynamic raw, String rawKey) {
    if (raw is Map) {
      var _m = raw[rawKey];
      if (_m == null) return null;
      var r = _m['\$'];
      if (r == null) {
        var __r = raw[rawKey]['__cdata'];
        if (__r == null) return "";
        return __r;
      }
      return r;
    }
    return raw[rawKey];
  }

  Video.fromJson(Map<String, dynamic> json) {
    last = autoFix2String(json, 'last') ?? "";
    id = autoFix2String(json, 'id') ?? "";
    tid = autoFix2String(json, 'tid') ?? "";
    name = autoFix2String(json, 'name') ?? "";
    type = autoFix2String(json, 'type') ?? "";
    pic = autoFix2String(json, 'pic') ?? "";
    lang = autoFix2String(json, 'lang') ?? "";
    area = autoFix2String(json, 'area') ?? "";
    year = autoFix2String(json, 'year') ?? "";
    state = autoFix2String(json, 'state') ?? "";
    note = autoFix2String(json, 'note') ?? "";
    actor = autoFix2String(json, 'actor') ?? "";
    director = autoFix2String(json, 'director') ?? "";
    dl = Dl.fromJson(json['dl'] ?? {});
    des = autoFix2String(json, 'des') ?? "";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['last'] = last;
    _data['id'] = id;
    _data['tid'] = tid;
    _data['name'] = name;
    _data['type'] = type;
    _data['pic'] = pic;
    _data['lang'] = lang;
    _data['area'] = area;
    _data['year'] = year;
    _data['state'] = state;
    _data['note'] = note;
    _data['actor'] = actor;
    _data['director'] = director;
    _data['dl'] = dl.toJson();
    _data['des'] = des;
    return _data;
  }
}

class Dl {
  Dl({
    required this.dd,
  });
  late final List<Dd> dd;

  Dl.fromJson(Map<String, dynamic> json) {
    var __dd = json['dd'] ?? {};
    if (__dd is Map) {
      dd = [Dd.fromJson(__dd.cast())];
    } else {
      dd = List.from(json['dd']).map((e) => Dd.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['dd'] = dd.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Dd {
  Dd({
    required this.flag,
    required this.cData,
  });
  late final String flag;
  late final String cData;

  Dd.fromJson(Map<String, dynamic> json) {
    flag = json['@flag'] ?? "";
    cData = json['__cdata'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['_flag'] = flag;
    _data['__cdata'] = cData;
    return _data;
  }
}
