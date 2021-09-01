package model

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"goblog/common"
	"goblog/database"
	"html"
	"strconv"
	"time"
)

type CommentInsert struct {
	Id         int
	Pid        int
	Aid        int
	Name       string
	Email      string
	Ip         string
	Url        string
	Body       string
	Type       string
	CreateTime int
}

type CommentPath struct {
	Ancestor   int
	Descendant int
	Len        int
}

type CommentsPathsTree struct {
	Cid        int
	Aid        int
	Name       string
	Email      string
	Body       string
	CreateTime int
	Ancestor   int
	Descendant int
	Len        int
}

type Comments struct {
	Cid        int
	Aid        int
	Pid        int
	Name       string
	Email      string
	Body       string
	Url        string
	CreateTime int
	Children   *[]interface{}
}

func CommentTree(comments []*Comments, pid int) string {

	html := ""
	isParent := "row"
	if pid != 0 {
		isParent = "child-node"
	}
	for _, v := range comments {
		if v.Pid == pid {
			headUrl := "http://q2.qlogo.cn/headimg_dl?dst_uin=%s&spec=100"
			html += "<div class=\"" + isParent + "\"  id=\"comment-" + strconv.Itoa(v.Cid) + "\">\n"
			if pid != 0 {
				html += "<div class=\"row\" id=\"comment-" + strconv.Itoa(v.Cid) + "\">"
			}
			html += "<div class=\"col-xs-2 col-sm-1 gravatar\">\n"
			html += "<img src=\"" + fmt.Sprintf(headUrl, v.Email) + "\" width=\"100%\" alt=\"\">\n"
			html += "</div>\n"
			html += "<div class=\"col-xs-10 col-sm-11\">\n"
			html += "<p class=\"comment-meta title\">\n"
			html += "<a href=\"" + v.Url + "\" target=\"_blank\" rel=\"nofollow noopener\">" + v.Name + "</a>\n"
			html += "<time datetime=\"" + common.TimeFormatMonth(time.Unix(int64(v.CreateTime), 0)) + "\" itemprop=\"datePublished\">\n"
			html += common.TimeFormatMonth(time.Unix(int64(v.CreateTime), 0)) + "\n"
			html += "</time>\n"
			html += " <a href=\"javascript:reply_to('" + strconv.Itoa(v.Cid) + "', '" + v.Name + "')\">回复</a>\n"
			html += "</p>"
			html += "<p class=\"comment-meta\">" + v.Body + "</pre>\n"
			html += "</div>\n"
			if isParent == "row" || pid != 0 {
				html += "</div>\n"
			}
			html += CommentTree(comments, v.Cid)
			if pid != 0 {
				html += "</div>\n"
			}
		}
	}
	return html
}

func GetCommentByArticleId(id int,t string) []*Comments {
	list := make([]*Comments, 0)
	if query := database.Ins.Table("go_comments").Where("`aid` = ? and `type` = ?", id,t).Find(&list); query.Error != nil {
		panic(query.Error)
	}
	return list
}

func AddCommentByArticle(c *gin.Context) bool {
	Aid, _ := strconv.Atoi(c.PostForm("archive"))
	ancestor, _ := strconv.Atoi(c.PostForm("parent"))
	insert := &CommentInsert{
		Aid:        Aid,
		Pid:        ancestor,
		Type:       c.PostForm("type"),
		Name:       c.PostForm("nickname"),
		Email:      c.PostForm("email"),
		Ip:         c.Request.RemoteAddr,
		Url:        c.PostForm("url"),
		Body:       html.EscapeString(c.PostForm("content")),
		CreateTime: int(time.Now().Unix()),
	}
	exec := database.Ins.Table("go_comments").Create(&insert)
	if exec.Error != nil {
		panic(exec.Error)
	}
	//插入新节点
	sql := "INSERT INTO go_comments_paths(ancestor,descendant)    SELECT t.ancestor,%d    FROM go_comments_paths AS t    WHERE t.descendant = %d    UNION ALL    SELECT %d,%d"
	if exec := database.Ins.Exec(fmt.Sprintf(sql, insert.Id, ancestor, insert.Id, insert.Id)); exec.Error != nil {
		panic(exec.Error)
	}
	return true
}
