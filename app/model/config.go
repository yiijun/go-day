package model

import (
	"goblog/database"
)

type Config struct {
	Id uint64
	Key string
	Value string
	Group string
}

var WebConfig = make(map[string]interface{})

func GetWebConfig() map[string]interface{}{
	list := make([]*Config, 0)
	query := database.Ins.Not("group",[]string{"dictionary"}).Find(&list)
	if query.Error !=nil{
		panic(query.Error)
	}
	for _,v  := range list{
		WebConfig[v.Key] = v.Value
	}
	return WebConfig
}
