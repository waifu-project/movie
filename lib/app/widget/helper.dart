import 'package:flutter/material.dart';

const K_DEFAULT_IMAGE = "assets/images/image_faild.png";

Widget KCoverImage = Image.asset(
  K_DEFAULT_IMAGE,
  width: double.infinity,
  fit: BoxFit.cover,
);
