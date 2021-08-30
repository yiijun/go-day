package controller

import (
	"fmt"
	"github.com/dchest/captcha"
	"github.com/gin-gonic/gin"
	"github.com/go-session/gin-session"
	"goblog/app/model"
	"goblog/common"
	"net/http"
)

func Captcha(c *gin.Context) {
	store := ginsession.FromContext(c)
	captchaId := common.SetCaptcha(c)
	store.Set("captchaId", captchaId)
	err := store.Save()
	if err != nil {
		panic(err.Error())
	}
}

func AddCommentByArticle(c *gin.Context) {
	code := c.PostForm("captcha")
	store := ginsession.FromContext(c)
	captchaId, ok := store.Get("captchaId")

	if !ok {
		c.JSON(http.StatusOK, gin.H{
			"code": 1,
			"msg":  "验证码已经失效",
		})
		return
	}
	if !captcha.VerifyString(fmt.Sprintf("%s", captchaId), code) {
		c.JSON(http.StatusOK, gin.H{
			"code": 2,
			"msg":  "输入验证码不正确",
		})
		return
	}
	store.Delete("captchaId")
	//插入评论信息

	if ret := model.AddCommentByArticle(c); ret != true {
		c.JSON(http.StatusOK, gin.H{
			"code": 3,
			"msg":  "添加评论失败",
		})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"code": 200,
		"msg":  "添加评论成功",
	})
	return
}
