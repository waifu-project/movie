import { load } from 'cheerio'

/** @type {KittyUtils} */
const utils = {
  /**
   * @param {KittyEnv} env
   * @returns {string}
   */
  async getM3u8WithIframe(env) {
    const iframe = env.get("iframe")
    const html = await req(`${env.baseUrl}${iframe}`)
    return this.getM3u8WithStr(html)
  },
  getM3u8WithStr(str) {
    const m3u8 = str.match(/"url"\s*:\s*"([^"]+\.m3u8)"/)[1]
    const realM3u8 = m3u8.replaceAll("\\/", "/")
    return realM3u8
  }
}

export { load, utils }