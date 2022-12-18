package main

import (
    "fmt"
    "github.com/weppos/publicsuffix-go/publicsuffix"
    "bufio"
    "log"
    "os"
)

func main() {

    infile, err := os.Open("hosts.txt")
    if err != nil {
        log.Fatal(err)
    }
    defer infile.Close()

    outfile, fileErr := os.Create("domains.txt")
    if fileErr != nil {
       fmt.Println(fileErr)
       return
    }
    defer outfile.Close()

    scanner := bufio.NewScanner(infile)
    for scanner.Scan() {
        fin, _ := publicsuffix.Domain(scanner.Text())
        fmt.Fprintf(outfile,"%v\n",fin)
    }
}
