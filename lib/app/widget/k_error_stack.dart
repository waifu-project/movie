import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 错误栈最大行数
final int KErrorStackMaxLine = 12;

/// 错误栈展示 `widget`
class KErrorStack extends StatelessWidget {
  KErrorStack({
    Key? key,
    this.msg = "",
    this.maxLine,
  });

  final String msg;

  final int? maxLine;

  int get _maxLine => maxLine ?? KErrorStackMaxLine;

  @override
  Widget build(BuildContext context) {
    if (msg.isEmpty) return SizedBox.shrink();
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(Get.width * .05),
        child: Text(
          msg,
          maxLines: _maxLine,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ),
    );
    ;
  }
}
