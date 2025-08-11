import 'package:catmovie/isar/schema/video_search_schema.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:catmovie/isar/schema/history_schema.dart';
import 'package:catmovie/isar/schema/mirror_schema.dart';
import 'package:catmovie/isar/schema/parse_schema.dart';
import 'package:catmovie/isar/schema/settings_schema.dart';
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

  void safeWrite(VoidCallback fn) {
    isar.writeTxnSync(() async => fn());
  }

  void safeRead(VoidCallback fn) {
    isar.txn(() async => fn);
  }

  List<CollectionSchema<dynamic>> get schemas => [
        SettingsIsarModelSchema,
        HistoryIsarModelSchema,
        ParseIsarModelSchema,
        MirrorIsarModelSchema,
        VideoHistoryIsarModelSchema,
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
  void fake(Isar isar) {
    isar.writeTxnSync(() {
      isar.settingsIsarModels.clearSync();
    });
  }

  void _initDB(Isar isar) {
    // _fake(isar);
    if (isar.settingsIsarModels.countSync() <= 0) {
      debugPrint("[logger] 初始化设置");
      var defaultSetting = SettingsIsarModel();
      if (defaultSetting.mirrorTextarea.isEmpty) {
        defaultSetting.mirrorTextarea =
            "https://cdn.jsdelivr.net/gh/waifu-project/v1@latest/yoyo.json";
      }
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
