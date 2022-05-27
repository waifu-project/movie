// To parse this JSON data, do
//
//     final artDetailData = artDetailDataFromJson(jsonString);

import 'dart:convert';

ArtDetailData artDetailDataFromJson(String str) =>
    ArtDetailData.fromJson(json.decode(str));

String artDetailDataToJson(ArtDetailData data) => json.encode(data.toJson());

class ArtDetailData {
  ArtDetailData({
    required this.title,
    required this.id,
    required this.images,
    required this.desc,
  });

  final String title;
  final String id;
  final List<String> images;
  final String desc;

  factory ArtDetailData.fromJson(Map<String, dynamic> json) => ArtDetailData(
        title: json["title"],
        id: json["id"],
        images: List<String>.from(json["images"].map((x) => x)),
        desc: json["desc"],
      );

  factory ArtDetailData.fromArgs(String id, String title) => ArtDetailData(
        desc: '',
        id: id,
        images: [],
        title: title,
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "id": id,
        "images": List<dynamic>.from(images.map((x) => x)),
        "desc": desc,
      };
}
