
interface T4Class {
  type_id: string
  type_name: string
}

interface T4Video {
  type_name: string
  vod_actor: string
  vod_area: string
  vod_content: string
  vod_year: string
  vod_id: string
  vod_name: string
  vod_pic: string
  vod_remarks: string
}

type T4EPUrl = { name: string, url: string }

type T4EP = { name: string, urls: Array<T4EPUrl> }

// TODO(d1y): custom headers
export default class T4 implements Handle {
  getConfig() {
    return <Iconfig>{
      id: "t4",
      name: "T4",
      api: "https://tvbot.ggff.net/pingguo",
      nsfw: false,
      type: 1
    }
  }
  async getCategory() {
    const text = await req(env.baseUrl, {
      headers: {
        "User-Agent": "okhttp/3.12.0",
      }
    })
    const unsafeObj: {
      class: T4Class[]
      list: T4Video[]
    } = JSON.parse(text)
    return unsafeObj.class.map<ICategory>(item => {
      return {
        id: item.type_id,
        text: item.type_name,
      }
    })
  }
  async getHome() {
    const cate = env.get("category")
    const page = env.get("page")
    const text = await req(env.baseUrl, {
      params: {
        t: cate,
        ac: "detail",
        pg: page,
      },
      headers: {
        "User-Agent": "okhttp/3.12.0",
      }
    })
    const unsafeObj: {
      limit: number
      list: T4Video[]
    } = JSON.parse(text)
    return unsafeObj.list.map<IMovie>(item => {
      return {
        id: item.vod_id,
        title: item.vod_name,
        cover: item.vod_pic,
        remark: item.vod_remarks,
      }
    })
  }

  async getDetail() {
    const id = env.get("movieId")
    const text = await req(env.baseUrl, {
      params: {
        ac: "detail",
        ids: id,
      },
      headers: {
        "User-Agent": "okhttp/3.12.0",
      },
    })
    function parseVideos(cx: any): Record<string, Array<T4EP>> {
      if (!cx) return {}
      const mainSplitSyb = "$$$"
      const { vod_play_from, vod_play_url } = cx
      if (!vod_play_from || !vod_play_url) return {}
      const tabs = vod_play_from.split(mainSplitSyb)
      const vs = vod_play_url.split(mainSplitSyb)
      const result: Record<string, Array<T4EP>> = {}
      for (let i = 0; i < tabs.length; i++) {
        const name = tabs[i] as string
        const url = vs[i] as string
        if (!result[name]) result[name] = []
        const urls: Array<{ name: string, url: string }> = []
        for (const item of url.split("#")) {
          const [name, url] = item.split("$")
          urls.push({ name, url })
        }
        result[name].push({ name, urls })
      }
      return result
    }
    const unsafeObj: {
      list: [T4Video]
    } = JSON.parse(text);
    const _ = unsafeObj.list[0]
    const videos = parseVideos(_)
    const playlist: IPlaylist[] = []
    Object.keys(videos).map(key => {
      const val = videos[key]
      const vod = val.map(item => {
        const title = item.name
        const videos = item.urls.map<IPlaylistVideo>(_ => {
          const iframe = [
            title,
            _.url,
          ]
          return { text: _.name, id: JSON.stringify(iframe) }
        })
        return <IPlaylist>{ title, videos }
      })
      playlist.push(...vod)
    })
    return <IMovie>{ desc: _.vod_content, playlist }
  }
  async getSearch() {
    const wd = env.get("keyword")
    const page = env.get("page")
    const text = await req(env.baseUrl, {
      params: {
        wd,
        pg: page,
        quick: false,
      },
      headers: {
        "User-Agent": "okhttp/3.12.0",
      }
    })
    const unsafeObj: {
      limit: number
      list: T4Video[]
    } = JSON.parse(text)
    return unsafeObj.list.map<IMovie>(item => {
      return {
        id: item.vod_id,
        title: item.vod_name,
        cover: item.vod_pic,
        remark: item.vod_remarks,
      }
    })
  }
  async parseIframe() {
    const _cx = env.get<string>("iframe")
    const [ flag, play ] = JSON.parse(_cx)
    const text = await req(env.baseUrl, {
      params: {
        flag,
        play,
      },
      headers: {
        "User-Agent": "okhttp/3.12.0",
      }
    })
    const unsafeObj: {
      parse: 0 | 1
      url: string
    } = JSON.parse(text)
    if (unsafeObj.parse == 0) {
      return unsafeObj.url
    }
    return ""
  }
}