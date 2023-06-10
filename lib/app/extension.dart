import 'package:isar/isar.dart';
import 'package:movie/isar/repo.dart';
import 'package:movie/isar/schema/history_schema.dart';
import 'package:movie/isar/schema/settings_schema.dart';
import 'package:movie/shared/enum.dart';

/// remove this(mixin object 杀伤力太大)
extension ISettingMixin on Object {
  IsarCollection<SettingsIsarModel> get settingAs => IsarRepository().settingAs;
  SettingsIsarModel get settingAsValue => IsarRepository().settingsSingleModel;

  IsarCollection<HistoryIsarModel> get historyAs => IsarRepository().isar.historyIsarModels;

  Isar get isarInstance => IsarRepository().isar;

  T getSettingAsKeyIdent<T>(SettingsAllKey key) {
    return getSettingAsKey(key) as T;
  }

  /// the code is shit|_・)
  ///
  /// disgustingε(┬┬﹏┬┬)3
  ///
  /// (っ ̯ -｡)
  getSettingAsKey(SettingsAllKey key) {
    var curr = settingAsValue;
    if (key == SettingsAllKey.themeMode) {
      return curr.themeMode;
    } else if (key == SettingsAllKey.iosCanBeUseSystemBrowser) {
      return curr.iosCanBeUseSystemBrowser;
    } else if (key == SettingsAllKey.macosPlayUseIINA) {
      return curr.macosPlayUseIINA;
    } else if (key == SettingsAllKey.isNsfw) {
      return curr.isNSFW;
    } else if (key == SettingsAllKey.mirrorIndex) {
      return curr.mirrorIndex;
    } else if (key == SettingsAllKey.mirrorTextarea) {
      return curr.mirrorTextarea;
    } else if (key == SettingsAllKey.showPlayTips) {
      return curr.showPlayTips;
    }
    return curr.id;
  }

  /// the code is shit|_・)
  ///
  /// disgustingε(┬┬﹏┬┬)3
  ///
  /// (っ ̯ -｡)
  updateSetting(SettingsAllKey key, dynamic value) {
    var curr = settingAsValue;
    if (key == SettingsAllKey.themeMode) {
      curr.themeMode = value;
    } else if (key == SettingsAllKey.iosCanBeUseSystemBrowser) {
      curr.iosCanBeUseSystemBrowser = value;
    } else if (key == SettingsAllKey.macosPlayUseIINA) {
      curr.macosPlayUseIINA = value;
    } else if (key == SettingsAllKey.isNsfw) {
      curr.isNSFW = value;
    } else if (key == SettingsAllKey.mirrorIndex) {
      curr.mirrorIndex = value;
    } else if (key == SettingsAllKey.mirrorTextarea) {
      curr.mirrorTextarea = value;
    } else if (key == SettingsAllKey.showPlayTips) {
      curr.showPlayTips = value;
    } else {
      return;
    }
    IsarRepository().isar.writeTxnSync(() {
      settingAs.putSync(curr);
    });
  }
}