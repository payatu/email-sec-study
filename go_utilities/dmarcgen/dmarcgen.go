package main

import (
    "bufio"
    "fmt"
    "log"
    "os"
)


func main() {

    domfile, err := os.Open("domains.txt")
    if err != nil {
        log.Fatal(err)
    }
    defer domfile.Close()

    dmarcfile, fileErr := os.Create("dmarc.txt")
    if fileErr != nil {
       fmt.Println(fileErr)
       return
    }
    defer dmarcfile.Close()

    scanner := bufio.NewScanner(domfile)
    for scanner.Scan() {
        fmt.Fprintf(dmarcfile,"_dmarc.%v\n",scanner.Text())
    }

    if err := scanner.Err(); err != nil {
        log.Fatal(err)
    }

}
