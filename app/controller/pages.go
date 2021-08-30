package controller

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"goblog/app/model"
	"strings"
)

func ManagePages(c *gin.Context)  {
	route := c.Request.URL
	data := make(map[string]interface{})
	data["currentCategory"] = model.GetCategoryByRoute(fmt.Sprintf("%s",route))[0]
	data["row"] = struct {Id int}{Id: 0}
	fmt.Println(strings.Replace(fmt.Sprintf("%s",route),"/","",-1))
	commentType := strings.Replace(fmt.Sprintf("%s",route),"/","",-1)
	comments := model.GetCommentByArticleId(0,commentType)
	data["comments"] = model.CommentTree(comments,0)
	data["type"] = commentType
	data["load"] = route
	view(c,"pages/index.html",data)
}