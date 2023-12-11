#!/bin/sh

IDLE_TIME=$((10*1000))  # 30 minutes in milliseconds
SCRIPT="/home/alex/apps/backup.sh"
PID=0
BACKUP_COMPLETED=0

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /var/log/backups
}

while true; do
    idle=$(xprintidle)
    if [ $idle -ge $IDLE_TIME ]; then
        if [ $BACKUP_COMPLETED -eq 0 ] && ([ $PID -eq 0 ] || ! kill -0 $PID 2>/dev/null); then
            log "System idle, starting backup..."
            $SCRIPT &
            PID=$!
            BACKUP_COMPLETED=1
            log "Backup started with PID $PID"
        fi
    else
        if [ $PID -ne 0 ] && kill -0 $PID 2>/dev/null; then
            log "System active, stopping backup..."
            kill -TERM $PID
            wait $PID
            EXIT_STATUS=$?
            if [ $EXIT_STATUS -ne 0 ]; then
                log "Backup process terminated with failure"
                BACKUP_COMPLETED=0
            else
                log "Backup process terminated successfully"
            fi
            PID=0
        fi
    fi
    sleep 2
done

