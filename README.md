<img src="design/logo_round.png" align="right" width="180">


## yoyo

[![yyrelease](https://github.com/waifu-project/movie/actions/workflows/release.yml/badge.svg)](https://github.com/waifu-project/movie/actions/workflows/release.yml)

使用 `Flutter` 构建, 支持 `Android` | `Windows` | `Macos` | `Linux`(浅浅的画个饼O(∩_∩)O)

![](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=apple&logoColor=white)
![](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)
![](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

支持自定义源, 可自行添加源
<!-- 欢迎加入TG裙交流(有源分享): https://t.me/+xub6INGSHqczN2Jl -->

<!-- [Re: 从零开始的开发日志](docs/dev.md)

[Re: 视频源制作](docs/源制作.md)

[Re: 视频解析](docs/解析.md) -->

### 安装

#### **Macos**

`macos` 可以使用 [homebrew](https://brew.sh) 快速安装, 也可自行下载安装

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/yoyo.mac.zip)

> PS: 由于暂时没有"版本"这个概念, 所以安装之后更新的话可直接使用 `brew reinstall yoyo`

```bash
brew tap waifu-project/brew
brew install yoyo
```

#### **Linux**

Linux 下打包的二进制相对于其他平台会大 `15mb`, 由于在不同Linux(桌面)系统上字体渲染太糊(#32), 所以直接内置了一个 `CJK` 字体([LXGWWenKai](https://github.com/lxgw/LxgwWenKai))

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/yy-linux-x86_64.tar.gz)

Archlinux 需要安装两个包

```bash
yay -S webkit2gtk-4.1
yay -S xdg-user-dir xdg-utils
```

TODO: 支持打包出 `appimage`

TODO: 支持 `AUR(archlinux)` 安装

#### **Windows**

没有测试过应该没问题吧?(有问题记得提`issues`)

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/yy-windows.zip)

#### **Android**

通用(用这个就对了~): [![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/app-release.apk)

arm64-v8a架构: [![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/app-arm64-v8a-release.apk)

armeabi-v7a架构: [![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/app-armeabi-v7a-release.apk)

x86_64架构: [![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/app-x86_64-release.apk)


#### **iOS**

`iOS` 下载 `ipa` 之后, 可以使用 [sideloadly](https://sideloadly.io/) | [TrollStore(推荐)](https://github.com/opa334/TrollStore) (签名)安装

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/app.ipa)

[![image](https://user-images.githubusercontent.com/45585937/197248782-f173db3f-401f-4e15-b5ab-92d7928475ec.png)](https://sideloadly.io/)
[![image](https://user-images.githubusercontent.com/45585937/197247561-0a60dbd6-1c91-4c22-a008-189819145e24.png)](https://github.com/opa334/TrollStore)

> PS: 目前暂不支持 `iOS15+` 以及更高系统

## 截图

<img src="https://s2.loli.net/2023/06/10/U1WZuja7PVfo9sp.png" width="420" />
<img src="https://s2.loli.net/2023/06/10/iX1kdqFBIpamAxj.png" width="420" />
<img src="https://s2.loli.net/2023/06/10/ytAVfTH8RZ7Prem.png" width="420" />


## 小提示🥳

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
