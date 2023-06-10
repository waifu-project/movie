// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

const K_DEFAULT_IMAGE = "assets/images/image_faild.png";

Widget kCoverImage = Image.asset(
  K_DEFAULT_IMAGE,
  width: double.infinity,
  fit: BoxFit.cover,
);
