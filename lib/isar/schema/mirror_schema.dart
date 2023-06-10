import 'package:isar/isar.dart';
import 'package:movie/shared/enum.dart';

part 'mirror_schema.g.dart';

// FIXME: remove this!!!
// The impl is stupid

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
    this.jiexiUrl,
  });

  Id id = Isar.autoIncrement;

  late String name;
  String logo = "";
  String desc = "";

  bool nsfw = false;

  late MirrorApiIsardModel api;

  @Enumerated(EnumType.ordinal)
  MirrorStatus status = MirrorStatus.unknow;

  @Deprecated("remove this")
  String? jiexiUrl;
}
