# 源制作

小猫影视中有两种源类型

- maccms: 苹果源
- JS: JS扩展源

配置示例:

```jsonc
{
  "id": "$UUID", // 唯一标识(不能重复)
  "name": "d1y@的影视站", // 名称
  "type": 0, // 源类型(0: maccms, 1: JS)
  "logo": "", // 图标
  "desc": "", // 源介绍
  "nsfw": false, // 是否为色情源
  "api": "", // 源地址(JS为 baseUrl 环境变量)
  "extra": { // 额外配置(type=1必填)
    "js": {
      "category": "$JS函数名 | 真实的分类数组", // 分类函数
      "home": "$JS函数名", // 首页函数
      "search": "$JS函数名", // 搜索函数
      "detail": "$JS函数名", // 详情函数
      "parseIframe": "$JS函数名" // 解析iframe函数
    },
    "jiexiUrl": "" // TODO: 这部分功能实现不完善
  }
}
```

配置文件需要上传到一个可访问的静态资源网站, 然后将网址添加到 `视频源管理` 就可以了 :)

<img src="https://s2.loli.net/2025/09/23/ADKMEhG5oHkvbnV.png" width="320" />

## 苹果源

小猫影视完善的实现了苹果CMS的源(XML/JSON都支持)

可以去网上搜索 `资源采集站` 会找到: https://14ysdg.com/archives/82

找到这种类型网址: http://help.apibdzy.com

<img src="https://i.loli.net/2021/11/15/AwfBn2yzMRXdTm6.png" width="240" />

访问该接口查看源码, 注意如果返回的是 `xml` | `json` 就对了 :)

<img src="https://i.loli.net/2021/11/15/j6UEP7AnIwJMV5Y.png" width="240" />

然后依葫芦画瓢编写一个配置文件

```json
[
  {
    "id": "$UUID",
    "name": "百度资源",
    "logo": "",
    "nsfw": false,
    "api": "https://cj.apibdzy.com/inc/api.php"
  }
]
```

## JS源

编写源依赖于 `JS/` 中工具链

- cli: 命令行工具, 可用将实现的 `Handle` 导出为配置文件
- types: 类型定义, 实现这里的 `Handle` 就行了

首先创建一个项目

```
npm init -y
```

之后添加两个依赖:

```diff
+    "@types/kitty": "https://gitpkg.vercel.app/waifu-project/movie/JS/types?dev",
+    "kitty": "https://gitpkg.vercel.app/waifu-project/movie/JS/cli?dev",
```

然后创建一个目录, 在里面创建 `demo.ts` 文件

```ts
export default class Demo implements Handle {
  getConfig() {
    return <Iconfig>{
      id: 'demo',
      name: 'JS引擎配置',
      api: "https://d1y.movie",
      nsfw: false,
      type: 1
    }
  }
  async getCategory() {
    // TODO: impl this
    return [
      { text: '电影', id: "1" },
      { text: '电视剧', id: "2" },
      { text: '综艺', id: "3" },
      { text: '动漫', id: "4" },
    ]
  }
  async getHome() {
    // TODO: impl this
    return <IMovie[]>[]
  }
  async getDetail() {
    // TODO: impl this
    return <IMovie>{ id, cover, title, remark, desc, playlist }
  }
  async getSearch() {
    // TODO: impl this
    return <IMovie[]>[]
  }
  async parseIframe() {
    // TODO: impl this
    return ""
  }
}
```

之后直接运行

```bash
# ❯ bunx kitty-parse --help   
# Usage: kitty-parse [options]
# 
# Parse TypeScript files and extract configurations
# 
# Options:
#   -V, --version          output the version number
#   -o, --output <file>    output JSON file (default: "result.json")
#   -d, --directory <dir>  directory to scan (default: "/Users/shiwanbaqianmeng/code/github/kitty")
#   -v, --verbose          verbose output (default: false)
#   -h, --help             display help for command
bunx kitty-parse -o result.json
```

示例项目: https://github.com/d1y/kitty