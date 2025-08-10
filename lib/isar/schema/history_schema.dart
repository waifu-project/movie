import 'package:isar/isar.dart';

part 'history_schema.g.dart';

@Collection()
class HistoryIsarModel {
  Id id = Isar.autoIncrement;

  @Index()
  late bool isNsfw;
  late String content;

  HistoryIsarModel(this.isNsfw, this.content);
}
