/// 主题(颜色)模式
enum SystemThemeMode {
  /// 系统自动
  system,

  /// 亮色
  light,

  /// 暗色
  dark,
}

enum VideoKennel {
  webview,
  mediaKit,
  /// macos 专属
  iina,
}

extension  VideoKennelExtension on VideoKennel {
  bool get isWebview => this == VideoKennel.webview;
  bool get isMediaKit => this == VideoKennel.mediaKit;
  bool get isIina => this == VideoKennel.iina;

  String get name {
    switch (this) {
      case VideoKennel.webview:
        return "Webview";
      case VideoKennel.mediaKit:
        return "MediaKit";
      case VideoKennel.iina:
        return "IINA";
    }
  }
}

extension SystemThemeModeExtension on SystemThemeMode {
  bool get isSytem => this == SystemThemeMode.system;
  bool get isLight => this == SystemThemeMode.light;
  bool get isDark => this == SystemThemeMode.dark;

  String get name {
    switch (this) {
      case SystemThemeMode.system:
        return "系统自动";
      case SystemThemeMode.light:
        return "亮色";
      case SystemThemeMode.dark:
        return "暗色";
    }
  }
}

enum SettingsAllKey {
  /// 主题
  themeMode,
  /// 播放器内核
  videoKennel,
  /// 是否开启成人模式
  isNsfw,
  /// 当前源(索引)
  mirrorIndex,
  /// 源链接(textarea)
  mirrorTextarea,
  /// 是否已经提示过免责声明
  showPlayTips,
  /// webview 启动的服务类型
  webviewPlayType,
  /// 首次启动
  onBoardingShowed,
}

/// 镜像源状态
enum MirrorStatus {
  /// 可用
  available,

  /// 不可用
  unavailable,

  /// 未知领域
  unknow
}
