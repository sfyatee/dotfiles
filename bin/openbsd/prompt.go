//go:build !linux

package main

import (
	"fmt"
	"os"
	"strings"
	"syscall"
	"time"
	"unsafe"
)

func boottime() (time.Time, error) {
	var boottime syscall.Timeval
	mib := []int32{1, 21} // CTL_KERN, KERN_BOOTTIME
	size := unsafe.Sizeof(boottime)
	_, _, errno := syscall.Syscall6(
		syscall.SYS___SYSCTL,
		uintptr(unsafe.Pointer(&mib[0])),
		uintptr(len(mib)),
		uintptr(unsafe.Pointer(&boottime)),
		uintptr(unsafe.Pointer(&size)),
		0,
		0,
	)
	if errno != 0 {
		return time.Time{}, errno
	}
	return time.Unix(int64(boottime.Sec), int64(boottime.Usec)*1000), nil
}

func diffYMDHMS(start, end time.Time) (years, months, days, hours, minutes, seconds int) {
	if end.Before(start) {
		start, end = end, start
	}

	for !start.AddDate(years+1, 0, 0).After(end) {
		years++
	}
	start = start.AddDate(years, 0, 0)
	for !start.AddDate(0, months+1, 0).After(end) {
		months++
	}
	start = start.AddDate(0, months, 0)
	for !start.AddDate(0, 0, days+1).After(end) {
		days++
	}
	start = start.AddDate(0, 0, days)

	// Remaining time
	rem := end.Sub(start)
	hours = int(rem / time.Hour)
	rem -= time.Duration(hours) * time.Hour
	minutes = int(rem / time.Minute)
	rem -= time.Duration(minutes) * time.Minute
	seconds = int(rem / time.Second)

	if hours >= 24 {
		addDays := hours / 24
		days += addDays
		hours = hours % 24
	}
	return
}

// days:       6:20:59:41
// months:     2:6:20:59:41
// years:      1:2:6:20:59:41
func formatSpan(y, mo, d, h, mi, s int) string {
	vals := []int{y, mo, d, h, mi, s}
	start := 0
	for start < len(vals)-3 && vals[start] == 0 {
		start++
	}

	var parts []string
	for i := start; i < len(vals); i++ {
		if i < 3 { // Y/M/D — no zero padding
			parts = append(parts, fmt.Sprintf("%d", vals[i]))
		} else { // H/M/S — zero padded
			parts = append(parts, fmt.Sprintf("%02d", vals[i]))
		}
	}
	return strings.Join(parts, ":")
}

func main() {
	cwd, _ := os.Getwd()
	host, _ := os.Hostname()
	home, _ := os.UserHomeDir()

	if strings.HasPrefix(cwd, home) {
		cwd = "~" + cwd[len(home):]
	}
	if strings.HasSuffix(host, ".home") {
		host = strings.TrimSuffix(host, ".home")
	}
	if strings.HasSuffix(host, ".local") {
		host = strings.TrimSuffix(host, ".local")
	}

	bt, _ := boottime()

	now := time.Now()
	y, mo, d, h, mi, s := diffYMDHMS(bt, now)
	fmt.Printf("[%s] %s ", formatSpan(y, mo, d, h, mi, s), host)

	parts := strings.Split(cwd, "/")
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
	fmt.Println()
}
