package controller

import (
	"github.com/gin-gonic/gin"
	"goblog/app/model"
)

func Index(c *gin.Context)  {
	data := make(map[string]interface{})
	data["list"] = model.GetIndexArticle()
	view(c,"index/index.html",data)
}
