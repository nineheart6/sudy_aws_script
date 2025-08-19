#!/bin/bash

LOG_FILE="$(date +%Y%m%d-%H%M).log"

for i in {1..12}; do
	# CPU 사용률 (%)
	cpu=$(top -bn1 | awk '/^%Cpu/ {printf "%.2f", 100 - $8}')
	# 메모리 사용률 (%)
	mem=$(free | awk '/Mem:/ {printf "%.2f", $3*100/$2}')
	# 디스크 사용률 (% 전체)
	disk=$(df -P --total -x tmpfs -x devtmpfs | awk '/total/ {printf "%.2f", $3*100/$2}')
	if [ ! -s "$LOG_FILE" ]; then
		echo -e "sec\tcpu\tmem\tdisk" >> "$LOG_FILE"
	fi
	# 데이터 기록 (탭 구분)
	echo -e "$(date +%S)\t$cpu%\t$mem%\t$disk%" >> "$LOG_FILE"
	sleep 5
done

