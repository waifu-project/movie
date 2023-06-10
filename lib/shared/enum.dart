/// 主题(颜色)模式
enum SystemThemeMode {
  /// 系统自动
  system,

  /// 亮色
  light,

  /// 暗色
  dark,
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
  themeMode,
  iosCanBeUseSystemBrowser,
  macosPlayUseIINA,
  isNsfw,
  mirrorIndex,
  mirrorTextarea,
  showPlayTips
}