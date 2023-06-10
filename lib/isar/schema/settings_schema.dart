import 'package:isar/isar.dart';
import 'package:movie/shared/enum.dart';

part 'settings_schema.g.dart';

@Collection(inheritance: false)
class SettingsIsarModel {
  Id id = Isar.autoIncrement;

  /// 主题
  @Enumerated(EnumType.ordinal)
  SystemThemeMode themeMode = SystemThemeMode.system;

  /// `ios` 播放视频是否使用默认的系统浏览器
  /// 1. 浏览器默认支持: `m3u8` | `mp4`
  /// 2. 网页可以直接跳转给浏览器用
  /// (所以`ios`默认直接走浏览器岂不美哉?)
  bool iosCanBeUseSystemBrowser = true;

  /// macos播放使用 [iina](https://iina.io)
  bool macosPlayUseIINA = false;

  bool isNSFW = false;

  /// 当前源
  @Deprecated("use mirror id, remove this")
  int mirrorIndex = 0;

  String mirrorTextarea = "";

  /// 显示播放前的提示(告知用户不要相信广告!)
  bool showPlayTips = true;
}
