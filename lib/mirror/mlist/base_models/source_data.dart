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

// To parse this JSON data, do
//
//     final sourceJsonData = sourceJsonDataFromJson(jsonString);

import 'dart:convert';

List<SourceJsonData> sourceJsonDataFromJson(String str) =>
    List<SourceJsonData>.from(
      json.decode(str).map(
            (x) => SourceJsonData.fromJson(x),
          ),
    );

String sourceJsonDataToJson(List<SourceJsonData> data) => json.encode(
      List<dynamic>.from(
        data.map((x) => x.toJson(),),
      ),
    );

class SourceJsonData {
  SourceJsonData({
    this.name,
    this.logo,
    this.desc,
    this.nsfw,
    this.api,
  });

  final String? name;
  final String? logo;
  final String? desc;
  final bool? nsfw;
  final Api? api;

  factory SourceJsonData.fromJson(Map<String, dynamic> json) => SourceJsonData(
        name: json["name"],
        logo: json["logo"],
        desc: json["desc"],
        nsfw: json["nsfw"],
        api: Api.fromJson(json["api"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "logo": logo,
        "desc": desc,
        "nsfw": nsfw,
        "api": api?.toJson(),
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
