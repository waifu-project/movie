import 'package:isar_community/isar.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:webplayer_embedded/webplayer_embedded.dart';

part 'settings_schema.g.dart';

@Collection(inheritance: false)
class SettingsIsarModel {
  Id id = Isar.autoIncrement;

  /// 主题
  @Enumerated(EnumType.ordinal)
  SystemThemeMode themeMode = SystemThemeMode.system;

  /// 播放器内核
  @Enumerated(EnumType.ordinal)
  VideoKernel videoKernel = VideoKernel.mediaKit;

  /// 是否开启成人模式
  bool isNSFW = false;

  /// 当前源
  int mirrorIndex = 0;

  String mirrorTextarea = "";

  /// 显示播放前的提示(告知用户不要相信广告!)
  bool showPlayTips = true;

  /// 启动时是否显示引导页面
  bool onBoardingShowed = false;

  /// 震动反馈
  bool hapticFeedback = true;

  /// 是否显示绅士模式设置（通过点击 Copyright 10次解锁）
  bool showNsfwSetting = false;

  @Enumerated(EnumType.ordinal)
  IWebPlayerEmbeddedType webviewPlayType = IWebPlayerEmbeddedType.p2pHLS;
}
