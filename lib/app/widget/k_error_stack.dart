import 'package:flutter/material.dart';

/// 错误栈最大行数
const int kErrorStackMaxLine = 12;

/// 错误栈展示 `widget`
class KErrorStack extends StatelessWidget {
  const KErrorStack({
    super.key,
    this.msg = "",
    this.maxLine,
  });

  final String msg;

  final int? maxLine;

  int get _maxLine => maxLine ?? kErrorStackMaxLine;

  @override
  Widget build(BuildContext context) {
    if (msg.isEmpty) return const SizedBox.shrink();
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          msg,
          maxLines: _maxLine,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
