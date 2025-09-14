import 'package:isar_community/isar.dart';
import 'package:catmovie/shared/enum.dart';

part 'mirror_schema.g.dart';

@embedded
class MirrorApiIsardModel {
  late String root;
  late String path;
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
    this.jiexiUrl,
  });

  Id id = Isar.autoIncrement;

  @Index()
  late String sid;

  late String name;
  String logo = "";
  String desc = "";

  bool nsfw = false;

  late MirrorApiIsardModel api;

  @Enumerated(EnumType.ordinal)
  MirrorStatus status = MirrorStatus.unknow;

  String? jiexiUrl;
}
