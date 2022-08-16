// Copyright (C) 2021-2022 d1y <chenhonzhou@gmail.com>
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


import 'package:flutter/material.dart';

/// [KTag] 事件触发类型
enum KTagTapEventType {
  /// 内容 [content]
  content,

  /// 右边 [action]
  action,
}

typedef KTapOnTap = void Function(KTagTapEventType type);

class KTag extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  final EdgeInsetsGeometry padding;

  final Color backgroundColor;

  final Widget child;

  final KTapOnTap onTap;

  const KTag({
    Key? key,
    this.padding = const EdgeInsets.symmetric(
      vertical: 6,
      horizontal: 15,
    ),
    this.margin = const EdgeInsets.fromLTRB(0, 0, 8, 6),
    this.backgroundColor = Colors.black26,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: backgroundColor,
      ),
      padding: padding,
      margin: margin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              onTap(KTagTapEventType.content);
            },
            child: child,
          ),
          SizedBox(
            width: 3,
          ),
          InkWell(
            onTap: () {
              onTap(KTagTapEventType.action);
            },
            child: Icon(
              Icons.close,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }
}
