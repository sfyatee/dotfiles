package main

import (
	"fmt"
	"os"
	"strings"
	"syscall"
	"time"
	"unsafe"
)

func uptime() time.Duration {
	var boottime syscall.Timeval
	mib := []int32{1, 21} // CTL_KERN, KERN_BOOTTIME
	size := unsafe.Sizeof(boottime)
	_, _, err := syscall.Syscall6(
		syscall.SYS___SYSCTL,
		uintptr(unsafe.Pointer(&mib[0])),
		uintptr(len(mib)),
		uintptr(unsafe.Pointer(&boottime)),
		uintptr(unsafe.Pointer(&size)),
		0,
		0,
	)
	if err != 0 {
		fmt.Println("Error getting uptime:", err)
		return 0
	}
	return time.Since(time.Unix(boottime.Sec, int64(boottime.Usec)*1000))
}

func main() {
	cwd, _ := os.Getwd()
	host, _ := os.Hostname()
	home, _ := os.UserHomeDir()
	var parts []string
	if strings.HasPrefix(cwd, home) {
		cwd = "~" + cwd[len(home):]
	}
	uptime := uptime()
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
