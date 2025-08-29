<img src="design/logo_round.svg" width="120" />

## 小猫影视 🐈

使用 `Flutter` 构建, 支持 `Android` | `Windows` | `Macos` | `iOS` | `Linux`

![](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)
![](https://img.shields.io/badge/iOS-000000?style=flat&logoColor=white)
![](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![](https://img.shields.io/badge/Windows-0078D6?style=flat&logo=windows&logoColor=white)
![](https://img.shields.io/badge/Android-3DDC84?style=flat&logo=android&logoColor=white)

**仅供学习参考, 请勿用于商业用途**

<!-- <img src="https://s2.loli.net/2025/08/12/dN78kJ1pAwqHYVZ.webp" width="120" /> -->

<details>
<summary>查看截图 🖼️</summary>

![首页](https://s2.loli.net/2025/08/04/1qJ72QC9ioxRjkZ.jpg)
![搜索](https://s2.loli.net/2025/08/04/VNZtikObdxhnRLf.jpg)
![TV](https://s2.loli.net/2025/08/04/XUZ18fmzEwiPoR3.jpg)
![播放.jpg](https://s2.loli.net/2025/08/29/PghkRipeYQDfC2U.png)

</details>

### 安装指南 📦

#### **Macos 🍎**

`macOS` 可以使用 [homebrew](https://brew.sh) 快速安装, 也可自行下载安装

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/catmovie-mac.zip
)

> 更新的话可直接使用 `brew reinstall -f yoyo`

```bash
brew tap waifu-project/brew
brew install yoyo
```

#### **Linux 🐧**

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/catmovie-linux-x86_64.tar.gz)

在 `Archlinux` 需要安装两个包

```sh
yay -S webkit2gtk-4.1
yay -S xdg-user-dir xdg-utils
```

#### **Windows 🪟**

在 `Win10` 下, 如果使用 `Webview` 播放器内核, 需要额外安装 [WebView2 Runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2)

> https://docs.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/catmovie-windows.zip)

#### **Android 🤖**

安卓没有正式测试过, 如果有问题记得提 [issue](https://github.com/waifu-project/movie/issues)

> [!NOTE]
> 安卓建议直接将播放器内核切换到 `MediaKit`

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/catmovie.apk)

#### **iOS 📱**

自签的话建议使用:

- [Sideloadly](https://sideloadly.io)
- [TrollStore](https://github.com/opa334/TrollStore)
- [NB助手](https://nbtool8.com)

> [!NOTE]
> apple-magnifier://install?url=https://github.com/waifu-project/movie/releases/latest/download/catmovie.ipa

[![](https://img.shields.io/badge/-点我下载-blue?logo=github)](https://github.com/waifu-project/movie/releases/latest/download/catmovie.ipa)

### 文档 📜

- [制作源](./docs/create_source.md)
- [键盘快捷键](./docs/keyboard.md) 
- [解析VIP视频](./docs/parse_vip.md)
- [URL Scheme](./docs/protocol.md)
- [贡献代码](./docs/PR.md)
- [调试代码](./docs/start_dev.md)