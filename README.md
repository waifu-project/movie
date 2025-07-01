<img src="design/logo_round.svg" width="120" />

## 小猫影视

自带线路的轻量级播放器🧌

使用 `Flutter` 构建, 支持 `Android` | `Windows` | `Macos` | `iOS` | `Linux`

![](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)
![](https://img.shields.io/badge/iOS-000000?style=flat&logoColor=white)
![](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![](https://img.shields.io/badge/Windows-0078D6?style=flat&logo=windows&logoColor=white)
![](https://img.shields.io/badge/Android-3DDC84?style=flat&logo=android&logoColor=white)

官方源参考: https://github.com/waifu-project/movie/issues/45
> 也支持自定义源, 可自行添加源, 参考: [源制作.md](./docs//源制作.md)

<img src="https://github.com/user-attachments/assets/cc99ceca-bc11-4fcd-84d6-16b07d155c5a" width="420" />

### 安装

#### **Macos**

`macOS` 可以使用 [Homebrew](https://brew.sh) 快速安装, 也可自行下载安装

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/catmovie-mac.zip
)

> 更新的话可直接使用 `brew reinstall yoyo`

```bash
brew tap waifu-project/brew
brew install yoyo
```

#### **Linux**

Linux 下打包的二进制相对于其他平台会大 `15mb`, 由于在不同Linux(桌面)系统上字体渲染太糊([#32](https://github.com/waifu-project/movie/issues/32)), 所以直接内置了一个 `CJK` 字体([LXGWWenKai](https://github.com/lxgw/LxgwWenKai))

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/catmovie-linux-x86_64.tar.gz)

Archlinux 需要安装两个包

```sh
yay -S webkit2gtk-4.1
yay -S xdg-user-dir xdg-utils
```

#### **Windows**

> FIXME: Windows现在无法运行

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/catmovie-windows.zip)

#### **Android**

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/catmovie.apk)

#### **iOS**

自签的话建议使用:

- [Sideloadly](https://sideloadly.io)
- [TrollStore](https://github.com/opa334/TrollStore)
- [NB助手(推荐)](https://nbtool8.com) 签名安装

> [!NOTE]
> 巨魔一键安装链接🔗:
> 
> apple-magnifier://install?url=https://github.com/waifu-project/movie/releases/latest/download/catmovie.ipa

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/catmovie.ipa)

## 提示🥳

### 桌面端有键盘快捷键吗?

有啊, 参见 [docs/keyboard.md](./docs/keyboard.md)

### 怎么样获得最好的使用(播放)体验?

> 目前不打算在播放体验上花功夫, 大部分的逻辑会走系统 `webview`

- `macOS` 推荐使用 [IINA](https://iina.io) 来播放视频
- `iOS` 推荐使用内置浏览器来播放视频