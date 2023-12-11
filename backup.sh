#!/usr/bin/env sh

echo "------------STARTING BACKUP----------------------"
USUAL_NETWORK_IP="192.168.8.100"

if ! ping -c 1 -W 1 "$USUAL_NETWORK_IP" >/dev/null 2>&1; then
    echo "Not connected to the usual network. Will make no automatic backup."
    exit 0
fi

rsync -aHAXS -e "ssh -i /home/alex/.ssh/keys/id_ed25519.backup -F /home/alex/.ssh/config" --progress --exclude-from='/home/alex/.rsyncignore' /home/alex alex@backup:/mnt/data-01-a/home
echo "=============BACKUP FINISHED======================"
