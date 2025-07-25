const style = document.createElement('style')
style.textContent = `
  .dplayer-info-panel {
    top: 80px !important;
  }

  #rePlaylist {
    max-width: 240px;
    min-width: 140px;
    height: 100vh;
    background: rgba(0,0,0,.92);
    position: fixed;
    top: 0;
    left: 0;
    padding: ${paddingTop}px 0 12px;
    box-sizing: border-box;
    z-index: 9999;
    transition: all .24s;
    font-size: 14px;
    color: #fff;
    transform: translateX(-100vw);
    opacity: 0;
    overflow: hidden;
    user-select: none;
  }

  #reAction {
    position: fixed;
    top: ${paddingTop}px;
    left: 12px;
    width: 24vw;
    max-width: 120px;
    height: 42px;
    cursor: pointer;
    z-index: 9998;
    display: flex;
    color: #fff;
    align-items: center;
    gap: 12px;
    font-size: 16px;
    opacity: 0;
    transition: all .2s;
  }

  #reAction:hover {
    opacity: 1;
  }

  #reAction svg {
    width: 24px;
    height: 24px;
  }

  #reMask {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background: rgba(0, 0, 0, .24);
    z-index: 999;
    pointer-events: none;
    opacity: 0;
    transition: all .24s;
  }

  .playlist-item {
    width: 100%;
    height: 42px;
    cursor: pointer;
    display: flex;
    align-items: center;
    padding: 0 8px;
    box-sizing: border-box;
    border: 1px solid rgb(0, 120, 212, 0);
    transition: all .24s;
  }

  .playlist-item.active {
    border: 1px solid rgb(0, 120, 212);
    background: rgb(4, 57, 94);
  }

  .playlist-item:hover {
    border: 1px solid rgb(0, 120, 212, 0) !important;
    background: rgb(4, 57, 94);
  }

  .playlist-item:active {
    transform: scale(0.98);
  }

  #_scroll {
    -ms-overflow-style: none !important;  /* IE 和 Edge */
    scrollbar-width: none !important;  /* Firefox */
    width: 100%;
    height: 100%;
    overflow-x: hidden;
    overflow-y: auto;
  }

  /* Chrome/Safari 滚动条 */
  #_scroll::-webkit-scrollbar {
    display: none !important; /* Chrome, Safari, Edge 强制隐藏滚动条 */
  }
  #_scroll::-webkit-scrollbar-thumb {
    background: rgba(255,255,255,0.2);
    border-radius: 3px;
  }
  #_scroll::-webkit-scrollbar-track {
    background: transparent; /* 消除白色轨道 */
  }


  /* 关键修复：强制硬件加速兼容 */
  #rePlaylist, #reAction, #reMask {
    will-change: transform; /* 优化渲染过渡 */
    backface-visibility: hidden; /* 消除白边 */
  }
`
document.head.appendChild(style)

const context = document.createElement('div')
const action = document.createElement('div')
const mask = document.createElement('div')

const playSvg = `<svg t="1751684860167" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="4605" width="200" height="200"><path d="M138.666667 91.733333C115.2 74.666667 85.333333 93.866667 85.333333 123.733333v179.2c0 29.866667 29.866667 49.066667 53.333334 34.133334l140.8-89.6c23.466667-14.933333 23.466667-51.2 0-66.133334L138.666667 91.733333zM426.666667 170.666667c-23.466667 0-42.666667 19.2-42.666667 42.666666s19.2 42.666667 42.666667 42.666667h490.666666c23.466667 0 42.666667-19.2 42.666667-42.666667s-19.2-42.666667-42.666667-42.666666H426.666667zM64 512c0 23.466667 19.2 42.666667 42.666667 42.666667h810.666666c23.466667 0 42.666667-19.2 42.666667-42.666667s-19.2-42.666667-42.666667-42.666667H106.666667c-23.466667 0-42.666667 19.2-42.666667 42.666667M106.666667 853.333333h810.666666c23.466667 0 42.666667-19.2 42.666667-42.666666s-19.2-42.666667-42.666667-42.666667H106.666667c-23.466667 0-42.666667 19.2-42.666667 42.666667s19.2 42.666667 42.666667 42.666666" fill="#ffffff" p-id="4606"></path></svg>`

action.innerHTML = playSvg
context.id = 'rePlaylist'
action.id = 'reAction'
mask.id = 'reMask'

function sendMessage(type, value) {
  fetch(`/internal_msg`, {
    method: "POST",
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      type,
      value: JSON.stringify(value)
    })
  })
}

/**
 * @param {string} text 
 */
function setActionText(text) {
  let title = action.querySelector('div')
  if (!title) {
    title = document.createElement('div')
    action.append(title)
  }
  title.innerText = text
}

function getActionText() {
  return action.innerText
}

/**
 * @param {Array<{ title: string, url: string }>} list 
 */
function setPlaylist(list) {
  context.innerHTML = ''
  const wrapperDiv = document.createElement('div')
  wrapperDiv.id = "_scroll"
  context.append(wrapperDiv)
  list.forEach(item => {
    const itemElement = document.createElement('div');
    itemElement.className = 'playlist-item'
    itemElement.innerText = item.title
    itemElement.setAttribute('data-url', item.url)
    itemElement.addEventListener('click', () => {
      const url = item.url
      setActionText(item.title)
      setActiveWithPlaylist(url)
      togglePlaylist(false)
      sendMessage('switchVideo', url)
      const iframe = document.querySelector('#iframe')
      if (iframe) {
        iframe.src = url
        return
      }
      player.seek(0)
      player.switchVideo({ url })
    })
    wrapperDiv.append(itemElement)
  })
}

function setActiveWithPlaylist(url) {
  Array.from(document.querySelectorAll('#rePlaylist .playlist-item')).forEach(item=> {
    item.classList.remove('active')
    if (item.getAttribute('data-url') == url) {
      item.classList.add('active')
    }
  })
}

function toggleMask(show) {
  if (show) {
    mask.style.opacity = '1'
    mask.style.pointerEvents = 'all'
  } else {
    mask.style.opacity = '0'
    mask.style.pointerEvents = 'none'
  }
}

/**
 * @param {boolean} show 
 */
function togglePlaylist(show) {
  if (show) {
    context.style.transform = 'translateX(0)'
    context.style.opacity = '1'
  } else {
    context.style.transform = 'translateX(-100vw)'
    context.style.opacity = '0'
  }
  toggleMask(show)
}

document.body.append(context)
document.body.append(action)
document.body.append(mask)

document.addEventListener('keydown', (e) => {
  // CMD+T (Mac) | Ctrl+T (Windows)
  // CMD+S (Mac) | Ctrl+S (Windows) => Arc 浏览器肌肉记忆
  if ((e.metaKey || e.ctrlKey) && (e.key === 't' || e.key === 's')) {
    e.preventDefault()
    if (context.style.opacity === '1') {
      togglePlaylist(false)
    } else {
      togglePlaylist(true)
    }
  }
  if (e.key === 'Escape') {
    if (context.style.opacity === '1') {
      togglePlaylist(false)
    }
  }
})

action.addEventListener('click', () => togglePlaylist(true))
mask.addEventListener('click', () => togglePlaylist(false))

window.setActiveWithPlaylist = setActiveWithPlaylist
window.setActionText = setActionText
window.getActionText = getActionText