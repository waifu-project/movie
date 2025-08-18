// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget kErrorImage = ClipRRect(
  borderRadius: BorderRadius.circular(8.0),
  child: const DecoratedBox(
    decoration: BoxDecoration(
      color: CupertinoColors.black,
    ),
    child: Center(
      child: Column(
        spacing: 6,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 42,
            color: Colors.white,
          ),
          Text("加载失败", style: TextStyle(color: Colors.white))
        ],
      ),
    ),
  ),
);
