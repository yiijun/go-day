package database

import (
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/jinzhu/gorm"
	"goblog/config"
)

var Ins *gorm.DB

var err error

func init() {
	//
	dsn := fmt.Sprintf("%s:%s@(%s:%s)/%s?charset=%s&parseTime=%s&loc=%s",
		config.Conf.Mysql.User,
		config.Conf.Mysql.Password,
		config.Conf.Mysql.Host,
		config.Conf.Mysql.Port,
		config.Conf.Mysql.DbName,
		config.Conf.Mysql.CharSet,
		config.Conf.Mysql.ParseTime,
		config.Conf.Mysql.Loc,
	)

	Ins, err = gorm.Open("mysql", dsn)

	if err!= nil{
		panic(err)
	}

	Ins.SingularTable(true)

	//设置前缀
	gorm.DefaultTableNameHandler = func(db *gorm.DB, defaultTableName string) string {
		return "go_"+defaultTableName
	}

	Ins.LogMode(true)
}

