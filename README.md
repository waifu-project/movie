<div align="center" style="display: flex">
  <img src="design/logo_round.png" width="120">
</div>

## 小猫影视

支持自定义源的轻量级视频播放器

使用 `Flutter` 构建, 支持 `Android` | `Windows` | `Macos` | `iOS` | `Linux`(浅浅的画个饼O(∩_∩)O)

![](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)
![](https://img.shields.io/badge/iOS-000000?style=flat&logoColor=white)
![](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![](https://img.shields.io/badge/Windows-0078D6?style=flat&logo=windows&logoColor=white)
![](https://img.shields.io/badge/Android-3DDC84?style=flat&logo=android&logoColor=white)

支持自定义源, 可自行添加源, 官方源参考: https://github.com/waifu-project/movie/issues/45

### 安装

#### **Macos**

`macos` 可以使用 [Homebrew](https://brew.sh) 快速安装, 也可自行下载安装

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/yoyo.mac.zip)

> PS: 由于暂时没有"版本"这个概念, 所以安装之后更新的话可直接使用 `brew reinstall yoyo`

```bash
brew tap waifu-project/brew
brew install yoyo
```

#### **Linux**

Linux 下打包的二进制相对于其他平台会大 `15mb`, 由于在不同Linux(桌面)系统上字体渲染太糊([#32](https://github.com/waifu-project/movie/issues/32)), 所以直接内置了一个 `CJK` 字体([LXGWWenKai](https://github.com/lxgw/LxgwWenKai))

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/yy-linux-x86_64.tar.gz)

Archlinux 需要安装两个包

```sh
# TODO: 支持打包出 `appimage`
# TODO: 支持 `AUR(archlinux)` 安装
yay -S webkit2gtk-4.1
yay -S xdg-user-dir xdg-utils
```

#### **Windows**

没有测试过应该没问题吧?(有问题记得提`issues`)

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/yy-windows.zip)

#### **Android**

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/app-release.apk)

<!-- 通用(用这个就对了~):  -->

<!--
arm64-v8a架构: [![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/app-arm64-v8a-release.apk)

armeabi-v7a架构: [![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/app-armeabi-v7a-release.apk)

x86_64架构: [![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/app-x86_64-release.apk)
-->

#### **iOS**

`ipa` 需要自签, 可以使用 [sideloadly](https://sideloadly.io) | [TrollStore](https://github.com/opa334/TrollStore) | [NB助手(推荐)](https://nbtool8.com) 签名安装
> 仅支持 iOS 14+ 以上系统

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/yoyo.ipa)

## 截图

<img src="https://github.com/waifu-project/movie/assets/45585937/cf72d526-6643-4040-a265-41c8a5bcf2da" width="420" />
<img src="https://github.com/waifu-project/movie/assets/45585937/f5f0ee2e-dfeb-44cd-9701-ac7c7bdf3584" width="420" />
<img src="https://github.com/waifu-project/movie/assets/45585937/7caddd08-bc0a-4d7d-a433-147b20ab248a" width="420" />


## 小提示🥳

### 为什么我的 nsfw🔞 源没有显示?

因为默认禁用了啊, 你需要手动开启

需要在设置中点击版本号10次, 然后开启 nsfw 即可(答案是 [2/3](https://github.com/waifu-project/movie/blob/schema/lib/app/modules/home/views/nsfwtable.dart#L11-L14))

或者可以使用: yoyo://nsfw?enable=1 开启

> 我们注册了一个 yoyo:// 协议, 参见 [docs/protocol.md](./docs/protocol.md)

### 桌面端有键盘快捷键吗?

有啊, 参见 [docs/keyboard.md](./docs/keyboard.md)

### 没有源怎么办?

默认支持导入 `zy-player` 源,可去下载源之后导入(设置->视频源帮助->导入)

<img width="240" alt="image" src="https://github.com/waifu-project/movie/assets/45585937/7c34fa56-a182-4640-a5df-c85c60e979ce">


### 怎么样获得最好的使用(播放)体验?

> 目前不打算在播放体验上花功夫, 大部分的逻辑会走系统 `webview`

`macOS` 推荐使用 [IINA](https://iina.io) 来播放视频

`iOS` 推荐使用内置浏览器来播放视频

<img width="240" src="https://files.catbox.moe/fzqpps.png" />

### copyright

图片素材来自:

- [花开荼靡心事未了](https://www.iconfont.cn/user/detail?spm=a313x.7781069.0.d214f71f6&uid=184365&nid=uWAFTqbAJ8hx)

- [Rahul](https://www.iconfont.cn/user/detail?uid=472001&nid=WYOADQZTMZeR)

- [菲崎爷爷](https://www.iconfont.cn/illustrations/detail?spm=a313x.7781069.1998910419.d9df05512&cid=36701)

- [chuncui199188](https://www.iconfont.cn/illustrations/detail?spm=a313x.7781069.1998910419.d9df05512&cid=24522)

- [九月红前来求药](https://www.iconfont.cn/user/detail?spm=a313x.7781069.0.d214f71f6&uid=4919826&nid=5Z6XDuRro8Q4)


**仅供学习参考**
