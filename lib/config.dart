const String APP_TITLE = "yoyo";

/// 映射常量表
class ConstDart {
  /// 镜像索引
  static final String ls_mirrorIndex = "mirrorIndex";

  /// nsfw
  static final String is_nsfw = "isNsfw";

  /// 是否为暗色模式
  static final String ls_isDark = "isDark";

  /// 自动系统主题(暗色/浅色)
  static final String auto_dark = "autoDark";

  /// 搜索历史记录
  static final String search_history = "searchHistory";

  /// 镜像列表
  static final String mirror_list = "mirrorList";

  /// 视频源输入框
  static final String mirror_textArea = "mirror_textarea";

  /// 显示播放提示
  /// **免责提示**
  static final String showPlayTips = "showPlayTips";

  /// iOS使用浏览器播放
  static final String iosVideoSystemBrowser = "iosVideoSystemBrowser";

  /// macOS是否使用iina播放
  static final String macosPlayUseIINA = "macosPlayUseIINA";

  static final String movieParseVip = "movieParseVip";

  /// 是否为开发模式
  /// TODDO
  static bool get isDev {
    return false;
  }
}

const GITHUB_OPEN = "https://github.com/waifu-project/movie";
