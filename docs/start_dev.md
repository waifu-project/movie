# Re: 环境安装
下载并安装 `Flutter SDK`, 国内用户请去: https://flutter.cn/

> 为避免版本问题, 请下载 (3.10.3) 版本 :)

建议国内用户设置这两个环境变量

```sh
export FLUTTER_STORAGE_BASE_URL="https://mirrors.tuna.tsinghua.edu.cn/flutter"
export PUB_HOSTED_URL="https://mirrors.tuna.tsinghua.edu.cn/dart-pub"
```

之后

```sh
git clone https://github.com/waifu-project/movie
cd movie
bash script/fetch_git_info.sh
flutter pub get .
flutter run
```

# PR: 贡献源(代码)

> 要制作源的话请先右转看看[源制作](./源制作.md)

TODO