package model

import (
	"goblog/common"
	"goblog/database"
	"time"
)

type Article struct {
	Id int
	Title string
	CreateTime time.Time
	ShowTime string
}

type Row struct {
	Id int
	Title string
	Name string
	Image string
	Content string
	Click int
	CreateTime time.Time
}

// GetIndexArticle /**
func GetIndexArticle() []*Article  {
	list := make([]*Article,0)
	query := database.Ins.Order("create_time desc").Limit("10").Find(&list)
	if query.Error !=nil{
		panic(query.Error)
	}
	for _,v := range list{
		v.ShowTime = common.TimeFormatMonth(v.CreateTime)
	}
	return list
}

func GetDetailArticle(id string) []*Row  {
	row := make([]*Row,0)
	query := database.
		Ins.
		Table("go_article").
		Joins("left join go_category on go_article.category_id = go_category.id").
		Select("go_article.id,title,name,go_article.image,go_article.content,click,go_article.create_time").
		Take(&row,id)
	if query.Error !=nil{
		panic(query.Error)
	}
	return row
}

func GetListArticle(title string,currentPage int) []*Article {
	list := make([]*Article,0)
	if title != "" {
		 database.Ins.
			Where("title like ?","%"+title+"%").
			Order("weight desc,create_time desc").
			Find(&list)
	}else{
		//计算开始
		start := (currentPage - 1) * 10
		database.Ins.
			Order("weight desc,create_time desc").
			Offset(start).
			Limit(10).
			Find(&list)
	}
	for _,v := range list{
		v.ShowTime = common.TimeFormatMonth(v.CreateTime)
	}
	return  list
}

func  GetArticleCount()  int {
	var count int
	query := database.Ins.Table("go_article").Count(&count)
	if query.Error !=nil{
		panic(query.Error)
	}
	return count
}