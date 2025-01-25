package main

import (
	"fmt"
	"os"
	"strings"
	"syscall"
	"time"
)

func main() {
	cwd, _ := os.Getwd()
	host, _ := os.Hostname()
	home := os.Getenv("HOME")
	var parts []string
	if strings.HasPrefix(cwd, home) {
		cwd = "~" + cwd[len(home):]
	}
	var sysinfo syscall.Sysinfo_t
	syscall.Sysinfo(&sysinfo)
	uptime := time.Duration(sysinfo.Uptime) * time.Second
	fmt.Printf("[%d:%02d:%02d] %s ", int64(uptime.Hours()),
		int64(uptime.Minutes())%60, int64(uptime.Seconds())%60,
		host)

	parts = strings.Split(cwd, "/")
	for i, part := range parts {
		if i == len(parts)-1 {
			fmt.Printf("%s", part)
		} else {
			if len(part) != 0 {
				fmt.Printf("%c/", part[0])
			} else {
				fmt.Printf("/")
			}
		}
	}
}
