// Copyright (C) 2021 d1y <chenhonzhou@gmail.com>
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
// 
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// before install `markdown-it` deps 
// npm i --save markdown-it

const markdown = require('markdown-it')
const path = require('path')
const fs = require('fs')

;(async ()=> {
  
  var filename = "源制作.md"
  var outputFilename = "source_create.html"
  var targetFile = path.join(__dirname, `../docs/${ filename }`)
  var md = markdown()
  var text = fs.readFileSync(targetFile).toString()
  var html = md.render(text)

  html = `<!-- 自动生成, 切勿删除 -->\n\n\n` + html

  var writeFilePath = path.join(__dirname, `../assets/data/${ outputFilename }`)
  fs.writeFileSync(writeFilePath, html)

})()