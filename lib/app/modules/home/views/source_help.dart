import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie/app/extension.dart';
import 'package:movie/app/modules/home/views/home_config.dart';
import 'package:movie/app/widget/k_error_stack.dart';
import 'package:movie/app/widget/window_appbar.dart';
import 'package:movie/spider/impl/mac_cms.dart';
import 'package:movie/spider/utils/source.dart';
import 'package:movie/spider/shared/manage.dart';
import 'package:movie/shared/enum.dart';
import 'package:movie/utils/helper.dart';
import 'package:movie/utils/http.dart';
import 'package:clipboard/clipboard.dart';
import 'package:movie/utils/json.dart';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class SourceItemJSONData {
  String? title;
  String? url;
  String? msg;
  bool? nsfw;

  SourceItemJSONData({
    this.title,
    this.url,
    this.msg,
    this.nsfw,
  });

  SourceItemJSONData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    url = json['url'];
    msg = json['msg'];
    nsfw = json['nsfw'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['url'] = url;
    data['msg'] = msg;
    data['nswf'] = nsfw;
    return data;
  }
}

class SourceHelpTable extends StatefulWidget {
  const SourceHelpTable({Key? key}) : super(key: key);

  @override
  _SourceHelpTableState createState() => _SourceHelpTableState();
}

class _SourceHelpTableState extends State<SourceHelpTable> {
  bool get showNSFW {
    return getSettingAsKeyIdent<bool>(SettingsAllKey.isNsfw);
  }

  loadMirrorListApi() async {
    setState(() {
      _isLoadingFromAJAX = true;
    });
    try {
      var resp = await XHttp.dio.get(
        fetchMirrorAPI,
        options: $toDioOptions(CachePolicy.noCache),
      );
      List<SourceItemJSONData> data = List.from(resp.data)
          .map((e) => SourceItemJSONData.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!showNSFW) {
        data = data.where((element) {
          return !(element.nsfw ?? true);
        }).toList();
      }
      setState(() {
        mirrors = data;
        _isLoadingFromAJAX = false;
        _loadingErrorStack = "";
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _isLoadingFromAJAX = false;
        _loadingErrorStack = e.toString();
      });
    }
  }

  bool _isLoadingFromAJAX = false;

  String _loadingErrorStack = "";

  List<SourceItemJSONData> mirrors = [];

  @override
  void initState() {
    super.initState();
    loadMirrorListApi();
  }

  String get playfulConfirmText {
    return "我知道了";
  }

  handleCopyText({
    SourceItemJSONData? item,
    bool canCopyAll = false,
  }) async {
    List<SourceItemJSONData> actions = mirrors;
    if (!canCopyAll && item != null) actions = [item];
    var ctx = Get.context;
    if (ctx == null) return;
    await Future.forEach(actions, (SourceItemJSONData element) {
      var msg = element.msg ?? "";
      Completer completer = Completer();
      if (msg.isEmpty) {
        completer.complete();
        return completer.future;
      }
      showEasyCupertinoDialog(
        context: ctx,
        content: Text(element.msg ?? ""),
        title: element.title,
        confirmText: playfulConfirmText,
        onDone: () {
          Get.back();
          completer.complete();
        },
      );
      return completer.future;
    });

    String result = actions[0].url ?? "";

    if (canCopyAll) {
      result = "";
      for (var element in actions) {
        result += '${element.url}\n';
      }
    }
    if (result.isEmpty) return;
    await FlutterClipboard.copy(result);
    showEasyCupertinoDialog(content: '已复制到剪贴板!');
  }

  String get _wrapperAjaxStatusLable {
    if (!_isLoadingFromAJAX) return "啥也没有";
    return "加载网络资源中";
  }

  /// 判断加载失败
  bool get _canLoadFail {
    return _loadingErrorStack.isNotEmpty && !_isLoadingFromAJAX;
  }

  /// 导入文件
  handleImportFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'json',
        'txt',
      ],
    );

    if (result == null) {
      showEasyCupertinoDialog(
        content: "未选择文件 :(",
        confirmText: playfulConfirmText,
      );
      return;
    }
    List<File> files = result.paths.map((path) => File(path!)).toList();

    // ==========================
    var sourceKey = "source";
    var filenameKey = "filename";
    // ==========================

    var data = files
        .where((e) => !isBinaryAsFile(e))
        .toList()
        .map<Map<String, dynamic>>((item) {
          String filename = item.uri.pathSegments.last;
          return {
            sourceKey: item.readAsStringSync(),
            filenameKey: filename,
          };
        })
        .toList()
        .where((e) => verifyStringIsJSON(e[sourceKey] as String))
        .toList();
    if (data.isEmpty) {
      showEasyCupertinoDialog(
        content: "导入的文件格式错误 :(",
        confirmText: playfulConfirmText,
      );
      return;
    }
    var _collData = <String, List<MacCMSSpider>>{};
    for (var item in data) {
      String source = item[sourceKey] as String;
      String filename = item[filenameKey] as String;
      var easyParseData = SourceUtils.tryParseDynamic(source);
      if (easyParseData == null) continue;
      List<MacCMSSpider> result = [];
      if (easyParseData is MacCMSSpider) {
        result = [easyParseData];
      } else if (easyParseData is List) {
        var append = easyParseData
            .where((element) {
              return element != null;
            })
            .toList()
            .map((ele) {
              return ele as MacCMSSpider;
            });
        result.addAll(append);
      }
      _collData[filename] = result;
    }

    String easyMessage = "";
    List<MacCMSSpider> stack = [];

    _collData.forEach((k, v) async {
      int len = v.length;
      if (v.isNotEmpty) {
        stack.addAll(v);
        easyMessage += "$k中有$len个源\n";
      }
    });
    if (stack.isEmpty) {
      showEasyCupertinoDialog(
        content: "未导入源, 可能是JSON文件格式不对? :(",
        confirmText: playfulConfirmText,
      );
      return;
    } else {
      var _easyData = SourceUtils.mergeMirror(
        stack,
        diff: true,
      );
      var _diff = _easyData[0] as int;
      if (_diff > 0) {
        var newListData = _easyData[1] as dynamic;
        await SpiderManage.mergeSpider(newListData);
      }
      var diffMsg = "本次共合并$_diff个源!";
      if (_diff <= 0) {
        diffMsg = "本次未合并!没有新的源!";
      }
      easyMessage += '\n' + diffMsg;
      showEasyCupertinoDialog(
        content: Column(
          children: [
            const Icon(
              CupertinoIcons.hand_thumbsup,
              size: 51,
              color: CupertinoColors.systemBlue,
            ),
            const SizedBox(
              height: 24,
            ),
            Text(easyMessage),
          ],
        ),
        confirmText: "好耶ヾ(✿ﾟ▽ﾟ)ノ",
      );
    }
  }

  Widget get _errorWidget {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "// 需要科学上网",
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              decorationColor: CupertinoColors.systemPink,
              color: CupertinoColors.systemPink,
              fontSize: 18,
            ),
          ),
          KErrorStack(
            msg: _loadingErrorStack,
          ),
        ],
      ),
    );
  }

  Widget get _mirrorEmptyStateWidget {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Builder(builder: (context) {
            if (_isLoadingFromAJAX) {
              return const CircularProgressIndicator();
            }
            return const Icon(CupertinoIcons.zzz);
          }),
          const SizedBox(
            height: 24,
          ),
          Text(
            _wrapperAjaxStatusLable,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoEasyAppBar(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CupertinoNavigationBarBackButton(),
                  Text(
                    "o(-`д´- ｡)",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 12,
                    ),
                    child: CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.arrow_down_square_fill,
                            color: CupertinoColors.white,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            "导入文件",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge!.copyWith(
                                  color: CupertinoColors.white,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                      onPressed: handleImportFiles,
                    ),
                  ),
                ],
              ),
              const Divider()
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: CupertinoScrollbar(
                  child: Builder(
                    builder: (context) {
                      if (mirrors.isEmpty) {
                        if (_canLoadFail) {
                          return _errorWidget;
                        }
                        return _mirrorEmptyStateWidget;
                      }
                      return ListView(
                        children: mirrors.map((item) {
                          return CupertinoListTile(
                            title: Text(
                              item.title ?? "",
                              style: TextStyle(
                                color: Get.isDarkMode
                                    ? Colors.white54
                                    : Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              handleCopyText(item: item);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  if (mirrors.isEmpty) {
                    if (_canLoadFail) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 24,
                        ),
                        child: CupertinoButton.filled(
                          padding: const EdgeInsets.all(12),
                          child: const Text("重新加载"),
                          onPressed: () {
                            loadMirrorListApi();
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 12,
                    ),
                    child: CupertinoButton.filled(
                      borderRadius: BorderRadius.circular(24),
                      child: const Text("一键复制到剪贴板"),
                      onPressed: () {
                        handleCopyText(canCopyAll: true);
                      },
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

showEasyCupertinoDialog({
  String? title,
  dynamic content,
  VoidCallback? onDone,
  BuildContext? context,
  String? confirmText,
}) {
  Widget child = const SizedBox.shrink();
  String outputTitle = title ?? "提示";
  String outputConfrimText = confirmText ?? "确定";
  if (content is Widget) {
    child = content;
  } else if (content is String) {
    child = Text(content);
  }
  var ctx = Get.context as BuildContext;
  if (context != null) ctx = context;
  showCupertinoDialog(
    builder: (BuildContext context) => EasyShowModalWidget(
      content: child,
      title: outputTitle,
      onDone: onDone,
      confirmText: outputConfrimText,
    ),
    context: ctx,
  );
}

class EasyShowModalWidget extends StatelessWidget {
  const EasyShowModalWidget({
    Key? key,
    this.onDone,
    required this.content,
    this.title = "提示",
    this.confirmText = "确定",
    this.confirmTextColor = Colors.red,
  }) : super(key: key);

  final VoidCallback? onDone;
  final String title;
  final Widget content;
  final String confirmText;
  final Color confirmTextColor;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Column(
        children: [
          Text(title),
        ],
      ),
      content: content,
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          child: Text(
            confirmText,
            style: TextStyle(
              color: confirmTextColor,
            ),
          ),
          onPressed: () {
            if (onDone != null) {
              onDone!();
            } else {
              Get.back();
            }
          },
        ),
      ],
    );
  }
}
