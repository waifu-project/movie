// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const K_DEFAULT_IMAGE = "assets/images/image_faild.png";

Widget kCoverImage = Image.asset(
  K_DEFAULT_IMAGE,
  width: double.infinity,
  fit: BoxFit.cover,
);

Widget kErrorImage = ClipRRect(
  borderRadius: BorderRadius.circular(8.0),
  child: const DecoratedBox(
    decoration: BoxDecoration(
      color: CupertinoColors.black,
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 42,
          ),
          SizedBox(height: 6),
          Text("加载失败")
        ],
      ),
    ),
  ),
);
