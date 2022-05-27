// To parse this JSON data, do
//
//     final movieVodPlayCodeData = movieVodPlayCodeDataFromJson(jsonString);

import 'dart:convert';

///
/// ```json
///
/// {
///     "vodTypes": [
///         {
///             "id": 12,
///             "title": "你好世界"
///         }
///     ],
///     "homeCards": [
///         {
///             "vodCards":[
///                 {
///                     "id": "23fsdf",
///                     "cover": "https://baidu.com/1.jpg",
///                     "title": "sdf"
///                 }
///             ]
///         }
///     ],
///     "artDatas": [
///         {
///             "id": "sdf",
///             "title": "fsd"
///         }]
/// }
///
///
/// ```
///
///
MovieVodPlayCodeData movieVodPlayCodeDataFromJson(String str) =>
    MovieVodPlayCodeData.fromJson(json.decode(str));
    
String movieVodPlayCodeDataToJson(MovieVodPlayCodeData data) =>
    json.encode(data.toJson());

class MovieVodPlayCodeData {
  MovieVodPlayCodeData({
    required this.vodTypes,
    required this.homeCards,
    required this.artDatas,
  });

  final List<VodType> vodTypes;
  final List<HomeCard> homeCards;
  final List<ArtData> artDatas;

  factory MovieVodPlayCodeData.fromJson(Map<String, dynamic> json) =>
      MovieVodPlayCodeData(
        vodTypes: List<VodType>.from(
            json["vodTypes"].map((x) => VodType.fromJson(x))),
        homeCards: List<HomeCard>.from(
            json["homeCards"].map((x) => HomeCard.fromJson(x))),
        artDatas: List<ArtData>.from(
            json["artDatas"].map((x) => ArtData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "vodTypes": List<dynamic>.from(vodTypes.map((x) => x.toJson())),
        "homeCards": List<dynamic>.from(homeCards.map((x) => x.toJson())),
        "artDatas": List<dynamic>.from(artDatas.map((x) => x.toJson())),
      };
}

class ArtData {
  ArtData({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory ArtData.fromJson(Map<String, dynamic> json) => ArtData(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
      };
}

class HomeCard {
  HomeCard({
    required this.vodCards,
  });

  final List<VodCard> vodCards;

  factory HomeCard.fromJson(Map<String, dynamic> json) => HomeCard(
        vodCards: List<VodCard>.from(
            json["vodCards"].map((x) => VodCard.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "vodCards": List<dynamic>.from(vodCards.map((x) => x.toJson())),
      };
}

class VodCard {
  VodCard({
    required this.id,
    required this.cover,
    required this.title,
  });

  final String id;
  final String cover;
  final String title;

  factory VodCard.fromJson(Map<String, dynamic> json) => VodCard(
        id: json["id"],
        cover: json["cover"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cover": cover,
        "title": title,
      };
}

class VodType {
  VodType({
    required this.id,
    required this.title,
  });

  final int id;
  final String title;

  factory VodType.fromJson(Map<String, dynamic> json) => VodType(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
      };
}
