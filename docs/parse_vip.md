# 基础使用

现在支持解析 `爱奇艺`/`优酷` 等视频了, 该功能是为了解决这些官方站点不能播放(vip/广告??)的问题

基本上在 `设置->解析源管理` 添加接口, 当播放时检测到官方站点就会走解析

![](https://files.catbox.moe/sh6i9k.gif)

# 源制作

比如说去Google搜索一下: `vip视频解析` 就有一大堆, 不过我建议去油猴脚本市场选中 [`iqiyi.com`](https://greasyfork.org/zh-CN/scripts/by-site/iqiyi.com) 站点搜索, 这时候就会出现一些脚本, 脚本里就有线路

# 导入

导入只支持 `json` 文件, 支持数组/对象, 格式:

```json
{
  "name": "白嫖线路",
  "url": "https://baidu.com"
}
```