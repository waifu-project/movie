import 'dart:io';

import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:catmovie/isar/schema/parse_schema.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:xi/xi.dart';

import '../controllers/home_controller.dart';
import 'source_help.dart';

enum KStatusCounter {
  success,
  fail,
  total,
}

typedef ValueImportCallback<T> = void Function(T value, List<dynamic> data);

class ParseVipManagePageView extends StatefulWidget {
  const ParseVipManagePageView({super.key});

  @override
  State<ParseVipManagePageView> createState() => _ParseVipManagePageViewState();
}

class _ParseVipManagePageViewState extends State<ParseVipManagePageView> {
  final HomeController home = Get.find<HomeController>();
  List<ParseIsarModel> get parseList => home.parseVipList;
  int get parseListCurrentIndex => home.currentParseVipIndex;

  @override
  initState() {
    super.initState();
  }

  Future<void> easyAddVipParseModel() async {
    var futureWith = await showCupertinoModalBottomSheet<ParseIsarModel>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => ParseVipAddDialog(
        onImport: (data, statusCounter) {
          home.addMovieParseVip(data);
          setState(() {});
          String msg =
              '''本次导入成功${statusCounter[0]}, 失败${statusCounter[1]}, 共${statusCounter[2]}''';
          showEasyCupertinoDialog(
            title: '提示',
            content: msg,
            onDone: () {
              Get.back();
            },
          );
        },
      ),
    );
    if (futureWith == null) return;
    home.addMovieParseVip(futureWith);
    setState(() {});
  }

  void easyRemoveOnceVipParseModel(int index) {
    home.removeMovieParseVipOnce(index);
    setState(() {});
  }

  void easySetDefaultOnceVipParseModal(int index) {
    home.setDefaultMovieParseVipIndex(index);
    setState(() {});
  }

  void easyShowHelp() {
    showEasyCupertinoDialog(
      title: '帮助',
      content: '''某些白名单播放链接(例如.爱奇艺,腾讯)需要解析才可以播放''',
      confirmText: '我知道了',
      onDone: () {
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var textColor = context.isDarkMode ? Colors.white : Colors.black;
    return Scaffold(
      appBar: WindowAppBar(
        iosBackStyle: true,
        title: Zoom(
          onTap: () => Get.back(),
          child: Row(
            children: [
              const SizedBox(width: 6.0),
              GestureDetector(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    CupertinoIcons.back,
                    color: textColor,
                  ),
                ),
                onTap: () {
                  Get.back();
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 9),
                child: Text(
                  "解析源管理",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: textColor),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Zoom(onTap: easyAddVipParseModel, child: Icon(Icons.add, color: textColor,)),
          const SizedBox(width: 12.0),
          Zoom(onTap: easyShowHelp, child: Icon(Icons.help, color: textColor,)),
          const SizedBox(width: 12.0),
        ],
      ),
      body: Builder(builder: (context) {
        if (parseList.isEmpty) {
          return _buildWithEmptry;
        }
        return _buildWithListBody;
      }),
    );
  }

  Widget get _buildWithEmptry {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          spacing: 24,
          children: [
            Image.asset(
              "assets/images/error.png",
              width: 120,
              height: 120,
            ),
            Text(
              "暂无解析接口 :(",
              style: TextStyle(
                color: (context.isDarkMode ? '#6f737a' : '#767a82').$color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _buildWithListBody {
    return SmoothListView.builder(
      duration: kSmoothListViewDuration,
      controller: ScrollController(),
      itemCount: parseList.length,
      itemBuilder: (BuildContext context, int index) {
        var curr = parseList[index];
        bool isSelected = parseListCurrentIndex == index;
        return Material(
          child: Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              key: ObjectKey(curr),
              children: [
                if (!isSelected)
                  SlidableAction(
                    onPressed: (_) {
                      easySetDefaultOnceVipParseModal(index);
                    },
                    backgroundColor: CupertinoColors.systemBlue,
                    foregroundColor: Colors.white,
                    icon: CupertinoIcons.bag,
                    flex: 2,
                    label: '设为默认',
                  ),
                SlidableAction(
                  onPressed: (_) {
                    easyRemoveOnceVipParseModel(index);
                  },
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: CupertinoIcons.delete,
                  flex: 1,
                  label: '删除',
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(),
              margin: const EdgeInsets.symmetric(
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 12.0,
                      ),
                      Text(
                        curr.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? CupertinoColors.systemBlue : null,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                    ),
                    child: Text(
                      curr.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: isSelected
                            ? CupertinoColors.systemGrey
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ParseVipAddDialog extends StatefulWidget {
  const ParseVipAddDialog({
    super.key,
    required this.onImport,
  });

  final ValueImportCallback<List<ParseIsarModel>> onImport;

  @override
  State<ParseVipAddDialog> createState() => _ParseVipAddDialogState();
}

class _ParseVipAddDialogState extends State<ParseVipAddDialog> {
  String name = '';
  String url = '';
  final _formKey = GlobalKey<FormState>();

  Future<void> submit() async {
    bool isNext = _formKey.currentState!.validate();
    if (!isNext) return;
    var model = ParseIsarModel(
      name,
      url,
    );
    Get.back<ParseIsarModel>(result: model);
  }

  Future<void> handleImportFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'json',
      ],
    );
    if (result == null) {
      showEasyCupertinoDialog(
        content: "未选择文件 :(",
        confirmText: '我知道了',
      );
      return;
    }
    var files = result.paths.map((path) => File(path!)).toList();
    List<String> contents = [];
    for (var file in files) {
      var data = file.readAsStringSync();
      contents.add(data);
    }
    contents = contents.where(verifyStringIsJSON).toList();
    List<ParseIsarModel> outputData = [];

    /// 状态计数器
    /// [0] => 成功
    /// [1] => 失败
    /// [2] => 总数()
    List<int> statusCounter = [0, 0, 0];
    try {
      for (var content in contents) {
        JSONBodyType? jsonType = getJSONBodyType(content);
        List<ParseIsarModel> data = [];
        if (jsonType == JSONBodyType.array) {
          var verifiedData = movieParseModelFromJson(content);
          for (var whenData in verifiedData) {
            var canBeNext = isURL(whenData.url);
            var point =
                canBeNext ? KStatusCounter.success : KStatusCounter.fail;
            statusCounter[point.index]++;
            if (canBeNext) {
              data.add(whenData);
            }
          }
        } else if (jsonType == JSONBodyType.obj) {
          var onceData = ParseIsarModel.fromJson(jsonc.decode(content));
          var canBeNext = isURL(onceData.url);
          var point = canBeNext ? KStatusCounter.success : KStatusCounter.fail;
          statusCounter[point.index]++;
          if (canBeNext) {
            data.add(onceData);
          }
        }
        if (data.isEmpty) continue;
        statusCounter[KStatusCounter.total.index] = data.length;
        outputData.addAll(data);
      }
    } catch (e) {
      showEasyCupertinoDialog(
        title: '解析失败',
        content: e.toString(),
      );
      return;
    }
    if (statusCounter[KStatusCounter.total.index] >= 1) {
      Get.back();
      widget.onImport(outputData, statusCounter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: SizedBox(
          width: double.infinity,
          height: 420,
          child: CupertinoPageScaffold(
            backgroundColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: Text("解析源需要填写名称和URL",
                            style: TextStyle(fontSize: 18)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                              decoration:
                                  const InputDecoration(hintText: '输入名称'),
                              onChanged: (value) {
                                name = value;
                                setState(() {});
                              },
                              validator: (value) {
                                var b = value!.length >= 2;
                                var msg = b ? null : '名称最少2个字符';
                                return msg;
                              },
                            ),
                            TextFormField(
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                              decoration:
                                  const InputDecoration(hintText: '输入URL'),
                              onChanged: (value) {
                                url = value;
                                setState(() {});
                              },
                              validator: (value) {
                                bool bindCheck = isURL(value);
                                return !bindCheck ? '不是url' : null;
                              },
                            ),
                            const SizedBox(height: 12.0),
                            Zoom(
                              child: SizedBox(
                                width: double.infinity,
                                child: CupertinoButton.filled(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  onPressed: submit,
                                  child: const Text(
                                    "添加",
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
