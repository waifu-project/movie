import { execSync } from 'child_process'
import { readFileSync, writeFileSync } from "fs"

/*const pipe = */ execSync("bunx kitty-parse -o result.json").toString("utf-8")
const cfgs: Iconfig[] = JSON.parse(readFileSync("result.json").toString("utf-8"))

let code = `import 'package:xi/xi.dart';

var jsTemplate = Templates({\n`
cfgs.forEach(cfg=> {
  code += `  "${cfg.id}": Template({\n`
  const js = cfg.extra!.js
  for (let [key, value] of Object.entries(js)) {
    code += `    JSCodeType.${key}: r"""
${value}
""",\n`
  }
  code += `  }),\n`
})
code += `});`

writeFileSync("../template.dart", code)