#!/bin/bash
# setup_ssl.sh
# SSL证书配置脚本（使用Let's Encrypt）

set -e

echo "配置SSL证书..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN="familyassistant.top"
WWW_DOMAIN="www.familyassistant.top"

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}此脚本需要root权限运行${NC}"
   exit 1
fi

# 1. 安装certbot
echo -e "${YELLOW}安装certbot...${NC}"
yum install -y epel-release
yum install -y certbot python3-certbot-nginx

# 2. 临时修改Nginx配置（移除SSL配置）
echo -e "${YELLOW}临时修改Nginx配置...${NC}"
cat > /etc/nginx/conf.d/family_assistant.conf << 'EOF'
upstream family_assistant {
    server 127.0.0.1:8000;
}

server {
    listen 80;
    server_name www.familyassistant.top familyassistant.top;

    access_log /var/log/nginx/family_assistant_access.log;
    error_log /var/log/nginx/family_assistant_error.log;

    client_max_body_size 20M;

    location /static/ {
        alias /home/familyapp/projects/family-assistant/staticfiles/;
        expires 30d;
    }

    location /media/ {
        alias /home/familyapp/projects/family-assistant/media/;
        expires 30d;
    }

    location / {
        proxy_pass http://family_assistant;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# 3. 重新加载Nginx
echo -e "${YELLOW}重新加载Nginx...${NC}"
nginx -t && systemctl reload nginx

# 4. 获取SSL证书
echo -e "${YELLOW}获取SSL证书...${NC}"
certbot --nginx -d $DOMAIN -d $WWW_DOMAIN --non-interactive --agree-tos --email your-email@example.com

# 5. 设置自动续期
echo -e "${YELLOW}设置SSL证书自动续期...${NC}"
echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -

# 6. 验证SSL配置
echo -e "${YELLOW}验证SSL配置...${NC}"
nginx -t

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ SSL证书配置成功${NC}"
    echo -e "${GREEN}✓ 网站现在支持HTTPS访问${NC}"
    echo ""
    echo "HTTPS地址: https://www.familyassistant.top"
    echo "证书自动续期已设置"
else
    echo -e "${RED}✗ SSL配置验证失败${NC}"
    exit 1
fi 