import 'package:movie/impl/movie.dart';
import 'package:movie/mirror/m_utils/m.dart';
import 'package:movie/mirror/mirror.dart';
import 'package:movie/mirror/mlist/base_models/source_data.dart';

class MirrorStatusStack {
  MirrorStatusStack._internal();
  factory MirrorStatusStack() => _instance;
  static late final MirrorStatusStack _instance = MirrorStatusStack._internal();

  Map<String, bool> _stacks = {};

  Map<String, bool> get getStacks => _stacks;

  List<MovieImpl> _datas = MirrorManage.extend;

  bool? getStack(String stack) {
    return _stacks[stack];
  }

  pushStatus(String sourceKey, bool status, {bool canSave = false}) {
    _stacks[sourceKey] = status;
    if (canSave) {
      flash();
    }
  }

  flash() {
    List<SourceJsonData> data = _datas.map((e) {
      bool status = e.meta.status;
      String id = e.meta.id;
      bool? _bStatus = getStack(id);
      if (_bStatus != null) {
        status = _bStatus;
      }
      return SourceJsonData(
        name: e.meta.name,
        logo: e.meta.logo,
        desc: e.meta.desc,
        nsfw: e.isNsfw,
        api: Api(
          root: e.meta.domain,
          path: (e as KBaseMirrorMovie).api_path,
        ),
        id: id,
        status: status,
      );
    }).toList();
    MirrorManage.mergeMirror(data);
  }

  clean() {
    _stacks.clear();
  }
}
