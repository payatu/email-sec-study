package main

import (
    "bufio"
    "fmt"
    "log"
    "os"
)


func main() {

    sel:= [17]string{"default", "s1", "s2", "google", "k1", "k2", "mail", "mandrill", "selector1", "selector2", "smtpapi","m1", "m2", "x", "dkim", "mailjet", "cm"}

    domfile, err := os.Open("domains.txt")
    if err != nil {
        log.Fatal(err)
    }
    defer domfile.Close()

    selfile, fileErr := os.Create("selectors.txt")
    if fileErr != nil {
       fmt.Println(fileErr)
       return
    }
    defer selfile.Close()

    scanner := bufio.NewScanner(domfile)
    for scanner.Scan() {
        for i:= 0; i < 17; i++{
        fmt.Fprintf(selfile,"%[2]v._domainkey.%[1]v",scanner.Text(),sel[i])
        }
    }

    if err := scanner.Err(); err != nil {
        log.Fatal(err)
    }

}
