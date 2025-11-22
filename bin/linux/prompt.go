//go:build linux

package main

import (
	"fmt"
	"os"
	"strings"
	"syscall"
	"time"
)

func boottime() (time.Time, error) {
	var si syscall.Sysinfo_t
	if err := syscall.Sysinfo(&si); err != nil {
		return time.Now(), err
	}
	return time.Now().Add(-time.Duration(si.Uptime) * time.Second), nil
}

func calctime(start, end time.Time) (years, months, days, hours, minutes, seconds int) {
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

func prompt(y, mo, d, h, mi, s int) string {
	vals := []int{y, mo, d, h, mi, s}
	start := 0
	for start < len(vals)-3 && vals[start] == 0 {
		start++
	}
	var parts []string
	for i := start; i < len(vals); i++ {
		if i < 3 {
			parts = append(parts, fmt.Sprintf("%d", vals[i]))
		} else {
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
	y, mo, d, h, mi, s := calctime(bt, now)
	fmt.Printf("[%s] %s ", prompt(y, mo, d, h, mi, s), host)

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
