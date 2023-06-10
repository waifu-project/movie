// ignore_for_file: constant_identifier_names

// FIXME: remove [ConstDart]

const String APP_TITLE = "yoyo";

/// 映射常量表
class ConstDart {
  /// 镜像索引
  static const String ls_mirrorIndex = "mirrorIndex";

  /// nsfw
  static const String is_nsfw = "isNsfw";

  /// 是否为暗色模式
  static const String ls_isDark = "isDark";

  /// 自动系统主题(暗色/浅色)
  static const String auto_dark = "autoDark";

  /// 搜索历史记录
  static const String search_history = "searchHistory";

  /// 镜像列表
  static const String mirror_list = "mirrorList";

  /// 视频源输入框
  static const String mirror_textArea = "mirror_textarea";

  /// 显示播放提示
  /// **免责提示**
  static const String showPlayTips = "showPlayTips";

  /// iOS使用浏览器播放
  static const String iosVideoSystemBrowser = "iosVideoSystemBrowser";

  /// macOS是否使用iina播放
  static const String macosPlayUseIINA = "macosPlayUseIINA";

  static const String movieParseVip = "movieParseVip";

  /// 是否为开发模式
  /// TODDO
  static bool get isDev {
    return false;
  }
}

const GITHUB_OPEN = "https://github.com/waifu-project/movie";
