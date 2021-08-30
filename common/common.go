package common

import (
	"fmt"
	"github.com/dchest/captcha"
	"github.com/gin-gonic/gin"
	"math"
	"strconv"
	"time"
)

var enFormatMonth = [...]string{"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"}

func TimeFormatMonth(t time.Time) string {
	month := enFormatMonth[t.Month()]
	return fmt.Sprintf("%d  %s  %d", t.Year(), month, t.Day())
}

func SetCaptcha(c *gin.Context) string {
	d := struct{ CaptchaId string }{captcha.NewLen(4)}
	err := captcha.WriteImage(c.Writer, d.CaptchaId, captcha.StdWidth, captcha.StdHeight)
	if err != nil {
		panic(err.Error())
	}
	return d.CaptchaId
}

// Page /**
func Page(count int, currentPage int) string {
	c := float64(count) / 8
	fmt.Printf("%f\n", c)
	countPage := math.Ceil(c)
	html := ""
	if currentPage <= 1 {
		html = "<li class=\"button\"><a href=\"javascript:;\"></a></li>"
	} else {
		up := strconv.Itoa(currentPage - 1)
		html += "<li class=\"button\"><a href=\"/article?page=" + up + "\"></a></li>"
	}
	if countPage <= 10 {
		for i := 1; i <= int(countPage); i++ {
			class := ""
			if i == currentPage{
				class = "current"
			}
			html += "<li><a class="+class+" href=\"?page=" + strconv.Itoa(i) + "\">" + strconv.Itoa(i) + "</a></li>"
		}
	}
	if currentPage == int(countPage) {
		html += "<li class=\"button\"><a href=\"javascript:;\"></a></li>"
	} else {
		up := strconv.Itoa(currentPage + 1)
		html += "<li class=\"button\"><a href=\"/article?page=" + up + "\"></a></li>"
	}
	return html
}
