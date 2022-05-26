// Copyright (C) 2022 d1y <chenhonzhou@gmail.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'mac.dart';

double kMacPaddingTop = 16;

class _MoveWindow extends StatelessWidget {
  _MoveWindow({Key? key, this.child}) : super(key: key);
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
      child: this.child ?? Container(),
    );
  }
}

class CustomMoveWindow extends StatelessWidget {
  final Widget? child;
  CustomMoveWindow({
    Key? key,
    this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (child == null) return _MoveWindow();
    return _MoveWindow(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: this.child!,
          ),
        ],
      ),
    );
  }
}

// FIXME
class CupertinoEasyAppBar extends StatefulWidget
    implements ObstructingPreferredSizeWidget {
  const CupertinoEasyAppBar({
    Key? key,
    this.backgroundColor,
    this.child,
  }) : super(key: key);

  final Color? backgroundColor;
  final Widget? child;

  @override
  bool shouldFullyObstruct(BuildContext context) {
    Color? easy = CupertinoDynamicColor.maybeResolve(
      this.backgroundColor,
      context,
    );
    Color? themeOf = CupertinoTheme.of(context).barBackgroundColor;
    final Color backgroundColor = easy ?? themeOf;
    return backgroundColor.alpha == 0xFF;
  }

  @override
  Size get preferredSize {
    double _calc = kToolbarHeight;
    if (GetPlatform.isMacOS) {
      _calc += kMacPaddingTop;
    }
    return Size.fromHeight(_calc);
  }

  @override
  State<CupertinoEasyAppBar> createState() => _CupertinoEasyAppBarState();
}

class _CupertinoEasyAppBarState extends State<CupertinoEasyAppBar> {
  Widget get _child {
    Widget? child = widget.child;

    /// FIXME: 若child为空
    /// FIXME: 多平台下
    if (child == null) return SizedBox.shrink();
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
    return _MoveWindow(
      child: target,
    );
  }

  @override
  Widget build(BuildContext context) {
    /// FIXME: material widget wrapper??
    return Material(child: _child);
  }
}

// class CupertinoDefaultAppBar extends CupertinoEasyAppBar {
//   const CupertinoDefaultAppBar({
//     Key? key,
//     this.leading,
//     this.middle,
//     this.trailing,
//     this.isBack = true,
//   }) : super(key: key);

//   final Widget? leading;
//   final Widget? middle;
//   final Widget? trailing;
//   final bool isBack;

//   Widget _easyWrapper(Widget? child) {
//     if (child == null) return SizedBox.shrink();
//     return child;
//   }

//   Widget get _leading {
//     if (leading != null) return leading as Widget;
//     if (isBack) return CupertinoNavigationBarBackButton();
//     return SizedBox.shrink();
//   }

//   Widget get _trailing => _easyWrapper(trailing);

//   Widget get _middle => _easyWrapper(middle);

//   Widget build(BuildContext context) {
//     return Row(children: [Text('Fix Me???'),]);
//   }
// }

class WindowAppBar extends StatelessWidget implements PreferredSizeWidget {
  WindowAppBar({
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

  Color get purueColor {
    return Get.isDarkMode ? Colors.blue : Colors.white;
  }

  Widget get titleWidget {
    var _ = Get.context;
    if (_ == null)
      return BackButton(
        color: purueColor,
      );
    if (title != null)
      return DefaultTextStyle(
        style: Theme.of(_).appBarTheme.titleTextStyle ?? TextStyle(),
        child: title as Widget,
      );
    if (iosBackStyle)
      return CupertinoNavigationBarBackButton(
        color: purueColor,
        onPressed: () => Get.back(),
      );
    return BackButton(
      color: purueColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    var childrens = [
      titleWidget,
      IconTheme(
        data: Theme.of(context).primaryIconTheme,
        child: Row(
          children: actions,
        ),
      )
    ];
    if (centerTitle)
      childrens.insert(
        0,
        Text(''),
      );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: CustomMoveWindow(
        child: PreferredSize(
          child: Container(
            color: Theme.of(context).primaryColor,
            width: double.infinity,
            padding: EdgeInsets.only(
              top: _top,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: childrens,
                  ),
                ),
                Builder(builder: (context) {
                  if (GetPlatform.isDesktop && !GetPlatform.isMacOS) {
                    return Macwindowctl(
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
                    );
                  }
                  return SizedBox.shrink();
                }),
              ],
            ),
          ),
          preferredSize: preferredSize,
        ),
      ),
    );
  }

  double get _top {
    var _h = MediaQuery.of(Get.context!).padding.top;
    return _h + _macosPaddingHeight;
  }

  @override
  Size get preferredSize => Size.fromHeight(barHeigth);
}
