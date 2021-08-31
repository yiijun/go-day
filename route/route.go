package route

import (
	"github.com/gin-gonic/gin"
	"github.com/go-session/gin-session"
	"goblog/app/controller"
	"html/template"
	"net/http"
)

type Captcha struct {
	Id string
}

func Routes() *gin.Engine {
	gin.SetMode(gin.ReleaseMode)
	r := gin.Default()
	r.SetFuncMap(template.FuncMap{
		"strToHtml": func(str string) template.HTML {
			return template.HTML(str)
		},
	})
	r.Use(ginsession.New())
	r.LoadHTMLGlob("app/view/**/*")
	r.StaticFS("/static", http.Dir("./static"))
	r.GET("/", controller.Index)
	r.GET("/detail/:id", controller.Detail)
	r.GET("/captcha", controller.Captcha)
	r.POST("/comment", controller.AddCommentByArticle)
	r.GET("/article",controller.ListArticle)
	r.GET("/pages",controller.ManagePages)
	r.GET("/link",controller.ManagePages)
	r.GET("/coding",controller.ManagePages)
	r.GET("/search",controller.ListArticle)
	return r
}
