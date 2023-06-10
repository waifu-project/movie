import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:movie/isar/schema/history_schema.dart';
import 'package:movie/isar/schema/mirror_schema.dart';
import 'package:movie/isar/schema/parse_schema.dart';
import 'package:movie/isar/schema/settings_schema.dart';
import 'package:path_provider/path_provider.dart';

// isar auto generated *.g.dart do you want add .gitignore?
// link: https://www.reddit.com/r/FlutterDev/comments/kazxo0/do_you_add_gdart_files_to_gitignore
// I don't like these makefiles (ーー゛)
// the code copy by ChatGPT

class IsarRepository {
  late Isar _isar;

  static final IsarRepository _instance = IsarRepository._internal();

  factory IsarRepository() {
    return _instance;
  }

  IsarRepository._internal() {
    init();
  }

  safeWrite(VoidCallback fn) {
    isar.writeTxnSync(() async => fn());
  }

  safeRead(VoidCallback fn) {
    isar.txn(() async => fn);
  }

  List<CollectionSchema<dynamic>> get schemas => [
        SettingsIsarModelSchema,
        HistoryIsarModelSchema,
        ParseIsarModelSchema,
        MirrorIsarModelSchema,
      ];

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      schemas,
      directory: dir.path,
      maxSizeMiB: 512,
    );
    _initDB(_isar);
  }

  @Deprecated("调试模式, 后续请删除")
  _fake(Isar isar) {
    isar.writeTxnSync(() {
      isar.settingsIsarModels.clearSync();
    });
  }

  _initDB(Isar isar) {
    // _fake(isar);
    if (isar.settingsIsarModels.countSync() <= 0) {
      debugPrint("[logger] 初始化设置");
      var defaultSetting = SettingsIsarModel();
      isar.writeTxnSync(() {
        isar.settingsIsarModels.putSync(defaultSetting);
      });
    }
  }

  Isar get isar => _isar;
}

extension IsarRepositoryModelHelp on IsarRepository {
  IsarCollection<SettingsIsarModel> get settingAs => _isar.settingsIsarModels;

  /// use the instance need init!!!
  /// maybe get fail(nill)
  SettingsIsarModel get settingsSingleModel => settingAs.getSync(1)!;
}
