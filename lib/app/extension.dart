import 'dart:ui';

import 'package:catmovie/isar/schema/category_schema.dart';
import 'package:catmovie/isar/schema/video_history_schema.dart';
import 'package:isar_community/isar.dart';
import 'package:catmovie/isar/repo.dart';
import 'package:catmovie/isar/schema/history_schema.dart';
import 'package:catmovie/isar/schema/mirror_schema.dart';
import 'package:catmovie/isar/schema/parse_schema.dart';
import 'package:catmovie/isar/schema/settings_schema.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:url_launcher/url_launcher_string.dart';

extension StringWithColor on String {
  Color get $color {
    String hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension ISettingMixin on Object {
  IsarCollection<SettingsIsarModel> get settingAs => IsarRepository().settingAs;
  SettingsIsarModel get settingAsValue => IsarRepository().settingsSingleModel;

  IsarCollection<HistoryIsarModel> get historyAs =>
      IsarRepository().isar.historyIsarModels;

  IsarCollection<ParseIsarModel> get parseAs =>
      IsarRepository().isar.parseIsarModels;

  IsarCollection<MirrorIsarModel> get mirrorAs =>
      IsarRepository().isar.mirrorIsarModels;

  IsarCollection<VideoHistoryIsarModel> get videoHistoryAs =>
      IsarRepository().isar.videoHistoryIsarModels;

  IsarCollection<CategoryIsarModel> get categoryAs =>
      IsarRepository().isar.categoryIsarModels;

  Isar get isarInstance => IsarRepository().isar;

  T getSettingAsKeyIdent<T>(SettingsAllKey key, {T? defaultValue}) {
    try {
      return getSettingAsKey(key) as T;
    } catch (e) {
      return defaultValue!;
    }
  }

  Object getSettingAsKey(SettingsAllKey key) {
    var curr = settingAsValue;
    if (key == SettingsAllKey.themeMode) {
      return curr.themeMode;
    } else if (key == SettingsAllKey.isNsfw) {
      return curr.isNSFW;
    } else if (key == SettingsAllKey.mirrorIndex) {
      return curr.mirrorIndex;
    } else if (key == SettingsAllKey.mirrorTextarea) {
      return curr.mirrorTextarea;
    } else if (key == SettingsAllKey.showPlayTips) {
      return curr.showPlayTips;
    } else if (key == SettingsAllKey.webviewPlayType) {
      return curr.webviewPlayType;
    } else if (key == SettingsAllKey.onBoardingShowed) {
      return curr.onBoardingShowed;
    } else if (key == SettingsAllKey.videoKernel) {
      return curr.videoKernel;
    } else if (key == SettingsAllKey.hapticFeedback) {
      return curr.hapticFeedback;
    } else if (key == SettingsAllKey.showNsfwSetting) {
      return curr.showNsfwSetting;
    }
    return curr.id;
  }

  void updateSetting(SettingsAllKey key, dynamic value) {
    var curr = settingAsValue;
    if (key == SettingsAllKey.themeMode) {
      curr.themeMode = value;
    } else if (key == SettingsAllKey.isNsfw) {
      curr.isNSFW = value;
    } else if (key == SettingsAllKey.mirrorIndex) {
      curr.mirrorIndex = value;
    } else if (key == SettingsAllKey.mirrorTextarea) {
      curr.mirrorTextarea = value;
    } else if (key == SettingsAllKey.showPlayTips) {
      curr.showPlayTips = value;
    } else if (key == SettingsAllKey.webviewPlayType) {
      curr.webviewPlayType = value;
    } else if (key == SettingsAllKey.onBoardingShowed) {
      curr.onBoardingShowed = value;
    } else if (key == SettingsAllKey.videoKernel) {
      curr.videoKernel = value;
    } else if (key == SettingsAllKey.hapticFeedback) {
      curr.hapticFeedback = value;
    } else if (key == SettingsAllKey.showNsfwSetting) {
      curr.showNsfwSetting = value;
    } else {
      return;
    }
    IsarRepository().isar.writeTxnSync(() {
      settingAs.putSync(curr);
    });
  }
}

extension Mixxxx on String {
  Future<void> openURL() async {
    await canLaunchUrlString(this)
        ? await launchUrlString(this)
        : throw 'Could not launch $this';
  }

  Future openToIINA() async {
    return 'iina://weblink?url=$this&new_window=1'.openURL();
  }
}
