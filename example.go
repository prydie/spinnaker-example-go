package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
)

// Version is the semvar version string for the application.
const Version = "1.0.0"

func sayHello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello to the world!")
}

func main() {
	version := flag.Bool("v", false, "prints current spinnaker-example version")
	flag.Parse()
	if *version {
		fmt.Println(Version)
		os.Exit(0)
	}

	http.HandleFunc("/", sayHello)           // set router
	err := http.ListenAndServe(":8080", nil) // set listen port
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
