// To parse this JSON data, do
//
//     final vodSearchRespData = vodSearchRespDataFromJson(jsonString);

import 'dart:convert';

import 'package:movie/mirror/mlist/fayuqi_models/vod_movie.dart';

VodSearchRespData vodSearchRespDataFromJson(String str) => VodSearchRespData.fromJson(json.decode(str));

String vodSearchRespDataToJson(VodSearchRespData data) => json.encode(data.toJson());

class VodSearchRespData {
    VodSearchRespData({
        required this.total,
        required this.current,
        required this.totalPage,
        required this.data,
    });

    final int total;
    final int current;
    final int totalPage;
    final List<VodCard> data;

    factory VodSearchRespData.fromJson(Map<String, dynamic> json) => VodSearchRespData(
        total: json["total"],
        current: json["current"],
        totalPage: json["total_page"],
        data: List<VodCard>.from(
            json["data"].map((x) => VodCard.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "current": current,
        "total_page": totalPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}
