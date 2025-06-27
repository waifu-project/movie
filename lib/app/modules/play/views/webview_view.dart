import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:catmovie/utils/screen_helper.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewView extends StatefulWidget {
  const WebviewView({super.key});

  @override
  createState() => _WebviewViewState();
}

class _WebviewViewState extends State<WebviewView> {
  final url = Get.arguments;

  late final WebViewController controller;

  @override
  void initState() {
    WakelockPlus.enable();
    execScreenDirction(ScreenDirction.x);
    init();
    super.initState();
  }

  void init() {
    // https://github.com/flutter/packages/blob/853c6773177a32be019c55c2ff45c9908196dadd/packages/webview_flutter/webview_flutter/example/lib/simple_example.dart#L27C5-L48C40
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(url));
  }

  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
    execScreenDirction(ScreenDirction.y);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black38,
        ),
        margin: const EdgeInsets.symmetric(vertical: 9),
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
      body: WebViewWidget(controller: controller),
    );
  }
}
