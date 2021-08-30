package controller

import (
	"github.com/gin-gonic/gin"
	"goblog/app/model"
	"goblog/common"
	"strconv"
)

func ListArticle(c *gin.Context) {
	title := c.DefaultQuery("keyword", "")
	currentPage, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	data := make(map[string]interface{})
	data["list"] = model.GetListArticle(title, currentPage)
	data["currentCategory"] = model.GetCategoryByRoute("/article")[0]
	count := model.GetArticleCount()
	//search 不做分页展示
	if title != ""{
		data["page"] = ""
	}else{
		data["page"] = common.Page(count, currentPage)
	}
	view(c, "article/index.html", data)
}
