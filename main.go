package main

import (
	"goblog/route"
)


func main() {
	err := route.Routes().Run();if err != nil {
		return 
	}
}
