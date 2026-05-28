#!/bin/bash

# ==================================================
# 환경 변수 및 설정 정의
# ==================================================
# 환경 변수가 없을 경우를 대비한 기본값 설정 (솔바오의 환경에 맞게 수정 가능)
AGENT_HOME="${AGENT_HOME:-/home/agent-dev/agent}"
LOG_FILE="/var/log/agent-app/monitor.log"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
PROCESS_NAME="agent_app.py"  # 요구사항의 프로세스명으로 반영
PORT="15034"

# ==================================================
# 로그 로테이션 기능 (최대 10MB, 10개 파일 유지)
# ==================================================
manage_log_rotation() {
    if [ -f "$LOG_FILE" ]; then
        # 파일 크기 계산 (바이트 단위)
        FILE_SIZE=$(stat -c%s "$LOG_FILE")
        MAX_SIZE=$((10 * 1024 * 1024)) # 10MB

        if [ "$FILE_SIZE" -ge "$MAX_SIZE" ]; then
            # 기존 백업 파일 백로테이션 (9번 -> 10번, ..., 1번 -> 2번)
            for i in {9..1}; do
                if [ -f "${LOG_FILE}.$i" ]; then
                    mv "${LOG_FILE}.$i" "${LOG_FILE}.$((i+1))"
                fi
            done
            # 현재 로그를 1번으로 백업
            mv "$LOG_FILE" "${LOG_FILE}.1"
            touch "$LOG_FILE"
            chmod 660 "$LOG_FILE"
        fi
    fi
}

# ==================================================
# STEP1. 프로세스 Health Check (실패 시 종료)
# ==================================================
PID=$(pgrep -f "$PROCESS_NAME")

if [ -z "$PID" ]; then
    echo "[ERROR] process '$PROCESS_NAME' is not running" >> "$LOG_FILE"
    echo "[ERROR] process '$PROCESS_NAME' is not running"
    exit 1
fi

# ==================================================
# STEP2. TCP LISTEN 상태 확인 (실패 시 종료)
# ==================================================
if ! ss -tuln | grep -q ":$PORT "; then
    echo "[ERROR] TCP $PORT is not LISTEN" >> "$LOG_FILE"
    echo "[ERROR] TCP $PORT is not LISTEN"
    exit 1
fi

# ==================================================
# STEP3. 방화벽 상태 확인 (경고만 출력, 종료 X)
# ==================================================
UFW_INACTIVE=0
if ! sudo ufw status | grep -q "Status: active"; then
    UFW_INACTIVE=1
fi

# ==================================================
# STEP4. 시스템 자원 수집
# ==================================================
# CPU 사용률 계산 (100 - idle)
CPU=$(top -bn1 | awk '/Cpu\(s\)/ {printf "%.1f", 100 - $8}')

# 메모리 사용률 계산 (사용량 / 전체용량 * 100)
MEM=$(free | awk '/Mem:/ {printf "%.1f", $3/$2 * 100}')

# 루트(/) 디스크 사용률 수집
DISK_USED=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')

# ==================================================
# STEP5. 임계값 경고 및 로그 기록 준비
# ==================================================
CPU_INT=${CPU%.*}
MEM_INT=${MEM%.*}

# 로그 파일 용량 관리 실행
manage_log_rotation

# 로그 파일에 한 줄 기록
echo "[$TIMESTAMP] PID:${PID} CPU:${CPU}% MEM:${MEM}% DISK_USED:${DISK_USED}%" >> "$LOG_FILE"

# ==================================================
# STEP6. 실행 결과 출력 
# ==================================================
echo "====== SYSTEM MONITOR RESULT ======"
echo ""
echo "[HEALTH CHECK]"
echo "Checking process ... [OK]"
echo "Checking port ... [OK]"
if [ "$UFW_INACTIVE" -eq 1 ]; then
    echo "[WARNING] UFW is inactive"
fi
echo ""
echo "CPU Usage:${CPU}%"
echo "MEM Usage:${MEM}%"
echo "DISK Used:${DISK_USED}%"

# ==================================================
# 임계값 초과 경고 화면 출력
# ==================================================
if [ "$CPU_INT" -gt 20 ]; then
    echo "[WARNING] CPU threshold exceeded (${CPU}% > 20%)"
fi
if [ "$MEM_INT" -gt 10 ]; then
    echo "[WARNING] MEM threshold exceeded (${MEM}% > 10%)"
fi
if [ "$DISK_USED" -gt 80 ]; then
    echo "[WARNING] DISK threshold exceeded (${DISK_USED}% > 80%)"
fi
