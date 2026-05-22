# odoo-cai-dat-docker-ubuntu

Production-ready Odoo 19 stack chạy trên Ubuntu bằng docker-compose, Postgres 16, nginx reverse proxy + Let's Encrypt SSL.

Bài viết đầy đủ: https://odoo.nicedx.com/odoo-cai-dat-docker-ubuntu/

## Quick start

```bash
git clone https://github.com/vytharion/odoo-cai-dat-docker-ubuntu.git
cd odoo-cai-dat-docker-ubuntu
cp .env.example .env
# Sửa POSTGRES_PASSWORD + ODOO_ADMIN_PASSWD trong .env
docker compose up -d
```

Mở trình duyệt: http://your-server-ip:8069

## Lessons (theo commit)

Mỗi commit là một bước nhỏ — clone repo, `git log --reverse` rồi đọc từng commit theo thứ tự.

1. Scaffold + .env template
2. docker-compose Odoo + Postgres
3. odoo.conf production config
4. nginx reverse proxy + SSL
5. Backup + restore scripts

## License

MIT.
