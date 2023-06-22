import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:movie/app/modules/home/controllers/home_controller.dart';
import 'package:movie/widget/simple_html/flutter_html.dart';

import 'settings_view.dart';

// ===============文明社会从你我他做起🤡
const kAnswer1 = '2';
const kAnswer2 = '3';
// ===============

class NsfwTableView extends StatefulWidget {
  const NsfwTableView({Key? key}) : super(key: key);

  @override
  _NsfwTableViewState createState() => _NsfwTableViewState();
}

class _NsfwTableViewState extends State<NsfwTableView> {
  final HomeController home = Get.find<HomeController>();

  Future<String> loadNsfwAsset() async {
    return await rootBundle.loadString('assets/data/nsfw.html');
  }

  TextEditingController c1 = TextEditingController(text: "");
  TextEditingController c2 = TextEditingController(text: "");

  String a1 = "";
  String a2 = "";

  bool get canInputNext {
    var answer1 = a1 == kAnswer1;
    var answer2 = a2 == kAnswer2;
    return answer1 && answer2;
  }

  String html = "";

  @override
  void initState() {
    c1.addListener(() {
      setState(() {
        a1 = c1.text;
      });
    });
    c2.addListener(() {
      setState(() {
        a2 = c2.text;
      });
    });
    loadHtmlCode();
    super.initState();
  }

  @override
  void dispose() {
    c1.dispose();
    c2.dispose();
    super.dispose();
  }

  loadHtmlCode() async {
    var data = await loadNsfwAsset();
    setState(() {
      html = data;
    });
  }

  handleOpen() {
    Get.back(
      result: GetBackResultType.success,
    );
  }

  String get tips => "为了确定您已经未成年, 请完成一道数学题之后开启:  ";
  String get question => "某个住在湖边的老人养有狗和鸭子，某天，老人看到5个头、14只脚。那么老人看到的是多少条狗？多少只鸭子？";
  String get q1 => '狗子🐶: ';
  String get q2 => '鸭子🦆: ';

  @override
  Widget build(BuildContext context) {
    Color currTextColor = Get.isDarkMode ? Colors.white : Colors.black;
    return DefaultTextStyle(
      style: TextStyle(
        color: currTextColor,
      ),
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          previousPageTitle: '开启NSFW',
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Html(data: html),
                DefaultTextStyle(
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: currTextColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tips, style: const TextStyle(fontSize: 21)),
                        const SizedBox(height: 12),
                        Text(question, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 12),
                        Text(q1),
                        const SizedBox(height: 6),
                        CupertinoTextField(
                          controller: c1,
                          style: TextStyle(color: currTextColor),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        Text(q2),
                        const SizedBox(height: 6),
                        CupertinoTextField(
                          controller: c2,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: currTextColor),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: CupertinoButton(
                            color: CupertinoColors.activeBlue,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 42.0,
                            ),
                            onPressed: canInputNext ? handleOpen : null,
                            child: const Text("开启"),
                          ),
                        ),
                        SizedBox(height: Get.height * .12)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
