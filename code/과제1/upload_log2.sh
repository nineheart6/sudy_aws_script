#!/usr/bin/env bash
# 1분 전 로그 파일을 S3에 업로드하고, 결과를 Discord 웹훅으로 알림

set -euo pipefail

# --- 사용자 설정 ---
# Discord 웹훅 URL. 스크립트 실행 전 환경 변수로 설정하는 것을 강력히 권장합니다.
# 예: export DISCORD_WEBHOOK_URL='https://discord.com/api/webhooks/...'
DISCORD_WEBHOOK_URL="https://discordapp.com/api/webhooks/"
LOG_DIR="/home/ec2-user/" # 실제 로그 파일이 있는 디렉토리 경로
S3_BUCKET="버킷명"
HOSTNAME=$() # 알림에 서버 호스트명을 추가하여 구분

# --- 1분 전 로그 파일 지정 ---
LOG_FILE_NAME="$(date --date='1 minute ago' +%Y%m%d-%H%M).log"
FULL_LOG_PATH="$LOG_DIR/$LOG_FILE_NAME"

# --- Discord 알림 전송 함수 ---
# title: 메시지 제목
# message: 메시지 본문
# color: 메시지 좌측 색상 (성공: 초록, 실패: 빨강, 정보: 파랑)
send_discord_notification() {
  local title="$1"
  local message="$2"
  local color="$3"

  # Discord Embeds 형식에 맞는 JSON 페이로드 생성
  JSON_PAYLOAD=$(cat <<EOF
{
  "username": "S3 Log Uploader",
  "embeds": [{
    "title": "$title",
    "description": "$message",
    "color": "$color",
    "footer": {
      "text": "Host: $HOSTNAME"
    },
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%S.000Z')"
  }]
}
EOF
)

  # curl로 Discord 웹훅에 POST 요청 전송
  curl -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" "$DISCORD_WEBHOOK_URL"
}


# --- 메인 로직 ---
# 파일 존재 여부 확인
if [ -f "$FULL_LOG_PATH" ]; then
    # AWS CLI 명령어 실행 및 표준 에러(stderr) 캡처
    ERROR_MSG=$(aws s3 cp "$FULL_LOG_PATH" "$S3_BUCKET" 2>&1)

    # 업로드 성공 여부 확인 ($? == 0 이면 성공)
    if [ $? -eq 0 ]; then
        # 성공 시 로컬 파일 삭제
        rm -f "$FULL_LOG_PATH"
        # Discord로 성공 알림 전송
        send_discord_notification "✅ 로그 업로드 성공" "파일 \`$LOG_FILE_NAME\` 을 S3 버킷으로 성공적으로 업로드하고 로컬에서 삭제했습니다." "65280" # 초록색
    else
        # 실패 시 Discord로 실패 알림 전송
        send_discord_notification "🚨 로그 업로드 실패" "파일 \`$LOG_FILE_NAME\` 업로드 중 오류가 발생했습니다.\n\n**에러 내용:**\n\`\`\`$ERROR_MSG\`\`\`" "16711680" # 빨간색
    fi
else
    # 파일이 존재하지 않을 경우 Discord로 알림
    send_discord_notification "ℹ️ 처리할 로그 없음" "경로에 \`$LOG_FILE_NAME\` 파일이 존재하지 않습니다." "3447003" # 파란색
fi
