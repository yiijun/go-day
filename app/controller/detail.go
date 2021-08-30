package controller

import (
	"github.com/gin-gonic/gin"
	"goblog/app/model"
	"regexp"
	"strconv"
)

func Detail(c *gin.Context) {
	reg := regexp.MustCompile(`[0-9]+`)
	id := reg.FindString(c.Param("id"))
	data := make(map[string]interface{})
	data["row"] = model.GetDetailArticle(id)[0]
	idInt,_ := strconv.Atoi(id)
	comments := model.GetCommentByArticleId(idInt,"article")
	data["comments"] = model.CommentTree(comments,0)
	data["type"] = "article"
	data["load"] = c.Request.URL
	view(c,"article/detail.html",data)
}
