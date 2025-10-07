/// <reference types="node"/>

import type { load as cheerioLoad } from 'cheerio'
import type { Dayjs } from 'dayjs'

declare global {
  /**
   * Kitty 全局对象
   * 提供 cheerio 加载器和工具函数
   */
  var kitty: Kitty

  /**
   * 环境变量对象
   * 包含基础 URL 和请求参数
   */
  var env: KittyEnv

  /**
   * HTTP 请求函数
   * 支持多种调用方式
   */
  var req: KittyReq

  //======工具函数====
  /**
   * 时间工具: https://day.js.org
   * 
   * @example
   * ```typescript
   * // 获取当前时间
   * const now = dayjs()
   * 
   * // 格式化时间
   * const formatted = dayjs().format('YYYY-MM-DD HH:mm:ss')
   * 
   * // 解析时间字符串
   * const date = dayjs('2024-01-01')
   * 
   * // 时间计算
   * const tomorrow = dayjs().add(1, 'day')
   * const lastWeek = dayjs().subtract(7, 'day')
   * ```
   */
  var dayjs: {
    (): Dayjs
    (date?: string | number | Date | Dayjs): Dayjs
    (date: string, format: string): Dayjs
  }

  /**
   * 环境变量参数类型
   * 定义了所有可用的参数键
   */
  type KittyEnvParams =
    "category" |  // 分类 ID
    "page" |      // 页码
    "limit" |     // 每页数量
    "movieId" |   // 视频 ID
    "keyword" |   // 搜索关键词
    "iframe"      // iframe URL

  /**
   * 环境变量接口
   * 提供基础 URL 和参数访问
   */
  interface KittyEnv {
    /**
     * 基础 URL
     * @example "https://example.com"
     */
    baseUrl: string

    /**
     * 请求参数对象
     */
    params: Record<KittyEnvParams, any>

    /**
     * 获取参数值
     * @param key 参数键
     * @param defaultValue 默认值
     * @returns 参数值或默认值
     * @example
     * ```typescript
     * const page = env.get("page", 1)
     * const category = env.get("category", "all")
     * ```
     */
    get<T>(key: KittyEnvParams, defaultValue?: T): T
  }

  /**
   * Kitty 工具函数接口
   */
  interface KittyUtils {
    /**
     * 从 iframe URL 获取 m3u8 链接
     * 
     * 使用方法：
     * ```typescript
     * const url = `${env.baseUrl}${env.get("iframe")}`
     * const m3u8 = await kitty.utils.getM3u8WithIframe(env)
     * ```
     * 
     * @param env 环境变量对象
     * @returns m3u8 链接
     */
    getM3u8WithIframe(env: KittyEnv): Promise<string>

    /**
     * 从 HTML 字符串中提取 m3u8 链接
     * 
     * 适用于包含视频播放器配置的 HTML：
     * ```html
     * <script>
     *   var player_aaaa = {
     *     data: [],
     *     "url": "http://example.com/video.m3u8"
     *   }
     * </script>
     * ```
     * 
     * @param str HTML 字符串
     * @returns m3u8 链接
     */
    getM3u8WithStr(str: string): string
  }

  /**
   * Kitty 主接口
   * 提供 cheerio 和工具函数
   */
  interface Kitty {
    /**
     * cheerio 加载器
     * 用于解析和操作 HTML
     * @example
     * ```typescript
     * const $ = kitty.load(html)
     * const title = $('h1').text()
     * ```
     */
    load: typeof cheerioLoad

    /**
     * 工具函数集合
     */
    utils: KittyUtils

    /**
     * 小猫当前版本号
     */
    VERSION: string

    /**
     * 版本比较(https://semver.org) >=
     */
    version_compare(old: string, _new: string): Promise<boolean>

    /**
     * 生成MD5值
     * @param str 字符串
     * @returns MD5 值
     * 
     * @example
     * ```typescript
     * const md5 = await kitty.md5("hello")
     * ```
     *
     */
    md5(str: string): Promise<string>

    [key: string]: any
  }

  /**
   * HTTP 请求选项
   */
  interface KittyRequestOptions {
    /**
     * 请求 URL
     * @example "https://example.com/api"
     */
    url?: string

    /**
     * HTTP 方法
     * @default "GET"
     */
    method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH' | 'HEAD' | 'OPTIONS'

    /**
     * 请求头
     * @example
     * ```typescript
     * {
     *   "User-Agent": "Mozilla/5.0...",
     *   "Referer": "https://example.com"
     * }
     * ```
     */
    headers?: Record<string, string>

    /**
     * URL 查询参数
     * @example
     * ```typescript
     * {
     *   page: 1,
     *   limit: 10
     * }
     * ```
     */
    params?: Record<string, any>

    /**
     * 请求体类型
     * - json: application/json
     * - form: application/x-www-form-urlencoded
     * @default "json"
     */
    bodyType?: 'json' | 'form'

    /**
     * 是否禁用缓存
     * 
     * 小猫默认会缓存请求结果。
     * 当 URL 相同但参数不同时，需要设置为 true
     * 
     * @default false
     * @example
     * ```typescript
     * // 禁用缓存
     * await req("https://api.example.com", { noCache: true })
     * ```
     */
    noCache?: boolean

    /**
     * 请求体数据
     */
    data?: any
  }

  /**
   * HTTP 请求函数
   * 
   * 支持三种调用方式：
   * 1. req(url) - 简单 GET 请求
   * 2. req(url, options) - 带选项的请求
   * 3. req(options) - 完整配置请求
   * 
   * @example
   * ```typescript
   * // 方式 1: 简单 GET 请求
   * const html = await req("https://example.com")
   * 
   * // 方式 2: 带选项的请求
   * const data = await req("https://api.example.com", {
   *   method: "POST",
   *   data: { key: "value" }
   * })
   * 
   * // 方式 3: 完整配置
   * const result = await req({
   *   url: "https://api.example.com",
   *   method: "POST",
   *   headers: { "Content-Type": "application/json" },
   *   data: { key: "value" }
   * })
   * ```
   */
  interface KittyReq {
    /**
     * 简单 GET 请求
     * @param url 请求 URL
     * @returns 响应文本
     */
    (url: string): Promise<string>

    /**
     * 带选项的请求
     * @param url 请求 URL
     * @param options 请求选项
     * @returns 响应文本
     */
    (url: string, options: Partial<KittyRequestOptions>): Promise<string>

    /**
     * 完整配置请求
     * @param options 请求选项（必须包含 url）
     * @returns 响应文本
     */
    (options: KittyRequestOptions): Promise<string>
  }

  /**
   * 分类信息
   */
  interface ICategory {
    /**
     * 分类名称
     * @example "电影", "电视剧", "动漫"
     */
    text: string

    /**
     * 分类 ID
     * @example "1", "movie", "tv"
     */
    id: string
  }

  /**
   * 播放列表中的单个视频
   */
  interface IPlaylistVideo {
    /**
     * 视频名称/集数
     * @example "第1集", "HD", "1080P"
     */
    text: string

    /**
     * m3u8 视频链接
     * 
     * 如果存在，则视频类型为 m3u8
     * @example "https://example.com/video.m3u8"
     */
    url?: string

    /**
     * iframe 链接
     * 
     * 如果存在，则视频类型为 iframe
     * 需要通过 parseIframe 解析获取真实播放地址
     * @example "https://example.com/player.html?vid=123"
     */
    id?: string
  }

  /**
   * 播放列表
   * 一个视频可能有多个播放列表（不同线路）
   */
  interface IPlaylist {
    /**
     * 播放列表标题
     * @example "线路1", "高清", "蓝光"
     */
    title: string

    /**
     * 视频列表
     */
    videos: Array<IPlaylistVideo>
  }

  /**
   * 视频/电影信息
   */
  interface IMovie {
    /**
     * 视频 ID
     * @example "12345", "movie_001"
     */
    id: string

    /**
     * 视频标题
     * @example "肖申克的救赎", "权力的游戏 第一季"
     */
    title: string

    /**
     * 封面图片 URL
     * @example "https://example.com/cover.jpg"
     */
    cover: string

    /**
     * 备注信息
     * @example "更新至10集", "HD", "完结"
     */
    remark?: string

    /**
     * 视频描述/简介
     */
    desc?: string

    /**
     * 播放列表
     * 包含所有可用的播放线路和集数
     */
    playlist?: Array<IPlaylist>
  }

  /**
   * 首页内容类型
   */
  type IHomeContentType =
    "banner" |    // 轮播图
    "card" |      // 卡片（横向滚动）
    "list" |      // 列表
    "markdown"    // Markdown 内容

  /**
   * 首页内容项
   * 首页可以包含多个不同类型的内容区块
   */
  interface IHomeContentItem {
    /**
     * 内容类型
     */
    type: IHomeContentType

    /**
     * 区块标题
     * @example "热门推荐", "最新上映", "本周热播"
     */
    title?: string

    /**
     * 视频列表
     * 当 type 为 banner、card 或 list 时使用
     */
    videos?: Array<IMovie>

    /**
     * 扩展字段
     */
    extra?: {
      /**
       * 关联的分类 ID
       * 用于"查看更多"功能
       */
      categoryId?: string

      /**
       * Markdown 内容
       * 当 type 为 markdown 时使用
       */
      markdown?: string

      /**
       * 其他自定义字段
       */
      [key: string]: any
    }
  }

  /**
   * 首页数据
   * 支持两种布局模式
   */
  interface IHomeData {
    /**
     * 数据类型
     * - list: 简单列表模式（兼容旧版本, 并支持分页）
     * - complex: 复杂布局模式（支持多种内容类型, 不支持分页）
     */
    type: 'list' | 'complex'

    /**
     * 内容数据
     * 包含一个或多个内容区块
     */
    data: Array<IHomeContentItem>
  }

  /**
   * JavaScript 配置
   * 用于自定义各个接口的实现逻辑
   */
  interface IconfigExtraJS {
    /**
     * 获取分类, 可以是 JavaScript 代码, 也可以是一个数组
     * 
     * @example 数组格式
     * ```typescript
     * [
     *   { text: "电影", id: "1" },
     *   { text: "电视剧", id: "2" }
     * ]
     * ```
     * 
     * @example JS代码
     * ```typescript
     * "return [{ text: '全部', id: '' }]"
     * ```
     */
    category: string

    /**
     * 获取首页数据的 JavaScript 代码
     * 
     * 返回值格式：IMovie[] 或 IHomeData
     * 
     * @example
     * ```typescript
     * const html = await req(env.baseUrl)
     * const $ = kitty.load(html)
     * return $('.movie-item').map((i, el) => ({
     *   id: $(el).attr('data-id'),
     *   title: $(el).find('.title').text(),
     *   cover: $(el).find('img').attr('src')
     * })).get()
     * ```
     */
    home: string

    /**
     * 搜索的 JavaScript 代码
     * 
     * 返回值格式：IMovie[]
     * 
     * @example
     * ```typescript
     * const keyword = env.get('keyword')
     * const html = await req(\`\${env.baseUrl}/search?q=\${keyword}\`)
     * return results
     * ```
     */
    search: string

    /**
     * 获取视频详情的 JavaScript 代码
     * 
     * 返回值格式：IMovie
     * 
     * @example
     * ```typescript
     * const movieId = env.get('movieId')
     * const html = await req(\`\${env.baseUrl}/detail/\${movieId}\`)
     * return movieDetail
     * ```
     */
    detail: string

    /**
     * 解析 iframe 的 JavaScript 代码
     * 
     * 返回值格式：string 或 string[]
     * 
     * 如果返回空或解析失败，会自动回退到无头浏览器嗅探
     * 
     * @example
     * ```typescript
     * const iframe = env.get('iframe')
     * const html = await req(iframe)
     * const match = html.match(/url:"([^"]+\.m3u8)"/)
     * return match ? match[1] : ''
     * ```
     */
    parseIframe: string
  }

  /**
   * 无头浏览器嗅探配置
   * 用于自动嗅探媒体资源 URL
   */
  interface IconfigExtraSniffer {
    /**
     * 嗅探模式
     * - 0: 返回第一个匹配的 URL（推荐，速度快）
     * - 1: 返回所有匹配的 URL（用于获取多个清晰度）
     * 
     * TODO(d1y): 目前小猫中没有选择多个结果源, 所以只有0可用
     * 
     * @default 0
     * @example
     * ```typescript
     * // 只需要一个 URL
     * { mode: 0 }
     * 
     * // 需要所有清晰度
     * { mode: 1 }
     * ```
     */
    mode?: 0 | 1

    /**
     * 超时时间（毫秒）
     * 
     * 建议根据网站加载速度设置：
     * - 快速网站: 10000-15000 (10-15秒)
     * - 普通网站: 15000-20000 (15-20秒)
     * - 慢速网站: 20000-30000 (20-30秒)
     * 
     * @default 10000
     * @example
     * ```typescript
     * { timeout: 15000 }  // 15秒超时
     * ```
     */
    timeout?: number

    /**
     * 自定义正则表达式，用于匹配媒体 URL
     * 
     * 如果不设置，使用默认规则匹配常见的媒体格式
     * 
     * @example
     * ```typescript
     * // 只匹配 m3u8
     * { customRegex: "https?://.*\\.m3u8" }
     * 
     * // 匹配特定域名的视频
     * { customRegex: "https?://cdn\\.example\\.com/.*\\.(m3u8|mp4)" }
     * 
     * // 匹配特定清晰度
     * { customRegex: "https?://.*\\.(m3u8|mp4)\\?.*quality=1080p" }
     * ```
     */
    customRegex?: string

    /**
     * 排除规则（正则表达式）
     * 
     * 匹配的 URL 将被忽略，用于过滤广告和追踪链接
     * 
     * @example
     * ```typescript
     * // 排除广告域名
     * { exclude: "ads\\.com|tracker\\.com" }
     * 
     * // 排除多个域名
     * { exclude: "ads\\.|stat\\.|analytics\\." }
     * ```
     */
    exclude?: string

    /**
     * 页面加载完成后执行的 JavaScript 脚本
     * 
     * 用于触发视频加载、点击播放按钮等操作
     * 
     * @example
     * ```typescript
     * // 点击播放按钮
     * {
     *   script: `
     *     var btn = document.querySelector('.play-button');
     *     if (btn) btn.click();
     *   `
     * }
     * 
     * // 触发视频播放
     * {
     *   script: `
     *     var video = document.querySelector('video');
     *     if (video) video.play();
     *   `
     * }
     * 
     * // 等待元素出现后操作
     * {
     *   script: `
     *     setTimeout(() => {
     *       var btn = document.querySelector('.play-btn');
     *       if (btn) btn.click();
     *     }, 2000);
     *   `
     * }
     * ```
     */
    script?: string

    /**
     * 页面初始化时执行的 JavaScript 脚本
     * 
     * 在页面加载前执行，用于注入 Cookie、修改页面行为等
     * 
     * @example
     * ```typescript
     * // 注入 Cookie
     * {
     *   initScript: `
     *     document.cookie = 'auth_token=your_token_here';
     *   `
     * }
     * 
     * // 隐藏 webdriver 特征
     * {
     *   initScript: `
     *     Object.defineProperty(navigator, 'webdriver', {
     *       get: () => undefined
     *     });
     *   `
     * }
     * 
     * // 设置全局变量
     * {
     *   initScript: `
     *     window.customFlag = true;
     *     console.log('页面初始化完成');
     *   `
     * }
     * ```
     */
    initScript?: string
  }

  /**
   * JavaScript 模板类型
   */
  type ITemplateWithJS =
    "t4"  // 道长的 type=4 模板
  // TODO(d1y): 小猫中现在t4自动嗅探有点问题, 请 @d1y 催更(2025-10-26)

  /**
   * 源配置扩展字段
   */
  interface IconfigExtra {
    /**
     * VIP 解析接口 URL
     * 
     * 用于解析需要 VIP 才能观看的视频
     * 
     * @example "https://jx.example.com/?url="
     */
    jiexiUrl?: string

    /**
     * 是否需要翻墙访问
     * 
     * @default false
     */
    gfw?: boolean

    /**
     * 搜索结果每页数量
     * 
     * @default 10 (universal) 或 20 (maccms)
     */
    searchLimit?: number

    /**
     * JavaScript 配置
     * 
     * 用于自定义各个接口的实现逻辑
     *
     * **解析视频链接(parseIframe)优先级高于无头浏览器嗅探**
     */
    js?: IconfigExtraJS

    /**
     * 无头浏览器嗅探配置
     * 
     * 用于自动嗅探媒体资源 URL
     * 当 JS 配置解析失败时自动回退到嗅探
     */
    sniffer?: IconfigExtraSniffer

    /**
     * 使用预定义的模板(JavaScript)
     */
    template?: ITemplateWithJS

    /**
     * 分类配置
     * 
     * MacCMS (type=0) 特有，用于指定分类
     * 注意, 请 JSON.stringify 后传入
     *
     * **主要是因为在 MacCMS 中有些分类压根就没有视频**
     * 
     * @example
     * ```typescript
     * '[{"text":"电影","id":"1"},{"text":"电视剧","id":"2"}]'
     * ```
     */
    category?: string

    /**
     * 其他自定义字段
     */
    [prop: string]: any
  }

  interface ILiveItem {
    name: string
    url: string
    type: 0 | 1 // 0=m3u | 1=txt
  }

  /**
   * 源配置
   * 定义一个视频源的完整信息
   */
  interface Iconfig {
    /**
     * 源 ID
     * 
     * 全局唯一标识符
     * 
     * @example "source_001", "bilibili", "douyin"
     */
    id: string

    /**
     * 源名称
     * 
     * @example "示例源", "B站", "抖音"
     */
    name: string

    /**
     * 源类型
     * - 0: MacCMS 源
     * - 1: Universal 源（JS通用源）
     */
    type: 0 | 1

    /**
     * API 地址
     * 
     * @example
     * ```typescript
     * // MacCMS
     * "https://example.com/api.php/provide/vod/"
     * 
     * // Universal
     * "https://example.com"
     * ```
     */
    api: string

    /**
     * 是否为 NSFW（18+）内容
     * 
     * @default false
     */
    nsfw: boolean

    /**
     * Logo URL
     * 
     * @example "https://example.com/logo.png"
     */
    logo?: string

    /**
     * 源描述
     * 
     * @example "这是一个示例视频源"
     */
    desc?: string

    /**
     * 扩展配置
     * 
     * 包含 VIP 解析、JS 配置、嗅探配置等
     */
    extra?: IconfigExtra
  }

  /**
   * 获取源配置的处理函数
   * 
   * @returns 源配置对象
   * @example
   * ```typescript
   * getConfig(): Iconfig {
   *   return {
   *     id: 'my_source',
   *     name: '我的视频源',
   *     type: 1,
   *     api: 'https://example.com',
   *     nsfw: false
   *   }
   * }
   * ```
   */
  type HandleConfig = () => Iconfig

  /**
   * 获取分类列表的处理函数
   * 分类分为两种
   * 1. JS动态: 需要自己实现
   * 2. 固定数组: 可以直接使用, 但请 JSON.stringify 后传入
   * 
   * @example JS动态
   * ```typescript
   * async getCategory(): Promise<ICategory[]> {
   *   const html = await req(env.baseUrl)
   *   const $ = kitty.load(html)
   *   return $('.category-item').map((i, el) => ({
   *     text: $(el).text(),
   *     id: $(el).attr('data-id')
   *   })).get()
   * }
   * ```
   * 
   * @example 固定数组
   * ```typescript
   * async getCategory(): Promise<ICategory[]> {
   *   return [
   *     { text: '电影', id: "1" },
   *     { text: '电视剧', id: "2" },
   *     { text: '综艺', id: "3" },
   *   ]
   * }
   */
  type HandleCategory = () => Promise<ICategory[]>

  /**
   * 获取首页数据的处理函数
   * 
   * @returns 视频列表或首页数据
   * @example
   * ```typescript
   * async getHome(): Promise<IMovie[]> {
   *   const page = env.get('page', 1)
   *   const category = env.get('category', '')
   *   const html = await req(`${env.baseUrl}/list?page=${page}&cat=${category}`)
   *   // ... 解析逻辑
   *   return movies
   * }
   * ```
   */
  type HandleHome = () => Promise<IMovie[] | IHomeData>

  /**
   * 获取视频详情的处理函数
   * 
   * @returns 视频详情
   * @example
   * ```typescript
   * async getDetail(): Promise<IMovie> {
   *   const movieId = env.get('movieId')
   *   const html = await req(`${env.baseUrl}/detail/${movieId}`)
   *   // ... 解析逻辑
   *   return movieDetail
   * }
   * ```
   */
  type HandleDetail = () => Promise<IMovie>

  /**
   * 搜索视频的处理函数
   * 
   * @returns 搜索结果列表
   * @example
   * ```typescript
   * async getSearch(): Promise<IMovie[]> {
   *   const keyword = env.get('keyword')
   *   const page = env.get('page', 1)
   *   const html = await req(`${env.baseUrl}/search?q=${keyword}&page=${page}`)
   *   // ... 解析逻辑
   *   return results
   * }
   * ```
   */
  type HandleSearch = () => Promise<IMovie[]>

  /**
   * 解析 iframe 获取真实播放地址的处理函数
   *
   * @returns 播放地址（单个或多个, 多个小猫播放也只会取[0]）
   * @example
   * ```typescript
   * async parseIframe(): Promise<string> {
   *   const iframe = env.get('iframe')
   *   const html = await req(iframe)
   *   const match = html.match(/url:"([^"]+\.m3u8)"/)
   *   return match ? match[1] : ''
   * }
   * 
   * // 或返回多个地址
   * async parseIframe(): Promise<string[]> {
   *   const iframe = env.get('iframe')
   *   const html = await req(iframe)
   *   const matches = html.matchAll(/url:"([^"]+\.m3u8)"/g)
   *   return Array.from(matches, m => m[1])
   * }
   * ```
   */
  type HandleParseIframe = () => Promise<string[] | string>

  /**
   * 处理器抽象类
   * 
   * 定义了视频源的所有接口方法
   * 
   * @example
   * ```typescript
   * class MySource extends Handle {
   *   getConfig(): Iconfig {
   *     return {
   *       id: 'my_source',
   *       name: '我的视频源',
   *       type: 1,
   *       api: 'https://example.com',
   *       nsfw: false
   *     }
   *   }
   *   
   *   async getCategory(): Promise<ICategory[]> {
   *     // 实现获取分类逻辑
   *     return []
   *   }
   *   
   *   async getHome(): Promise<IMovie[]> {
   *     // 实现获取首页逻辑
   *     return []
   *   }
   *   
   *   async getDetail(): Promise<IMovie> {
   *     // 实现获取详情逻辑
   *     return {} as IMovie
   *   }
   *   
   *   async getSearch(): Promise<IMovie[]> {
   *     // 实现搜索逻辑
   *     return []
   *   }
   *   
   *   async parseIframe(): Promise<string> {
   *     // 实现 iframe 解析逻辑
   *     // 也可为空, 支持自动嗅探
   *     return ''
   *   }
   * }
   * ```
   */
  abstract class Handle {
    /**
     * 获取源配置（必须实现）
     */
    getConfig: HandleConfig

    /**
     * 获取分类列表
     */
    getCategory: HandleCategory

    /**
     * 获取首页数据
     */
    getHome: HandleHome

    /**
     * 获取视频详情（可选）
     * 
     * 不存在只能是 `getHome` 已经获取到数据(包括视频链接)
     */
    getDetail?: HandleDetail

    /**
     * 搜索视频（可选）
     * 
     * 不存在则表示不支持搜索
     */
    getSearch?: HandleSearch

    /**
     * 解析 iframe（可选
     *
     * **不存在则会自动嗅探**
     */
    parseIframe?: HandleParseIframe
  }

}

export { }