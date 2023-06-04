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
