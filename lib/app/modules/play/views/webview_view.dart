import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:movie/app/modules/play/controllers/play_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewView extends GetView {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    return GetBuilder<PlayController>(
      builder: (play) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                6,
              ),
            ),
          ),
        ),
        body: WebView(
          initialUrl: Get.arguments,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
