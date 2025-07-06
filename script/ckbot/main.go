package main

import (
	_ "embed"
	"encoding/json"
	"errors"
	"fmt"
	"net/url"
	"os"
	"slices"
	"strings"
	"sync"
	"time"

	"github.com/charmbracelet/log"
	"github.com/imroc/req/v3"
	"github.com/longbridgeapp/opencc"
	"github.com/sourcegraph/conc/pool"
)

//go:embed template.html
var htmlTemplate string

var t2s *opencc.OpenCC

var ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36"

func isHTML(input string) bool {
	input = strings.ToLower(input)
	htmlMarkers := []string{"html", "<!d", "<body"}

	for _, htmlMarker := range htmlMarkers {
		if strings.Contains(input, htmlMarker) {
			return true
		}
	}

	return false
}

func isJSON(str string) bool {
	if strings.HasPrefix(str, "{") && strings.HasSuffix(str, "}") {
		return true
	}
	if strings.HasPrefix(str, "[") && strings.HasSuffix(str, "]") {
		return true
	}
	return false
}

func isXML(body string) bool {
	docStart := strings.TrimSpace(body)[:5]
	return docStart == "<?xml"
}

type ResponseType int

const (
	XMLT ResponseType = iota
	JSONT
	UnknownT
)

type Result struct {
	Idx    int          `json:"idx"`    // 索引(map会丢失)
	Parse  ParseResult  `json:"parse"`  // 上下文
	OK     bool         `json:"ok"`     // 是否可用
	Time   string       `json:"time"`   // 耗时
	Reason string       `json:"reason"` // 原因
	Nsfw   bool         `json:"nsfw"`   // 是否是18+源
	Type   ResponseType `json:"type,omitempty"`
}

type GithubUser struct {
	Avatar   string `json:"avatar_url"`
	Login    string `json:"login"`
	HomePage string `json:"html_url"`
}

// 参考数据结构: https://api.github.com/repos/waifu-project/movie/issues/45/comments
type GithubIssueComment struct {
	ID        uint64      `json:"id"`
	Body      string      `json:"body"`
	User      *GithubUser `json:"user"`
	CreatedAt string      `json:"created_at"`
	UpdatedAt string      `json:"updated_at"`
	Text      []ParseResult
}

func isOKAndResponseType(body string) (ResponseType, error) {
	var cx = strings.TrimSpace(body)
	if len(cx) == 0 {
		return UnknownT, errors.New("body 为空, 该接口无响应")
	}
	if cx == "err{0}" { // 错误的魔法值
		return UnknownT, errors.New("body 为错误值(err{0})")
	}
	if isHTML(cx) {
		return UnknownT, errors.New("body 为 html 格式, 不支持或者该域名已经过期")
	}
	if isXML(body) {
		return XMLT, nil
	}
	if isJSON(body) {
		return JSONT, nil
	}
	return UnknownT, errors.New("body 不是 xml 或者 json 格式")
}

func getGithubIssueComments(owner, repo, issueID, token string) map[uint64]GithubIssueComment {
	var url = fmt.Sprintf("https://api.github.com/repos/%s/%s/issues/%s/comments", owner, repo, issueID)
	var comments []GithubIssueComment
	req.SetQueryParam("per_page", "100").SetBearerAuthToken(token).SetSuccessResult(&comments).MustGet(url)
	var cx = make(map[uint64]GithubIssueComment)
	for _, comment := range comments {
		var texts = getItemWithText(comment.Body, cx)
		if len(texts) == 0 {
			// 如果全是重复的为空了, 那还要个毛线啊
			continue
		}
		comment.Text = texts
		cx[comment.ID] = comment
	}
	return cx
}

type ParseResult struct {
	Text string `json:"name"`
	URL  string `json:"url"`
	Nsfw bool   `json:"nsfw"`
}

// 判断数组中是否包含单个
//
// 自动去除 / 尾部, 我怕它重复了
func resultIncludes(list []ParseResult, val ParseResult) bool {
	var url2 = strings.TrimSuffix(val.URL, "/")
	for _, item := range list {
		var url1 = strings.TrimSuffix(item.URL, "/")
		if url1 == url2 {
			return true
		}
	}
	return false
}

func parseName(raw string) string {
	var result = strings.TrimSpace(raw)
	text, err := t2s.Convert(result)
	if err != nil {
		return result
	}
	return text
}

func getItemWithText(text string, cx map[uint64]GithubIssueComment) []ParseResult {
	var context []ParseResult
	for _, comment := range cx {
		context = append(context, comment.Text...)
	}
	var result []ParseResult
	var lines = strings.Split(strings.TrimSpace(text), "\n")
	var skip = true
	for _, _line := range lines {
		var line = strings.TrimSpace(_line)
		if strings.HasPrefix(line, "-----") {
			skip = false
			continue
		}
		if skip {
			continue
		}
		var syb = " "
		if strings.Contains(line, ",") {
			syb = ","
		}
		var ss = strings.Split(line, syb)
		if len(ss) <= 1 {
			continue
		}
		var text = parseName(ss[0])
		var url = strings.TrimSpace(ss[1])
		var now = ParseResult{
			Text: text,
			URL:  url,
			Nsfw: false,
		}
		if len(ss) >= 3 {
			var flag = strings.TrimSpace(ss[2])
			var flags = []string{"true", "nsfw", "色情"}
			if slices.Contains(flags, flag) {
				now.Nsfw = true
			}
		}
		if resultIncludes(context, now) { //重复了就不添加
			continue
		}
		result = append(result, now)
	}
	return result
}

func runTaskCheck(list []ParseResult, ccTaskCount int) []Result {
	var pool = pool.New().WithMaxGoroutines(ccTaskCount)
	var cx sync.Map // map[int][Result]
	for idx, item := range list {
		pool.Go(func() {
			var start = time.Now()
			var result Result
			defer func() {
				if r := recover(); r != nil {
					log.Error("Recovered", "err", r)
				}
			}()
			resp, err := req.Get(item.URL)
			result.Idx = idx
			result.Parse = item
			log.Info("检查资源", "名称", item.Text, "链接", item.URL)
			if err != nil {
				log.Error("检查资源失败1", "名称", item.Text, "链接", item.URL, "reason", err)
				result.Reason = err.Error()
			} else {
				var body, err = resp.ToString()
				if err != nil {
					log.Error("解析资源body失败", "名称", item.Text, "链接", item.URL, "reason", err)
					result.Reason = err.Error()
				} else {
					rt, err := isOKAndResponseType(body)
					if err != nil {
						result.Reason = err.Error()
						log.Error("验证资源body失败", "名称", item.Text, "链接", item.URL, "reason", err)
					} else {
						result.Nsfw = item.Nsfw
						result.Type = rt
						result.OK = true
						log.Info("检查资源成功", "名称", item.Text, "链接", item.URL, "NSFW", result.Nsfw)
					}
				}
			}
			var s = time.Since(start).Seconds()
			result.Time = fmt.Sprintf("%.2f", s)
			cx.Store(idx, result)
		})
	}
	pool.Wait()
	var result []Result
	cx.Range(func(key, value any) bool {
		result = append(result, value.(Result))
		return true
	})
	return result
}

type v1 struct {
	Name   string `json:"name"`
	Nsfw   bool   `json:"nsfw"`
	API    v1API  `json:"api"`
	Status bool   `json:"status"`
}

type v1API struct {
	Root string `json:"root"`
	Path string `json:"path"`
}

type htmlDataStruct struct {
	Data    []Result           `json:"data"`
	Comment GithubIssueComment `json:"comment"`
}
type htmlStruct struct {
	NowTime string                    `json:"now"`
	Correct int                       `json:"correct"`
	Err     int                       `json:"err"`
	Data    map[uint64]htmlDataStruct `json:"data"`
}

var cstSh, _ = time.LoadLocation("Asia/Shanghai")

func dumpToHTML(result map[uint64][]Result, cx map[uint64]GithubIssueComment, correct, err int) {
	var data = make(map[uint64]htmlDataStruct)
	for key, results := range result {
		data[key] = htmlDataStruct{
			Data:    results,
			Comment: cx[key],
		}
	}
	var output = htmlStruct{
		NowTime: time.Now().In(cstSh).Format("2006年01月02日 15时04分05秒"),
		Data:    data,
		Correct: correct,
		Err:     err,
	}
	buf, e := json.Marshal(output)
	if e != nil {
		panic(err)
	}
	var code = string(buf)
	var html = strings.Replace(htmlTemplate, "$$$$", code, -1)
	var outHTML = os.Getenv("OUT_HTML")
	if outHTML != "" {
		os.WriteFile(outHTML, []byte(html), 0644)
	}
}

func dumpToJSON(_result map[uint64][]Result) (int, int) {
	var correct = 0
	var err = 0
	var pipe []Result
	var yoyoJSON []v1

	{
		for _, val := range _result {
			pipe = append(pipe, val...)
		}
		for _, val := range pipe {
			if val.OK {
				correct++
				var cx, err = url.Parse(val.Parse.URL)
				if err != nil {
					panic(err)
				}
				var root = fmt.Sprintf("%s://%s", cx.Scheme, cx.Host)
				var data = v1{Name: val.Parse.Text, Nsfw: val.Nsfw, API: v1API{Root: root, Path: cx.Path}, Status: true}
				yoyoJSON = append(yoyoJSON, data)
			} else {
				err++
			}
		}
	}

	var humanSize = fmt.Sprintf("%d/%d", correct, len(pipe))
	log.Info("检查完成", "当前可用", humanSize)

	var file = os.Getenv("OUTPUT")
	if file != "" {
		cx, err := json.MarshalIndent(yoyoJSON, "", "\t")
		if err != nil {
			panic(err)
		}
		os.WriteFile(file, cx, 0644)
	}

	return correct, err
}

func init() {
	req.SetUserAgent(ua)
	req.SetTimeout(time.Second * 6)
	req.EnableInsecureSkipVerify()
}

func main() {
	t2s, _ = opencc.New("t2s")
	log.Info("开始获取评论列表")
	var token = os.Getenv("GITHUB_TOKEN")
	if token == "" {
		panic("GITHUB_TOKEN 不能为空")
	}
	var bodys = getGithubIssueComments("waifu-project", "movie", "45", token)
	if len(bodys) == 0 {
		panic("从 github 评论中未获取到资源")
	}
	log.Infof("获取评论列表完成(解析到%d条评论)\n", len(bodys))
	var result = make(map[uint64][]Result)
	for _, item := range bodys {
		log.Info("开始检查资源组", "id", item.ID, "数量", len(item.Text))
		var data = runTaskCheck(item.Text, 12)
		result[item.ID] = data
	}
	var correct, err = dumpToJSON(result)
	dumpToHTML(result, bodys, correct, err)
	log.Info("完成")
}
