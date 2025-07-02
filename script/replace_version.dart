import 'dart:io';

Future<void> main() async {
  String version = Platform.environment['version'] ?? "";
  if (version.isEmpty) {
    // ignore: avoid_print
    print("real version get failed\n");
    return;
  }
  String realVersion = version.replaceAll("release-v", "");
  File pubspec = File("pubspec.yaml");
  List<String> lines = await pubspec.readAsLines();
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    if (line.startsWith("version:")) {
      lines[i] = "version: $realVersion";
      break;
    }
  }
  pubspec.writeAsStringSync(lines.join("\n"));
}