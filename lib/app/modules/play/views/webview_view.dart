import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewView extends StatefulWidget {
  const WebviewView({Key? key}) : super(key: key);

  @override
  _WebviewViewState createState() => _WebviewViewState();
}

class _WebviewViewState extends State<WebviewView> {
  final url = Get.arguments;

  @override
  void initState() {
    Wakelock.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  bool showBackButton = true;

  /// TODO 按钮在点击后三秒内将会 `opacity` => .1
  // double get opacityValue {
  //   return showBackButton ? 1.0 : .1;
  // }

  // late Timer opacityLight;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    return Scaffold(
      floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black38,
          ),
          margin: EdgeInsets.symmetric(vertical: 9),
          child: IconButton(
            icon: const BackButtonIcon(),
            color: Colors.white,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
        ),
    );
  }
}
