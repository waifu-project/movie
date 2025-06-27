import 'package:executor/executor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/shared/mirror_status_stack.dart';
import 'package:xi/xi.dart';

// 这里的代码借鉴(抄袭)了:
//
// https://github.com/Hentioe/mikack-mobile/blob/d6c92e509ae4c7fce6aaea48202b34ebb3b9f546/lib/pages/search.dart#L3
// https://github.com/honjow/FEhViewer/blob/d3c0d773418cbf5ee3697bff3a081764b74aca04/lib/common/controller/download_state.dart#L4
// https://github.com/jiangtian616/JHenTai/blob/cbcb16d422ba28bff5c560493b8ad760e6746d20/lib/src/utils/eh_executor.dart#L6
//
// 可参考的包:
//
// https://pub.dev/packages/concurrent_queue
// https://pub.dev/packages/computer
//
// now impl is stupid, need reimpl...

enum MirrorTabButtonStatus {
  /// 取消
  cancel,

  /// 确定
  done,
}

class MirrorCheckView extends StatefulWidget {
  const MirrorCheckView({
    super.key,
    required this.list,
  });

  final List<ISpiderAdapter> list;

  @override
  State<MirrorCheckView> createState() => _MirrorCheckViewState();
}

class _MirrorCheckViewState extends State<MirrorCheckView> {
  double get _checkBoxWidth {
    var w = Get.width;
    if (w >= 900) return 320;
    return w * .6;
  }

  double get _checkBoxHeight {
    var h = Get.height;
    if (h >= 900) return 420;
    return h * .48;
  }

  bool running = false;

  List<ISpiderAdapter> get listStack => widget.list;

  int get listStackLen => listStack.length;

  Executor? executor = Executor(concurrency: 12);

  List<String> currCacheID = [];

  Future<void> runTasks() async {
    running = true;
    setState(() {});
    executor = Executor(concurrency: 12);
    var target = widget.list.where((element) {
      return !currCacheID.contains(element.meta.id);
    }).toList();
    if (target.isEmpty) {
      running = false;
      setState(() {});
      return;
    }
    debugPrint("即将执行任务(共${target.length})");
    for (var curr in target) {
      executor!.scheduleTask(() async {
        if (!mounted) return;
        bool isSuccess = false;
        updateCurrentStatusText("开始测试 ${curr.meta.name}");
        try {
          await curr.getHome();
          isSuccess = true;
          _success++;
          setState(() {});
        } catch (e) {
          isSuccess = false;
          debugPrint(e.toString());
          _fail++;
          setState(() {});
        }
        String id = curr.meta.id;
        debugPrint("测试: $id, 结果: ${isSuccess ? '成功' : '失败'}");
        MirrorStatusStack().pushStatus(id, isSuccess);
        if (_taskCount < listStackLen) {
          _taskCount++;
        }
        setState(() {});
        currCacheID.add(id);
      });
    }
    await executor!.join(withWaiting: true);
    await executor!.close();
    running = false;
    setState(() {});
  }

  void handleTapAction() {
    if (running) {
      executor?.close();
      running = false;
      setState(() {});
    } else {
      if (_taskCount != 0) {
        _taskCount--;
        setState(() {});
      }
      runTasks();
    }
  }

  /// 成功
  int _success = 0;

  /// 失败
  int _fail = 0;

  /// 当前执行任务数
  int _taskCount = 0;

  String get _taskText {
    return "任务: $_taskCount/$listStackLen";
  }

  String get _text {
    return "成功: $_success, 失败: $_fail";
  }

  void beforeHook() {
    running = true;
    setState(() {});
    runTasks();
  }

  bool get easyDone {
    return _taskCount == listStackLen && !running;
  }

  @override
  void initState() {
    super.initState();

    beforeHook();
  }

  @override
  void dispose() {
    super.dispose();
    executor?.close();
  }

  void handleClickMenu(MirrorTabButtonStatus action) {
    switch (action) {
      case MirrorTabButtonStatus.cancel:
        running = false;
        // MirrorStatusStack().clean();
        debugPrint("已取消 >_<");
        setState(() {});
        Get.back(
          result: false,
        );
        break;
      case MirrorTabButtonStatus.done:
        MirrorStatusStack().flash();
        Get.back(
          result: true,
        );
        break;
    }
  }

  String _currentStatusText = "";

  void updateCurrentStatusText(String text) {
    _currentStatusText = text;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: context.isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          width: _checkBoxWidth,
          height: _checkBoxHeight,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                "获取源状态",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 6,
              ),
              const Divider(
                thickness: 2,
              ),
              Expanded(
                child: Column(
                  children: [
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      child: Expanded(
                        child: Column(
                          children: [
                            Text(
                              _taskText,
                            ),
                            Text(
                              _text,
                            )
                          ],
                        ),
                      ),
                    ),
                    Builder(builder: (context) {
                      if (easyDone) {
                        return const Icon(
                          CupertinoIcons.archivebox,
                          size: 66,
                        );
                      }
                      return const CircularProgressIndicator();
                    }),
                    Builder(builder: (context) {
                      if (easyDone) return const SizedBox.shrink();
                      Color bgColor = Colors.white;
                      if (!context.isDarkMode) {
                        bgColor = Colors.black;
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _currentStatusText,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),
                    if (!easyDone)
                      const SizedBox(
                        height: 12,
                      ),
                    Builder(builder: (context) {
                      var text = "执行任务中";
                      if (easyDone) {
                        text = "任务已完成";
                      }
                      var child = Text(text);
                      if (easyDone) return Expanded(child: child);
                      return child;
                    }),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              if (!easyDone)
                CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  onPressed: handleTapAction,
                  child: Builder(builder: (context) {
                    String text = "暂停任务";
                    if (!running) {
                      text = "继续任务";
                    }
                    return Text(text);
                  }),
                ),
              const SizedBox(
                height: 8,
              ),
              const Divider(
                thickness: 1,
                height: 0,
              ),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text("取消"),
                        onPressed: () {
                          handleClickMenu(
                            MirrorTabButtonStatus.cancel,
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 1,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text("确定"),
                        onPressed: () {
                          handleClickMenu(
                            MirrorTabButtonStatus.done,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
