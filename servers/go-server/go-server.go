package main

import (
    "fmt"
    "os"
    "net/http"
    "time"
    "math/rand"
    "log"
)

var port string

func helloHandler(w http.ResponseWriter, r *http.Request) {
    randSleepDuration := time.Duration(rand.Intn(3))
    time.Sleep(time.Duration(randSleepDuration) * time.Second)

    log.Printf("%s %s\n", r.Method, r.URL)

    fmt.Fprintf(w, "Go Server: %s!", port)
}

func main() {
    port = "10000"

    args := os.Args[1:]
    if len(args) == 1 {
        port = args[0]
    }
    addr := fmt.Sprintf("localhost:%s", port)

    mux := http.NewServeMux()
    mh := http.HandlerFunc(helloHandler)
    mux.Handle("/", mh)

    log.Printf("Go-Server listening on port %s\n", port)

    http.ListenAndServe(addr, mux)
}
