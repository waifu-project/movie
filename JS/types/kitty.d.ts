/// <reference types="node"/>

import type { load as cheerioLoad } from 'cheerio'

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

interface Kitty {
  load: typeof cheerioLoad
}

type KittyReq = (url: string) => Promise<string>

declare global {
  var kitty: Kitty
  var env: KittyEnv
  var req: KittyReq

  interface ICategory {
    text: string
    id: string
  }

  interface IPlaylist {
    text: string
    id: string
  }

  interface IMovie {
    id: string
    title: string
    cover: string
    remark: string
    playlist: Array<IPlaylist>
  }

  type HandleCategory = () => Promise<ICategory[]>
  type HandleHome = () => Promise<IMovie[]>
  type HandleDetail = () => Promise<IMovie[]>
  type HandleSearch = () => Promise<IMovie[]>
  type HandleParseIframe = () => Promise<string[]>

  abstract class Handle {
    getCategory: HandleCategory
    getHome: HandleHome
    getDetail: HandleDetail
    getSearch: HandleSearch
    parseIframe: HandleParseIframe
  }

}

export { }