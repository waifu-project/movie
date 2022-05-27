# Re: 环境安装
下载并安装 `Flutter SDK`, 国内用户请去: https://flutter.cn/

> 为避免版本问题, 请下载 (2.10.4) 版本 :)

建议国内用户设置这两个环境变量

```sh
export FLUTTER_STORAGE_BASE_URL="https://mirrors.tuna.tsinghua.edu.cn/flutter"
export PUB_HOSTED_URL="https://mirrors.tuna.tsinghua.edu.cn/dart-pub"
```

之后

```sh
git clone https://github.com/waifu-project/movie
cd movie
flutter pub get .
cd script
# 自动生成 source_create.html
npm i --save markdown-it
node gen_source_create.js

flutter run
```

# PR: 贡献源(代码)

> 要制作源的话请先右转看看[源制作](./源制作.md)

需要实现一个抽象类 [/lib/impl/movie.dart](/lib/impl/movie.dart)

建议在 [/lib/mirror/mlist](/lib/mirror/mlist) 目录中编写

最后在 [/lib/mirror/mirror.dart](/lib/mirror/mirror.dart) 中的 `builtin` 添加即可

具体可以参考 [ThePorn](/lib/mirror/mlist/theporn.dart) 的实现

```dart
abstract class MovieImpl {
  bool get isNsfw;

  MovieMetaData get meta;

  Future<List<MirrorOnceItemSerialize>> getHome({
    int page = 1,
    int limit = 10,
  });

  Future<List<MirrorOnceItemSerialize>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  });

  Future<MirrorOnceItemSerialize> getDetail(String movie_id);
}
```