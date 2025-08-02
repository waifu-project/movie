// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class X {
  String? name;
  bool? nsfw;
  Api? api;
  bool? status;

  X({this.name, this.nsfw, this.api, this.status});

  X.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    nsfw = json['nsfw'];
    api = json['api'] != null ? Api.fromJson(json['api']) : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['nsfw'] = nsfw;
    if (api != null) {
      data['api'] = api!.toJson();
    }
    data['status'] = status;
    return data;
  }
}

class Api {
  String? root;
  String? path;

  Api({this.root, this.path});

  Api.fromJson(Map<String, dynamic> json) {
    root = json['root'];
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['root'] = root;
    data['path'] = path;
    return data;
  }
}

String space(int size) {
  StringBuffer sb = StringBuffer();
  for (int i = 0; i < size; i++) {
    sb.write(' ');
  }
  return sb.toString();
}

String toDartCode(List<X> sources) {
  String result = '''import 'package:xi/xi.dart';\n
var list\$ = [\n''';
  for (var source in sources) {
    result += '${space(2)}MacCMSSpider(\n';
    result += '${space(4)}name: "${source.name}",\n';
    result += '${space(4)}nsfw: ${source.nsfw ?? false},\n';
    result += '${space(4)}api_path: "${source.api?.path}",\n';
    result += '${space(4)}root_url: "${source.api?.root}",\n';
    result += '${space(4)}id: "${source.name}",\n';
    result += '${space(4)}status: ${source.status ?? true},\n';
    result += '${space(2)}),\n';
  }
  result += '];';
  return result;
}

Future<void> main() async {
  final url = Uri.parse(
    "https://cdn.jsdelivr.net/gh/waifu-project/v1@latest/yoyo.json",
  );
  final resp = await http.get(url);
  if (resp.statusCode != 200) {
    OSError("fetch remote json failed: $url");
    return;
  }
  final List<dynamic> jsonList = json.decode(resp.body);
  final List<X> sources = jsonList
      .map(
        (item) => X.fromJson(item as Map<String, dynamic>),
      )
      .toList();
  var dartCode = toDartCode(sources);
  print(dartCode);
}
