package main

import (
    "encoding/json"
    "fmt"
    "net/http"
    "os"
    "time"
)

func main() {
    hostname, _ := os.Hostname()
    version := "v3"
    startTime := time.Now()

    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(map[string]string{
            "hostname": hostname,
            "version":  version,
            "time":     time.Now().Format(time.RFC3339),
            "uptime":   time.Since(startTime).String(),
        })
    })

    http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        w.Write([]byte("ok"))
    })

    http.HandleFunc("/ready", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        w.Write([]byte("ready"))
    })

    fmt.Println("Starting server on :8080")
    http.ListenAndServe(":8080", nil)
}