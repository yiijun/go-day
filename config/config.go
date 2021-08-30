package config

import (
	"github.com/joho/godotenv"
	"gopkg.in/yaml.v2"
	"io/ioutil"
	"log"
	"os"
)

//加载配置文件

type mysql struct {
	User     string `yaml:"user"`
	Password string `yaml:"password"`
	Host     string `yaml:"host"`
	Port     string `yaml:"port"`
	CharSet  string `yaml:"charset"`
	DbName string `yaml:"dbname"`
	ParseTime string `yaml:"parse_time"`
	Loc string `yaml:"loc"`
}

type app struct {
	NAME string `yaml:"name"`
}

type config struct {
	Mysql mysql `yaml:"mysql"`
	App   app   `yaml:"app"`
}

var Conf *config

func init() {
	if err := godotenv.Load(".env"); err != nil {
		log.Fatal(err)
	}
	//读取环境
	env := os.Getenv("ENV")
	yamFile, err := ioutil.ReadFile(env + ".yaml")

	if err != nil {
		log.Fatalf("yamlFile.Get err #%v ", err)
	}
	//解析配置
	if err := yaml.Unmarshal(yamFile, &Conf); err != nil {
		log.Fatalf("yaml Unmarshal: #%v", err)
	}
}
