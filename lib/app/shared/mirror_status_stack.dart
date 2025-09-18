import 'package:catmovie/shared/manage.dart';
import 'package:xi/xi.dart';

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
    List<SourceMeta> data = _datas.map((e) {
      bool status = e.meta.status;
      String id = e.meta.id;
      bool? bStatus = getStack(id);
      if (bStatus != null) {
        status = bStatus;
      }
      return SourceMeta(
        id: id,
        name: e.meta.name,
        type: e.meta.type,
        api: e.meta.api,
        logo: e.meta.logo,
        desc: e.meta.desc,
        isNsfw: e.meta.isNsfw,
        status: status,
        extra: e.meta.extra,
      );
    }).toList();
    SpiderManage.mergeSpiderFromMeta(data);
  }

  void clean() {
    _stacks.clear();
  }
}
