import 'package:isar/isar.dart';

part 'history_schema.g.dart';

@Collection()
class HistoryIsarModel {
  Id id = Isar.autoIncrement;

  late String content;

  HistoryIsarModel(this.content);
}
