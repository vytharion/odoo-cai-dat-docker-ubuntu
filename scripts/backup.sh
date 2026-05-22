#!/usr/bin/env bash
# Backup Odoo: dumps postgres + tars filestore.
# Output: ./backups/odoo-YYYYMMDD-HHMM.tar.gz
set -euo pipefail

if [ -f .env ]; then
    set -a
    # shellcheck disable=SC1091
    source .env
    set +a
fi

: "${POSTGRES_USER:?POSTGRES_USER is required}"
: "${POSTGRES_DB:?POSTGRES_DB is required}"

STAMP=$(date +%Y%m%d-%H%M)
OUT_DIR=./backups
mkdir -p "$OUT_DIR"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

echo "[backup] dump postgres..."
docker compose exec -T db pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc -f /tmp/odoo.dump
docker compose cp db:/tmp/odoo.dump "$WORK/odoo.dump"

echo "[backup] copy filestore..."
docker compose cp odoo:/var/lib/odoo/. "$WORK/filestore"

ARCHIVE="$OUT_DIR/odoo-$STAMP.tar.gz"
tar -czf "$ARCHIVE" -C "$WORK" odoo.dump filestore

SIZE=$(du -h "$ARCHIVE" | cut -f1)
echo "[backup] OK → $ARCHIVE ($SIZE)"
