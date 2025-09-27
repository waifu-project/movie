/// 主题(颜色)模式
enum SystemThemeMode {
  /// 系统自动
  system,

  /// 亮色
  light,

  /// 暗色
  dark,
}

enum VideoKernel {
  webview,
  mediaKit,
  /// macos 专属
  iina,
}

extension  VideoKernelExtension on VideoKernel {
  bool get isWebview => this == VideoKernel.webview;
  bool get isMediaKit => this == VideoKernel.mediaKit;
  bool get isIina => this == VideoKernel.iina;

  String get name {
    switch (this) {
      case VideoKernel.webview:
        return "Webview";
      case VideoKernel.mediaKit:
        return "MediaKit";
      case VideoKernel.iina:
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
  videoKernel,
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
  /// 震动反馈
  hapticFeedback,
  /// 是否显示绅士模式设置
  showNsfwSetting,
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
