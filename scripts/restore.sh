#!/usr/bin/env bash
# Restore Odoo from an archive produced by backup.sh.
# Usage: scripts/restore.sh ./backups/odoo-20260522-1430.tar.gz
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <backup.tar.gz>" >&2
    exit 2
fi
ARCHIVE=$1
if [ ! -f "$ARCHIVE" ]; then
    echo "archive not found: $ARCHIVE" >&2
    exit 2
fi

if [ -f .env ]; then
    set -a
    # shellcheck disable=SC1091
    source .env
    set +a
fi

: "${POSTGRES_USER:?POSTGRES_USER is required}"
: "${POSTGRES_DB:?POSTGRES_DB is required}"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
tar -xzf "$ARCHIVE" -C "$WORK"

echo "[restore] stop odoo service..."
docker compose stop odoo

echo "[restore] drop + recreate target db..."
docker compose exec -T db dropdb -U "$POSTGRES_USER" --if-exists "$POSTGRES_DB"
docker compose exec -T db createdb -U "$POSTGRES_USER" "$POSTGRES_DB"

echo "[restore] copy dump into container + pg_restore..."
docker compose cp "$WORK/odoo.dump" db:/tmp/odoo.dump
docker compose exec -T db pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" --no-owner /tmp/odoo.dump

echo "[restore] copy filestore back..."
docker compose run --rm odoo rm -rf /var/lib/odoo/filestore
docker compose cp "$WORK/filestore/." odoo:/var/lib/odoo/

docker compose start odoo
echo "[restore] OK. Tail logs with: docker compose logs -f odoo"
