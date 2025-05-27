#!/bin/bash
# deploy.sh
# Family Assistant 一键部署脚本

set -e

echo "开始部署 Family Assistant..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 项目配置
PROJECT_NAME="family-assistant"
PROJECT_DIR="/home/familyapp/projects/$PROJECT_NAME"
NGINX_CONF="/etc/nginx/conf.d/family_assistant.conf"
SERVICE_FILE="/etc/systemd/system/family-assistant.service"

# 检查是否为root用户
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}请不要使用root用户运行此脚本${NC}"
   exit 1
fi

# 1. 设置文件权限
echo -e "${YELLOW}设置文件权限...${NC}"
chmod +x start_gunicorn.sh

# 2. 复制配置文件（需要sudo权限）
echo -e "${YELLOW}复制配置文件...${NC}"
sudo cp nginx_family_assistant.conf $NGINX_CONF
sudo cp family-assistant.service $SERVICE_FILE

# 3. 创建SSL目录（如果不存在）
echo -e "${YELLOW}创建SSL目录...${NC}"
sudo mkdir -p /etc/nginx/ssl

# 4. 设置目录权限
echo -e "${YELLOW}设置目录权限...${NC}"
sudo chown -R familyapp:familyapp $PROJECT_DIR
sudo chmod -R 755 $PROJECT_DIR/staticfiles
sudo chmod -R 755 $PROJECT_DIR/media

# 5. 测试Nginx配置
echo -e "${YELLOW}测试Nginx配置...${NC}"
sudo nginx -t

# 6. 重新加载systemd
echo -e "${YELLOW}重新加载systemd...${NC}"
sudo systemctl daemon-reload

# 7. 启动服务
echo -e "${YELLOW}启动Family Assistant服务...${NC}"
sudo systemctl enable family-assistant
sudo systemctl start family-assistant

# 8. 重启Nginx
echo -e "${YELLOW}重启Nginx...${NC}"
sudo systemctl restart nginx

# 9. 检查服务状态
echo -e "${YELLOW}检查服务状态...${NC}"
sleep 3

if sudo systemctl is-active --quiet family-assistant; then
    echo -e "${GREEN}✓ Family Assistant服务运行正常${NC}"
else
    echo -e "${RED}✗ Family Assistant服务启动失败${NC}"
    sudo systemctl status family-assistant
    exit 1
fi

if sudo systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✓ Nginx服务运行正常${NC}"
else
    echo -e "${RED}✗ Nginx服务启动失败${NC}"
    sudo systemctl status nginx
    exit 1
fi

# 10. 显示部署信息
echo -e "${GREEN}"
echo "=================================="
echo "部署完成！"
echo "=================================="
echo -e "${NC}"
echo "项目地址: http://www.familyassistant.top"
echo "API文档: http://www.familyassistant.top/api/"
echo ""
echo "服务管理命令:"
echo "  启动服务: sudo systemctl start family-assistant"
echo "  停止服务: sudo systemctl stop family-assistant"
echo "  重启服务: sudo systemctl restart family-assistant"
echo "  查看状态: sudo systemctl status family-assistant"
echo "  查看日志: sudo journalctl -u family-assistant -f"
echo ""
echo "Nginx管理命令:"
echo "  重启Nginx: sudo systemctl restart nginx"
echo "  查看状态: sudo systemctl status nginx"
echo "  测试配置: sudo nginx -t"
echo ""
echo "日志文件位置:"
echo "  Django日志: $PROJECT_DIR/logs/django.log"
echo "  Gunicorn访问日志: $PROJECT_DIR/logs/gunicorn_access.log"
echo "  Gunicorn错误日志: $PROJECT_DIR/logs/gunicorn_error.log"
echo "  Nginx访问日志: /var/log/nginx/family_assistant_access.log"
echo "  Nginx错误日志: /var/log/nginx/family_assistant_error.log"
echo ""
echo -e "${YELLOW}注意: 如需HTTPS访问，请先配置SSL证书${NC}" 