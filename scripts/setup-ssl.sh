#!/usr/bin/env bash
# Bootstrap SSL via Let's Encrypt for the Odoo domain.
# Run on host (NOT inside container). Requires nginx already serving the http-only
# block on :80 with /.well-known/acme-challenge/ pointed at /var/www/certbot.
set -euo pipefail

if [ -f .env ]; then
    set -a
    # shellcheck disable=SC1091
    source .env
    set +a
fi

: "${ODOO_DOMAIN:?ODOO_DOMAIN is required (set in .env)}"
: "${ODOO_LETSENCRYPT_EMAIL:?ODOO_LETSENCRYPT_EMAIL is required (set in .env)}"

sudo mkdir -p /var/www/certbot
sudo mkdir -p /etc/letsencrypt

# Run certbot in a one-shot docker container so the host doesn't need a python venv.
sudo docker run --rm \
    -v /etc/letsencrypt:/etc/letsencrypt \
    -v /var/www/certbot:/var/www/certbot \
    certbot/certbot:v2.11.0 \
    certonly \
        --webroot \
        --webroot-path /var/www/certbot \
        --email "$ODOO_LETSENCRYPT_EMAIL" \
        --agree-tos \
        --no-eff-email \
        --non-interactive \
        --domain "$ODOO_DOMAIN"

# Render nginx template and reload.
envsubst '${ODOO_DOMAIN}' < nginx/odoo.conf | sudo tee /etc/nginx/sites-available/odoo.conf >/dev/null
sudo ln -sf /etc/nginx/sites-available/odoo.conf /etc/nginx/sites-enabled/odoo.conf
sudo nginx -t
sudo systemctl reload nginx

echo "SSL issued for $ODOO_DOMAIN. Renewal: add 'docker run ... certbot renew --quiet' to cron."
