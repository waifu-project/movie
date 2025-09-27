/// <reference types="node"/>

import type { load as cheerioLoad } from 'cheerio'

declare global {
  var kitty: Kitty
  var env: KittyEnv
  var req: KittyReq

  type KittyEnvParams =
    "category" |
    "page" |
    "limit" |
    "movieId" |
    "keyword" |
    "iframe"

  interface KittyEnv {
    baseUrl: string,
    params: Record<KittyEnvParams, any>,
    get<T>(key: KittyEnvParams, defaultValue?: T): T
  }

  interface KittyUtils {
    /**
     * ```js
     *  const url = `${env.baseUrl}${env.get("iframe")}`
     * ```
     * ↑↑↑↑ 拼接完成之后, 在调用 [getM3u8WithStr]
     * @param env {KittyEnv}
     */
    getM3u8WithIframe(env: KittyEnv): Promise<string>
    /**
     * 获取 `iframe` 的 `m3u8` 直链
     * 适用于:
     * ```html
     * <div></div><a href="$.html"/><a>
     * <script>
     *  var palyer_aaaa = {
     *  data: [],"url":"http://x.m3u8" 
     * }
     * </script>
     * ```
     */
    getM3u8WithStr(str: string): string
  }

  interface Kitty {
    load: typeof cheerioLoad
    utils: KittyUtils
  }

  interface KittyRequestOptions {
    url?: string
    method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH' | 'HEAD' | 'OPTIONS'
    headers?: Record<string, string>
    params?: Record<string, any>
    bodyType?: 'json' | 'form'
    /**
     * 小猫中会默认缓存请求, 当你不需要缓存时候, 可以设置为 true
     * > 如果遇到 url 一致的但只是参数不同时, 这个时候就需要设置为 true
     */
    noCache?: boolean
    data?: any
  }

  interface KittyReq {
    // req(url)
    (url: string): Promise<string>
    // req(url, options)
    (url: string, options: Partial<KittyRequestOptions>): Promise<string>
    // req(options)
    (options: KittyRequestOptions): Promise<string>
  }

  interface ICategory {
    text: string
    id: string
  }

  interface IPlaylistVideo {
    text: string
    // 这里的 type 通过 url | id 判断
    // url 存在则为 m3u8
    // id 则为 iframe
    // type: 'm3u8' | 'iframe'
    url?: string
    id?: string
  }  

  interface IPlaylist {
    title: string
    videos: Array<IPlaylistVideo>
  }

  interface IMovie {
    id: string
    title: string
    cover: string
    remark?: string
    desc?: string
    playlist?: Array<IPlaylist>
  }

  interface IconfigExtraJS {
    category: string
    home: string
    search: string
    detail: string
    parseIframe: string
  }

  interface IconfigExtra {
    jiexiUrl?: string
    gfw?: boolean
    searchLimit?: number
    js?: IconfigExtraJS
    [prop: string]: any
  }

  // TODO(d1y): update movie/schema/*.json
  interface Iconfig {
    id: string
    name: string
    type: 0 | 1
    api: string
    nsfw: boolean
    logo?: string
    desc?: string
    extra?: IconfigExtra
  }

  type HandleConfig = () => Iconfig
  type HandleCategory = () => Promise<ICategory[]>
  type HandleHome = () => Promise<IMovie[]>
  type HandleDetail = () => Promise<IMovie>
  type HandleSearch = () => Promise<IMovie[]>
  type HandleParseIframe = () => Promise<string[] | string>

  abstract class Handle {
    getConfig: HandleConfig
    getCategory?: HandleCategory
    getHome?: HandleHome
    getDetail?: HandleDetail
    getSearch?: HandleSearch
    parseIframe?: HandleParseIframe
  }

}

export { }