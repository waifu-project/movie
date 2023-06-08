import 'package:isar/isar.dart';
import 'package:movie/shared/enum.dart';

part 'settings_schema.g.dart';

@collection
class SettingsIsarModel {

  Id id = Isar.autoIncrement;

  @Enumerated(EnumType.ordinal)
  late SystemThemeMode themeMode;
}
