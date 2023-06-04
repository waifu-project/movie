// To parse this JSON data, do
//
//     final sourceJsonData = sourceJsonDataFromJson(jsonString);

import 'dart:convert';

import 'package:movie/utils/xid.dart';

List<SourceJsonData> sourceJsonDataFromJson(String str) =>
    List<SourceJsonData>.from(
      json.decode(str).map(
            (x) => SourceJsonData.fromJson(x),
          ),
    );

String sourceJsonDataToJson(List<SourceJsonData> data) => json.encode(
      List<dynamic>.from(
        data.map(
          (x) => x.toJson(),
        ),
      ),
    );

class SourceJsonData {
  SourceJsonData({
    this.name,
    this.logo,
    this.desc,
    this.nsfw,
    this.api,
    this.id,
    this.status,
    this.jiexiUrl,
  });

  final String? name;
  final String? logo;
  final String? desc;
  final bool? nsfw;
  final Api? api;
  final String? id;
  final bool? status;
  final String? jiexiUrl;

  /// [SourceUtils.tryParseData]
  @Deprecated('不推荐使用, 推荐使用 SourceUtils.tryParseData()')
  factory SourceJsonData.fromJson(Map<String, dynamic> json) {
    var name = json['name'];
    var logo = json['logo'];
    var desc = json['desc'];

    /// FIXME: 兼容 `ZY-Player`
    var status = json['status'] ?? true;

    var oldID = json['id'];
    var id = oldID ?? "";
    if (id.isEmpty) {
      var insID = Xid();
      id = insID.toString();
    }
    late Api api;
    late bool nsfw;

    /// note:
    ///   => 兼容 `ZY-Player` 的源
    ///   => 通过判断其是否有 `id`

    bool? _nsfw = json['nsfw'];

    var _api = json['api'];

    if (_api is Map<String, dynamic>) {
      api = Api.fromJson(_api);
    } else if (_api is String) {
      var url = Uri.tryParse(_api);
      if (url != null) {
        api = Api(
          path: url.path,
          root: url.origin,
        );
      }
    }

    if (_nsfw == null) {
      bool flag = json['group'] ?? "" == "18禁";
      nsfw = flag;
    } else {
      nsfw = _nsfw;
    }

    var jiexiUrl = json['jiexiUrl'] ?? "";

    return SourceJsonData(
      name: name,
      logo: logo,
      desc: desc,
      nsfw: nsfw,
      api: api,
      status: status,
      id: id,
      jiexiUrl: jiexiUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "logo": logo,
        "desc": desc,
        "nsfw": nsfw,
        "api": api?.toJson(),
        'id': id,
        'status': status,
        'jiexiUrl': jiexiUrl,
      };
}

class Api {
  Api({
    this.root,
    this.path,
  });

  final String? root;
  final String? path;

  factory Api.fromJson(Map<String, dynamic> json) => Api(
        root: json["root"],
        path: json["path"],
      );

  Map<String, dynamic> toJson() => {
        "root": root,
        "path": path,
      };
}
