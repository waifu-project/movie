import 'package:isar/isar.dart';

part 'parse_schema.g.dart';

@Collection()
class ParseIsarModel {
  Id id = Isar.autoIncrement;

  late String name;
  late String url;

  ParseIsarModel(this.name, this.url);
}
