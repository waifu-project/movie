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
    super.key,
    this.padding = const EdgeInsets.symmetric(
      vertical: 6,
      horizontal: 15,
    ),
    this.margin = const EdgeInsets.fromLTRB(0, 0, 8, 6),
    this.backgroundColor = Colors.black26,
    required this.child,
    required this.onTap,
  });

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
        spacing: 3,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            hoverColor: Colors.transparent,
            onTap: () {
              onTap(KTagTapEventType.content);
            },
            child: child,
          ),
          InkWell(
            hoverColor: Colors.transparent,
            onTap: () {
              onTap(KTagTapEventType.action);
            },
            child: const Icon(
              Icons.close,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }
}
