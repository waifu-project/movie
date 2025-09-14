import 'dart:convert';

import 'package:isar_community/isar.dart';

part 'parse_schema.g.dart';

@Collection()
class ParseIsarModel {
  Id id = Isar.autoIncrement;

  late String name;
  late String url;

  ParseIsarModel(this.name, this.url);

  factory ParseIsarModel.fromJson(Map<String, dynamic> json) {
    return ParseIsarModel(json['name'] ?? "", json['url'] ?? "");
  }
}

dynamic movieParseModelFromJson(String json) {
  var map = jsonDecode(json);
  var name = map['name'] ?? "";
  var url = map['url'] ?? "";
  return ParseIsarModel(name, url);
}
