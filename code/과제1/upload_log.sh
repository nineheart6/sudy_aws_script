# 1분 전 로그 파일을 S3에 업로드하고, 성공 시 삭제, 실패 시 메시지를 로컬에 출력

#!/usr/bin/env bash

#실패시 종료하는 구문
set -euo pipefail

# --- 1분 전 로그 파일 지정 ---
NOW_DATE_LOG="$(date --date='2 minute ago' +%Y%m%d-%H%M).log"

# --- 사용자 설정
AWS_CLI="$(which aws)"                         # aws CLI 경로 확인


# --- 파일 존재 여부 확인 ---
if [ -f "$NOW_DATE_LOG" ]; then
    # 업로드 시도
    if aws s3 cp "$NOW_DATE_LOG" 버킷명; then
        # 성공 시 로컬에서 삭제
        rm -f "$NOW_DATE_LOG"
    else
        # 실패 시 메시지 출력
        echo "$(date '+%F %T') - $NOW_DATE_LOG file upload fail"
    fi
else
    echo "$(date '+%F %T') - $NOW_DATE_LOG 파일이 존재하지 않음"
fi
