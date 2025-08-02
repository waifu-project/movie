import 'package:catmovie/shared/manage.dart';
import 'package:xi/xi.dart';
import 'package:xi/models/mac_cms/source_data.dart';

class MirrorStatusStack {
  MirrorStatusStack._internal();
  factory MirrorStatusStack() => _instance;
  static final MirrorStatusStack _instance = MirrorStatusStack._internal();

  final Map<String, bool> _stacks = {};

  Map<String, bool> get getStacks => _stacks;

  final List<ISpiderAdapter> _datas = SpiderManage.extend;

  bool? getStack(String stack) {
    return _stacks[stack];
  }

  void pushStatus(String sourceKey, bool status, {bool canSave = false}) {
    _stacks[sourceKey] = status;
    if (canSave) {
      flash();
    }
  }

  void flash() {
    List<SourceJsonData> data = _datas.map((e) {
      bool status = e.meta.status;
      String id = e.meta.id;
      bool? bStatus = getStack(id);
      if (bStatus != null) {
        status = bStatus;
      }
      return SourceJsonData(
        name: e.meta.name,
        logo: e.meta.logo,
        desc: e.meta.desc,
        nsfw: e.isNsfw,
        api: Api(
          root: e.meta.domain,
          path: (e as MacCMSSpider).api_path,
        ),
        id: id,
        status: status,
      );
    }).toList();
    SpiderManage.mergeSpider(data);
  }

  void clean() {
    _stacks.clear();
  }
}
