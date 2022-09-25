// To parse this JSON data, do
//
//     final movieParseModel = movieParseModelFromJson(jsonString);

import 'dart:convert';

List<MovieParseModel> movieParseModelFromJson(String str) =>
    List<MovieParseModel>.from(
        json.decode(str).map((x) => MovieParseModel.fromJson(x)));

String movieParseModelToJson(List<MovieParseModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MovieParseModel {
  MovieParseModel({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;

  factory MovieParseModel.fromJson(Map<String, dynamic> json) =>
      MovieParseModel(
        name: json["name"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "url": url,
      };
}
