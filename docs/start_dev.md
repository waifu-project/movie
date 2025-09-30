# Re: 环境安装
下载并安装 `Flutter SDK`, 国内用户请去: https://flutter.cn/

> 为避免版本问题, 请下载 (3.35.1) 版本 :)

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
flutter pub run build_runner build
# brew install cocoapods
flutter run
# chmod u+x JS/sync
./JS/sync
pushd packages/xi/lib/adapters/templates
bun install && bun run build
popd
```

# PR: 贡献源(代码)

> 要制作源的话请先右转看看[源制作](./create_source.md)