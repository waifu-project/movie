import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'mac.dart';

double kMacPaddingTop = 16;

class MoveWindow extends StatelessWidget {
  const MoveWindow({super.key, this.child});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        if (GetPlatform.isDesktop) {
          appWindow.startDragging();
        }
      },
      onDoubleTap: () {
        if (GetPlatform.isDesktop) {
          appWindow.maximizeOrRestore();
        }
      },
      child: child ?? Container(),
    );
  }
}

class CustomMoveWindow extends StatelessWidget {
  final Widget? child;
  const CustomMoveWindow({
    super.key,
    this.child,
  });
  @override
  Widget build(BuildContext context) {
    if (child == null) return const MoveWindow();
    return MoveWindow(
      child: child,
    );
  }
}

class CupertinoEasyAppBar extends StatefulWidget
    implements ObstructingPreferredSizeWidget {
  const CupertinoEasyAppBar({
    super.key,
    this.backgroundColor,
    this.child,
    this.parentContext,
  });

  final Color? backgroundColor;
  final Widget? child;
  final BuildContext? parentContext;

  @override
  bool shouldFullyObstruct(BuildContext context) {
    var cx = parentContext ?? context;
    Color? easy = CupertinoDynamicColor.maybeResolve(
      this.backgroundColor,
      cx,
    );
    Color? themeOf = CupertinoTheme.of(context).barBackgroundColor;
    final Color backgroundColor = easy ?? themeOf;
    int px = (backgroundColor.a * 255.0).round() & 0xff;
    return px == 0xFF;
  }

  @override
  Size get preferredSize {
    double calc = kToolbarHeight;
    if (GetPlatform.isMacOS) {
      calc += kMacPaddingTop;
    }
    return Size.fromHeight(calc);
  }

  @override
  State<CupertinoEasyAppBar> createState() => _CupertinoEasyAppBarState();
}

class _CupertinoEasyAppBarState extends State<CupertinoEasyAppBar> {
  Widget get _child {
    Widget? child = widget.child;
    if (child == null) return const SizedBox.shrink();
    Widget target = child;
    if (GetPlatform.isMacOS) {
      target = Padding(
        padding: EdgeInsets.only(
          top: kMacPaddingTop,
        ),
        child: child,
      );
    }
    if (GetPlatform.isMobile) {
      target = Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: target,
      );
    }
    return MoveWindow(child: target);
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: _child);
  }
}

class WindowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WindowAppBar({
    super.key,
    this.toolBarHeigth,
    this.title,
    this.iosBackStyle = false,
    this.actions = const [],
    this.centerTitle = false,
  });

  final bool iosBackStyle;

  final bool centerTitle;

  final Widget? title;

  bool get isSupport {
    return GetPlatform.isDesktop;
  }

  final double? toolBarHeigth;

  final List<Widget> actions;

  double get _macosPaddingHeight {
    return GetPlatform.isMacOS ? kMacPaddingTop : 0;
  }

  /// [bar] 的高度
  double get barHeigth {
    if (toolBarHeigth != null) return toolBarHeigth as double;
    return kToolbarHeight + _macosPaddingHeight;
  }

  Widget titleWidget(Color purueColor) {
    var cx = Get.context;
    if (cx == null) {
      return BackButton(
        color: purueColor,
      );
    }
    if (title != null) {
      return DefaultTextStyle(
        style: Theme.of(cx).appBarTheme.titleTextStyle ?? const TextStyle(),
        child: title as Widget,
      );
    }
    if (iosBackStyle) {
      return CupertinoNavigationBarBackButton(
        color: purueColor,
        onPressed: () => Get.back(),
      );
    }
    return BackButton(
      color: purueColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color purueColor = context.isDarkMode ? Colors.blue : Colors.white;

    List<Widget> childrens = [
      titleWidget(purueColor),
      IconTheme(
        data: Theme.of(context).primaryIconTheme,
        child: Row(
          children: actions,
        ),
      )
    ];
    if (centerTitle) {
      childrens.insert(
        0,
        const Text(''),
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: CustomMoveWindow(
        child: PreferredSize(
          preferredSize: preferredSize,
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.only(
              top: _top,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: childrens,
                  ),
                ),
                if (GetPlatform.isDesktop && !GetPlatform.isMacOS)
                  SizedBox(width: 6),
                if (GetPlatform.isDesktop && !GetPlatform.isMacOS)
                  Macwindowctl(
                    buttonSize: 12,
                    blurSize: 24,
                    focused: true,
                    buttonReverse: true,
                    onClick: (action) {
                      switch (action) {
                        case MacwindowctlAction.close:
                          appWindow.close();
                          break;
                        case MacwindowctlAction.maximize:
                          appWindow.maximizeOrRestore();
                          break;
                        case MacwindowctlAction.minimize:
                          appWindow.minimize();
                          break;
                        default:
                      }
                    },
                  ),
                SizedBox(width: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double get _top {
    var h = MediaQuery.of(Get.context!).padding.top;
    return h + _macosPaddingHeight;
  }

  @override
  Size get preferredSize => Size.fromHeight(barHeigth);
}
