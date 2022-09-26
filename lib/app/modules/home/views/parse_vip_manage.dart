import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:movie/app/widget/window_appbar.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:movie/models/movie_parse.dart';
import 'package:movie/utils/helper.dart';

import '../controllers/home_controller.dart';

class ParseVipManagePageView extends StatefulWidget {
  const ParseVipManagePageView({Key? key}) : super(key: key);

  @override
  State<ParseVipManagePageView> createState() => _ParseVipManagePageViewState();
}

class _ParseVipManagePageViewState extends State<ParseVipManagePageView> {
  final HomeController home = Get.find<HomeController>();
  List<MovieParseModel> get parseList => home.parseVipList;
  int get parseListCurrentIndex => home.currentParseVipIndex;

  @override
  initState() {
    super.initState();
  }

  easyAddVipParseModel() async {
    var futureWith = await showCupertinoModalBottomSheet<MovieParseModel>(
      context: context,
      builder: (BuildContext context) => ParseVipAddDialog(),
    );
    if (futureWith == null) return;
    home.addMovieParseVipOnce(futureWith);
    setState(() {});
  }

  easyRemoveOnceVipParseModel(int index) {
    home.removeMovieParseVipOnce(index);
    setState(() {});
  }

  easySetDefaultOnceVipParseModal(int index) {
    home.setDefaultMovieParseVipIndex(index);
    setState(() {});
  }

  easyShowHelp() {
    showCupertinoDialog(
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('帮助'),
        content: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
          ),
          child: Text(
            '''某些白名单播放链接(例如.爱奇艺,腾讯)需要解析才可以播放''',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text(
              '我知道了',
              style: TextStyle(
                color: CupertinoColors.activeBlue,
              ),
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
      context: Get.context as BuildContext,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WindowAppBar(
        iosBackStyle: true,
        title: Row(
          children: [
            SizedBox(
              width: 6.0,
            ),
            GestureDetector(
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  CupertinoIcons.back,
                  color: Theme.of(context).primaryIconTheme.color,
                ),
              ),
              onTap: () {
                Get.back();
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 9,
              ),
              child: Text(
                "解析源管理",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: easyAddVipParseModel,
            child: Icon(Icons.add),
          ),
          SizedBox(
            width: 12.0,
          ),
          GestureDetector(
            onTap: easyShowHelp,
            child: Icon(Icons.help),
          ),
          SizedBox(
            width: 12.0,
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (parseList.length <= 0) {
          return _buildWithEmptry;
        }
        return _buildWithListBody;
      }),
    );
  }

  Widget get _buildWithEmptry {
    return Container(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                "assets/images/error.png",
                width: Get.width * .33,
              ),
              SizedBox(
                height: 24,
              ),
              Text("暂无解析接口 :("),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _buildWithListBody {
    return ListView.builder(
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
                  backgroundColor: Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: CupertinoIcons.delete,
                  flex: 1,
                  label: '删除',
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(),
              margin: EdgeInsets.symmetric(
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
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
                    padding: EdgeInsets.symmetric(
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
                            : Theme.of(context).textTheme.caption?.color,
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
  const ParseVipAddDialog({Key? key}) : super(key: key);

  @override
  State<ParseVipAddDialog> createState() => _ParseVipAddDialogState();
}

class _ParseVipAddDialogState extends State<ParseVipAddDialog> {
  String name = '';
  String url = '';
  final _formKey = GlobalKey<FormState>();

  submit() async {
    bool isNext = _formKey.currentState!.validate();
    if (!isNext) return;
    var model = MovieParseModel(
      name: name,
      url: url,
    );
    Get.back<MovieParseModel>(result: model);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        width: double.infinity,
        height: Get.height * .42,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.0, // 0.0 means one physical pixel
              ),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Icon(
                Icons.close,
                size: 18,
                color: CupertinoColors.systemBlue,
              ),
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                          decoration: InputDecoration(hintText: '输入名称'),
                          onChanged: (value) {
                            name = value;
                            setState(() {});
                          },
                          validator: (value) {
                            var _b = value!.length >= 2;
                            var msg = _b ? null : '名称最少2个字符';
                            return msg;
                          },
                        ),
                        TextFormField(
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                          decoration: InputDecoration(hintText: '输入URL'),
                          onChanged: (value) {
                            url = value;
                            setState(() {});
                          },
                          validator: (value) {
                            bool bindCheck = isURL(value);
                            return !bindCheck ? '不是url' : null;
                          },
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton.filled(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            onPressed: submit,
                            child: Text(
                              "添加",
                              style: TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
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
      ),
    );
  }
}
