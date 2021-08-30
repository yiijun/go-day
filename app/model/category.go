package model

import (
	"goblog/database"
)

type Category struct {
	Id uint64
	Name string
	Url string
	Image string
	Keyword string
	Description string
	Content string
	CreateTime string
}

func GetCategoryList()  []*Category {
	list := make([]*Category,0)
	query := database.Ins.Order("weigh asc").Find(&list)
	if query.Error !=nil{
		panic(query.Error)
	}
	return list
}

func GetCategoryByRoute(route string) []*Category  {
	row :=  make([]*Category,0)
	query :=  database.Ins.Where("url = ?",route).Take(&row)
	if query.Error !=nil{
		panic(query.Error)
	}
	return row
}