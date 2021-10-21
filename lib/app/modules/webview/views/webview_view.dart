import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/webview_controller.dart';

class WebviewView extends GetView<WebviewController> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    return GetBuilder<WebviewController>(
      builder: (webview) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6,),),
          ),
        ),
        body: WebView(
          initialUrl: webview.url,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
