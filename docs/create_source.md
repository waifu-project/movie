# 源制作指南

> [!NOTE]
> 该文档仅适用于 `>=2.6.0` 版本

小猫影视支持两种视频源类型，让你可以轻松接入各种影视资源：

- **maccms**: 苹果 CMS 源（兼容 XML/JSON 格式）
- **JS**: JavaScript 扩展源（自定义实现）

## 配置格式

下面是一个完整的源配置示例:

```jsonc
// 简单数组
[
  {/* Iconfig */
    "id": "$UUID", // 唯一标识(不能重复)
    "name": "d1y@的影视站", // 名称
    "type": 0, // 源类型(0: maccms, 1: JS/universal)
    "logo": "", // 图标 URL
    "desc": "", // 源介绍
    "nsfw": false, // 是否为 NSFW 内容
    "status": true, // 源状态(true: 启用, false: 禁用)
    "api": "", // API 地址
    "extra": { // 额外配置
      // ========== 通用配置 ==========
      "jiexiUrl": "", // 视频解析接口 URL (可选，功能待完善)
      "gfw": false, // 是否需要代理访问 (可选)
      "searchLimit": 20, // 搜索结果每页数量 (可选，maccms默认20，JS默认10)
      // ========== maccms 源配置特有分类 (type=0) ==========
      "category": "", // 分类 ID 或名称 (可选，用于筛选特定分类)
      // ========== JS 源配置 (type=1) ==========
      "js": {
        "category": "$JS函数名 | 真实的分类数组", // 分类函数或数组
        "home": "$JS函数名", // 首页函数
        "search": "$JS函数名", // 搜索函数
        "detail": "$JS函数名", // 详情函数
        "parseIframe": "$JS函数名" // 解析iframe函数(可选)
      },
      // ========== 模板配置 (可选) ==========
      "template": "template_id", // 使用预定义的模板 ID(目前只有t4)
      // ========== 视频嗅探配置 (可选) ==========
      // 当 parseIframe 未实现时自动启用
      "sniffer": {
        "mode": 0, // 嗅探模式: 0=返回第一个URL, 1=返回所有URL
        "timeout": 10000, // 超时时间(毫秒)
        "customRegex": "", // 自定义正则表达式(可选)
        "exclude": "", // 排除规则(可选)
        "script": "", // 页面加载后执行的JS脚本(可选)
        "initScript": "" // 页面初始化时执行的JS脚本(可选)
      }
    }
  }
]

// 复杂对象
{
  "sites": [], /* Array<Iconfig> */
  "data": [],  /* Array<Iconfig> */
  "lives": [], /* Array<ILiveItem> */
}
```

### 配置参数速查表

#### 基础字段（所有源通用）

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| `id` | string | ✅ | - | 唯一标识，不能重复 |
| `name` | string | ✅ | - | 源名称 |
| `type` | int | ✅ | 0 | 源类型：0=maccms, 1=JS |
| `api` | string | ✅ | - | API 地址 |
| `logo` | string | ❌ | "" | 图标 URL |
| `desc` | string | ❌ | "" | 源介绍 |
| `nsfw` | bool | ❌ | false | 是否为 NSFW 内容 |
| `status` | bool | ❌ | true | 是否启用 |

#### extra 字段（可选配置）

| 参数 | 类型 | 适用源 | 默认值 | 说明 |
|------|------|--------|--------|------|
| `jiexiUrl` | string | 全部 | "" | 视频解析接口 URL |
| `gfw` | bool | 全部 | false | 是否需要代理访问 |
| `searchLimit` | int | 全部 | 20/10 | 搜索结果每页数量 |
| `category` | string | maccms | - | 筛选特定分类 |
| `template` | string | JS | - | 使用预定义模板 |
| `js` | object | JS | - | JS 函数配置 |
| `sniffer` | object | 全部 | - | 视频嗅探配置 |

#### TV 直播源配置包含以下字段：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `name` | string | ✅ | 频道名称（如：CCTV1、湖南卫视） |
| `url` | string | ✅ | 直播流地址（支持 m3u、txt 等格式） |
| `type` | int | ✅ | 类型标识：0=m3u 格式，1=txt 格式 |


### 如何使用配置文件

将配置文件上传到可访问的静态资源网站（如 GitHub Pages、Vercel 等），然后在小猫影视中打开「视频源管理」，添加配置文件的 URL 地址即可。

<img src="https://s2.loli.net/2025/10/24/gvdox1l3uQKipIB.png" width="320" />

**使用订阅协议**

小猫影视支持订阅协议 `xm://sub?url=<配置文件URL>`，用户点击链接即可自动添加源。例如：

```bash
xm://sub?url=https://example.com/source.json
```

### URL 加密规则（可选）

为了保护源地址或简化配置，小猫影视支持对 URL 进行 Base64 加密。

#### 加密格式

所有加密的 URL 必须以 `b` 开头，后跟 Base64 编码的内容：

```
b<base64_encoded_content>
```

#### 支持的加密类型

**1. 普通 URL 加密**

直接对完整的 URL 进行 Base64 编码：

```javascript
// 原始 URL
https://example.com/api/data.json

// 加密后（b + base64）
baHR0cHM6Ly9leGFtcGxlLmNvbS9hcGkvZGF0YS5qc29u
```

**2. GitHub 规则加密**

对于托管在 GitHub 的配置文件，可以使用简化的 GitHub 规则：

**格式：** `g<user>/<repo>#<branch>/<path>`

- `g`: GitHub 规则标识符
- `<user>`: GitHub 用户名
- `<repo>`: 仓库名
- `#<branch>`: 分支名（可选，默认为 `main`）
- `<path>`: 文件路径（支持多级目录）

**示例：**

```javascript
// GitHub 规则（指定分支）
gd1y/kitty#gh-pages/output/result.json

// 转换为
https://raw.githubusercontent.com/d1y/kitty/gh-pages/output/result.json

// 加密后
bZ2QxeS9raXR0eSNnaC1wYWdlcy9vdXRwdXQvcmVzdWx0Lmpzb24=
```

```javascript
// GitHub 规则（默认分支）
gd1y/kitty/data/source.json

// 转换为
https://raw.githubusercontent.com/d1y/kitty/main/data/source.json

// 加密后
bZ2QxeS9raXR0eS9kYXRhL3NvdXJjZS5qc29u
```

## 苹果源（maccms）

小猫影视完整支持苹果 CMS 的资源接口，兼容 XML 和 JSON 两种格式。

### 如何找到苹果源

1. 搜索「资源采集站」关键词，可以找到很多资源站列表
   - 参考：https://14ysdg.com/archives/82

2. 找到类似这样的 API 地址：`http://help.apibdzy.com`

   <img src="https://i.loli.net/2021/11/15/AwfBn2yzMRXdTm6.png" width="240" />

3. 访问 API 地址，检查返回的数据格式
   - 确认返回的是 `xml` 或 `json` 格式
   - 能看到影视数据结构就说明可用

   <img src="https://i.loli.net/2021/11/15/j6UEP7AnIwJMV5Y.png" width="240" />

### 创建苹果源配置

找到可用的 API 后，按照下面的格式创建配置文件：

#### 基础配置

```json
[
  {
    "id": "$UUID",
    "name": "百度资源",
    "type": 0,
    "logo": "",
    "nsfw": false,
    "api": "https://cj.apibdzy.com/inc/api.php"
  }
]
```

#### 高级配置

如果需要更多控制，可以使用 `extra` 字段：

```json
[
  {
    "id": "$UUID",
    "name": "百度资源",
    "type": 0,
    "logo": "",
    "nsfw": false,
    "api": "https://cj.apibdzy.com/inc/api.php",
    "extra": {
      "category": "[]",  // 使用静态分类
      "gfw": false,  // 是否需要代理访问
      "sniffer": {} // 视频嗅探配置
    }
  }
]
```

---

## JS 扩展源

JS 扩展源让你可以自定义数据源的实现逻辑，适合接入各种非标准的影视网站。

### 开发工具

小猫影视提供了完整的开发工具链（位于 `JS/` 目录）：

- **cli**: 命令行工具，用于将你的实现导出为配置文件
- **types**: TypeScript 类型定义，提供完整的接口规范

### JS 运行环境与 Polyfill

小猫影视的 JS 源运行在 Flutter JS 引擎中，为了让你的代码能够正常运行，我们提供了完整的 polyfill 支持：

#### 已内置的 Polyfill

**基础 API**（`js_polyfill.dart`）：
- ~~`FormData`: 表单数据处理~~
- `URLSearchParams`: URL 参数解析
- `URL`: URL 对象（部分支持）
- `dayjs`: 日期时间处理库

**编码函数**（`polyfill.js`）：
- `btoa` / `atob`: Base64 编码/解码
- `encodeURI` / `decodeURI`: URI 编码/解码
- `encodeURIComponent` / `decodeURIComponent`: URI 组件编码/解码
- `escape` / `unescape`: 字符串转义（已废弃但仍可用）
- `TextEncoder` / `TextDecoder`: 文本编码器

**DOM API**（`dom_polyfill.js`）⚠️ **仅为模拟环境**：
- `window` / `document`: 基础 DOM 对象（模拟）
- `Element` / `Node`: DOM 元素和节点（模拟）
- `Event` / `EventTarget`: 事件系统（模拟）
- `XMLHttpRequest`: HTTP 请求（模拟，不会真实发送请求）
- `localStorage` / `sessionStorage`: 本地存储（内存模拟）
- `navigator` / `location` / `history`: 浏览器对象（模拟）

#### 使用示例

```javascript
export default class MySource implements Handle {
  async getHome() {
    // 使用 Base64 编码
    const encoded = btoa('小猫影视');
    const decoded = atob(encoded);
    
    // 使用 URL 编码
    const url = encodeURIComponent('https://example.com/搜索');
    
    // 使用 dayjs 处理日期
    const now = dayjs().format('YYYY-MM-DD');
    
    // 使用 URLSearchParams
    const params = new URLSearchParams('page=1&limit=20');
    const page = params.get('page');
    
    return [];
  }
}
```

#### 注意事项

⚠️ **环境限制**：
- JS 引擎不是完整的浏览器环境，某些浏览器特有的 API 可能不可用
- **DOM polyfill 是纯内存模拟**，不会产生真实的 DOM 渲染或副作用
- DOM API 主要用于让依赖 DOM 的第三方库能够加载，**不要依赖 DOM 操作来实现业务逻辑**

💡 **最佳实践**：
- 优先使用标准 JavaScript API（如 `JSON.parse`、`Array.map` 等）
- 需要网络请求时，使用小猫影视提供的 HTTP 工具

### 快速开始

#### 1. 创建项目

```bash
npm init -y
```

#### 2. 安装依赖

```diff
+    "@types/kitty": "https://gitpkg.vercel.app/waifu-project/movie/JS/types?dev",
+    "kitty": "https://gitpkg.vercel.app/waifu-project/movie/JS/cli?dev",
```

#### 3. 实现源逻辑

创建 `demo.ts` 文件，实现 `Handle` 接口：

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

#### 4. 生成配置文件

使用命令行工具导出配置：

```bash
# 查看帮助
bunx kitty-parse --help

# 生成配置文件
bunx kitty-parse -o result.json
```

**命令选项说明：**
- `-o, --output <file>`: 指定输出文件（默认：result.json）
- `-d, --directory <dir>`: 指定扫描目录
- `-v, --verbose`: 显示详细输出
- `-h, --help`: 显示帮助信息

### JS 源高级配置

#### 完整配置示例

```json
{
  "id": "advanced-source",
  "name": "高级 JS 源",
  "type": 1,
  "api": "https://example.com",
  "status": true,
  "extra": {
    // "template": "t4",
    "js": {
      "category": "getCategory",
      "home": "getHome",
      "search": "getSearch",
      "detail": "getDetail",
      "parseIframe": "parseIframe"
    },
    "searchLimit": 15,
    "gfw": true,  // 需要代理访问
    "sniffer": {
      "timeout": 20000,
      "customRegex": "https?://cdn\\.example\\.com/.*\\.(m3u8|mp4)"
    }
  }
}
```

### 参考资源

- **完整类型定义**: [index.d.ts](../JS/types/index.d.ts)
- **示例项目**: https://github.com/d1y/kitty

---

## 视频嗅探功能

> 感谢道长 (@hjdhnx) 的原创实现：https://github.com/hjdhnx/pup-sniffer

### 什么是视频嗅探

视频嗅探是一个智能功能，可以自动从网页中提取真实的视频播放地址。当你遇到无法直接播放的视频链接时，嗅探功能会帮你找到可播放的视频资源。

### 自动触发条件

当满足以下条件时，小猫影视会自动启动视频嗅探：

1. 在 `getDetail()` 或 `getHome()` 中，视频链接被标记为 `iframe` 类型
   - 例如：`{ text: '第一集', id: '$iframe_url' }`
2. 源配置中没有实现 `parseIframe` 方法

### 嗅探配置参数

你可以在源配置的 `extra.sniffer` 中自定义嗅探行为：

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `mode` | int | 0 | 嗅探模式：0=返回第一个匹配的URL，1=返回所有匹配的URL |
| `timeout` | int | 10000 | 超时时间（毫秒） |
| `customRegex` | string | - | 自定义正则表达式，用于匹配特定格式的媒体 URL |
| `exclude` | string | - | 排除规则，匹配的 URL 将被忽略（支持正则） |
| `script` | string | - | 页面加载完成后执行的 JavaScript 脚本 |
| `initScript` | string | - | 页面初始化时执行的 JavaScript 脚本 |

**配置示例：**

```json
{
  "extra": {
    "sniffer": {
      "mode": 0,
      "timeout": 15000,
      "customRegex": "https?://cdn\\.example\\.com/.*\\.(m3u8|mp4)",
      "exclude": "ads\\.example\\.com|tracker\\.example\\.com",
      "script": "document.querySelector('video')?.play();"
    }
  }
}
```

### 常见问题

#### Q: 为什么嗅探不到视频？

可能的原因：
- 网页使用了加密或混淆技术
- 视频需要登录或付费才能观看
- 网站使用了特殊的播放器技术
- 网络连接不稳定或被限制

#### Q: 嗅探到的视频无法播放？

可能的原因：
- 视频链接有时效性限制，已过期
- 视频有防盗链保护（需要特定 Referer）
- 视频格式不被当前播放器支持
- 缺少必要的请求头（User-Agent 等）