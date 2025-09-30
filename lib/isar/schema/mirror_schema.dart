import 'package:isar_community/isar.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:xi/xi.dart';

part 'mirror_schema.g.dart';

@embedded
class MirrorExtraJS {
  late String category;
  late String home;
  late String search;
  late String detail;
  late String parseIframe;
}

@embedded
class MirrorExtra {
  String? jiexiUrl;
  bool? gfw;
  int? searchLimit;
  String? template;
  MirrorExtraJS? js;
}

@collection
class MirrorIsarModel {
  MirrorIsarModel({
    required this.api,
    required this.name,
    required this.logo,
    required this.desc,
    required this.nsfw,
    required this.status,
    required this.sid,
    required this.type,
    required this.extra,
  });

  Id id = Isar.autoIncrement;

  @Index()
  late String sid;

  late String name;
  String logo = "";
  String desc = "";

  bool nsfw = false;

  late String api;

  @Enumerated(EnumType.ordinal)
  MirrorStatus status = MirrorStatus.unknow;

  @Enumerated(EnumType.ordinal)
  late SourceType type;

  late MirrorExtra extra;
}
