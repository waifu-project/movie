# 制作规则

`YY`实现了通用的制作规则如下

```jsonc
{
  "name": "小不点の资源库", // 名称
  "logo": "", // 图标
  "desc": "", // 介绍
  "nsfw": true, // ********
  "api": {
    "root": "http://baidu.com", // 域名
    "path": "/xx/xx.php" // api 路径
  }
}
```

理论上来说支持 `ZY-Player` 的源

去网上搜索 `资源采集站` 会找到: https://14ysdg.com/archives/82

找到这种类型网址: http://help.apibdzy.com

![WX20211115-163850.png](https://i.loli.net/2021/11/15/AwfBn2yzMRXdTm6.png)

访问该接口查看源码, 注意如果返回的是 `xml` 就对了 :)

![WX20211115-164255.png](https://i.loli.net/2021/11/15/j6UEP7AnIwJMV5Y.png)

然后依葫芦画瓢编写一个配置文件

```json
[
  {
  "name": "百度资源",
  "logo": "",
  "desc": "",
  "nsfw": false,
  "api": {
    "root": " https://cj.apibdzy.com",
    "path": "/inc/api.php"
  }
}
]
```

然后上传到一个可访问的静态资源网站, 然后将网址添加到视频源管理里添加就可以了