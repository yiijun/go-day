package controller

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"goblog/app/model"
	"net/http"
)

func  view(c *gin.Context,path string,data map[string]interface{}) {
	data["category"] = model.GetCategoryList()
	data["shar"] = fmt.Sprintf("%s%s",c.Request.Referer(),c.Request.URL)
	c.HTML(http.StatusOK,path,gin.H{
		"config":model.GetWebConfig(),
		"data":data,
	})
}
