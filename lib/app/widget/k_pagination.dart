// Copyright (C) 2021 d1y <chenhonzhou@gmail.com>
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum KPaginationActionButtonDirection {
  /// 左边
  l,

  /// 右边
  r
}

typedef KPaginationActionCallback = void Function(
  KPaginationActionButtonDirection type,
);

typedef KPaginationInputChangeCallback = void Function(
  int value,
);

class KPaginationActionButton extends StatelessWidget {
  KPaginationActionButton({
    Key? key,
    this.direction = KPaginationActionButtonDirection.l,
    this.disable = false,
    required this.onTap,
  }) : super(key: key);

  final KPaginationActionButtonDirection direction;
  final bool disable;
  final VoidCallback onTap;

  bool get isLeft => direction == KPaginationActionButtonDirection.l;

  String get directionStr {
    if (isLeft) return "上一页";
    return "下一页";
  }

  Color get borderColor {
    return (Get.isDarkMode ? Colors.white : Colors.black);
  }

  double get boxOpacity {
    return disable ? .3 : 1;
  }

  final List<IconData> _icons = [
    CupertinoIcons.left_chevron,
    CupertinoIcons.right_chevron
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Text(
        directionStr,
        style: TextStyle(fontSize: 9),
      ),
    ];
    int index = 0;
    if (!isLeft) index = 1;
    IconData icon = _icons[index];
    children.insert(
      index,
      Icon(
        icon,
        size: 15,
      ),
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: boxOpacity,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 3,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

class KPagination extends StatefulWidget {
  final KPaginationActionCallback onActionTap;

  final bool turnL;

  final bool turnR;

  final VoidCallback onJumpTap;

  final TextEditingController textEditingController;

  const KPagination({
    Key? key,
    required this.onActionTap,
    required this.onJumpTap,
    required this.textEditingController,
    this.turnL = true,
    this.turnR = true,
  }) : super(key: key);

  @override
  _KPaginationState createState() => _KPaginationState();
}

class _KPaginationState extends State<KPagination> {
  TextEditingController get textEditingController =>
      widget.textEditingController;

  int get outputTextValue {
    var text = textEditingController.text;
    return int.parse(text);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant KPagination oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              KPaginationActionButton(
                disable: !widget.turnL,
                onTap: () {
                  if (widget.turnL)
                    widget.onActionTap(KPaginationActionButtonDirection.l);
                },
              ),
              SizedBox(
                width: 6,
              ),
              KPaginationActionButton(
                disable: !widget.turnR,
                direction: KPaginationActionButtonDirection.r,
                onTap: () {
                  if (widget.turnR)
                    widget.onActionTap(KPaginationActionButtonDirection.r);
                },
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                child: CupertinoTextField(
                  controller: textEditingController,
                  textAlign: TextAlign.center,

                  /// 怕不是要上天, 一个分页给爷整个几千页?
                  /// 给爷稳一点
                  /// @龙馨竹
                  maxLength: 4,

                  /// The content entered must be a number!!
                  /// link: https://stackoverflow.com/a/49578197
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,

                  padding: EdgeInsets.zero,
                  strutStyle: StrutStyle(
                    forceStrutHeight: true,
                  ),
                  style: TextStyle(
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                width: 66,
              ),
              SizedBox(
                width: 6,
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    widget.onJumpTap();
                  },
                  child: Text(
                    "点击跳转",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
