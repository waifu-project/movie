import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:movie/utils/screen_helper.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewView extends StatefulWidget {
  const WebviewView({Key? key}) : super(key: key);

  @override
  _WebviewViewState createState() => _WebviewViewState();
}

class _WebviewViewState extends State<WebviewView> {
  final url = Get.arguments;

  // bool isLand = false;

  @override
  void initState() {
    Wakelock.enable();
    execScreenDirction(ScreenDirction.x);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
    execScreenDirction(ScreenDirction.y);
  }

  // bool showBackButton = true;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      body: Stack(
        children: [
          WebView(
            initialUrl: url,
            javascriptMode: JavascriptMode.unrestricted,
          ),
          // Positioned(
          //   child: GestureDetector(
          //     child: Container(
          //       width: 42,
          //       height: 42,
          //       decoration: BoxDecoration(
          //         color: Colors.black,
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       child: Icon(
          //         CupertinoIcons.fullscreen,
          //         color: Colors.white,
          //       ),
          //     ),
          //     onTap: () {
          //       // setState(() {
          //       //   if (isLand) {
          //       //     isLand = !isLand;
          //       //     AutoOrientation.portraitUpMode();
          //       //   } else {
          //       //     isLand = !isLand;
          //       //     AutoOrientation.landscapeLeftMode();
          //       //   }
          //       // });
          //     },
          //   ),
          //   top: 33,
          //   right: 18,
          // )
        ],
      ),
    );
  }
}
