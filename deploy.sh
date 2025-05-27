#!/bin/bash

# Family Assistant 部署脚本
# 使用方法: ./deploy.sh

set -e  # 遇到错误立即退出

echo "开始部署 Family Assistant..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 项目配置
PROJECT_NAME="family-assistant"
PROJECT_DIR="/root/$PROJECT_NAME"
VENV_DIR="$PROJECT_DIR/venv"
SERVICE_NAME="family-assistant"

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}错误: 此脚本需要root权限运行${NC}"
   echo "请使用root用户运行此脚本"
   exit 1
fi

echo -e "${GREEN}1. 检查项目目录...${NC}"
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}错误: 项目目录不存在: $PROJECT_DIR${NC}"
    exit 1
fi

cd $PROJECT_DIR

echo -e "${GREEN}2. 创建虚拟环境...${NC}"
if [ ! -d "$VENV_DIR" ]; then
    python3.9 -m venv venv
    echo "虚拟环境创建完成"
else
    echo "虚拟环境已存在"
fi

echo -e "${GREEN}3. 激活虚拟环境并安装依赖...${NC}"
source $VENV_DIR/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
pip install gunicorn

echo -e "${GREEN}4. 创建必要目录...${NC}"
mkdir -p logs staticfiles media

echo -e "${GREEN}5. 设置环境变量...${NC}"
export DJANGO_SETTINGS_MODULE=production_settings

echo -e "${GREEN}6. 收集静态文件...${NC}"
python manage.py collectstatic --noinput

echo -e "${GREEN}7. 运行数据库迁移...${NC}"
python manage.py migrate

echo -e "${GREEN}8. 设置文件权限...${NC}"
chmod +x start_gunicorn.sh

echo -e "${GREEN}9. 配置systemd服务...${NC}"
# 复制服务文件到系统目录
cp family-assistant.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable $SERVICE_NAME

echo -e "${GREEN}10. 配置Nginx...${NC}"
# 复制Nginx配置文件
cp nginx_family_assistant.conf /etc/nginx/conf.d/
# 测试Nginx配置
nginx -t

echo -e "${GREEN}11. 启动服务...${NC}"
# 启动Django应用
systemctl start $SERVICE_NAME
systemctl status $SERVICE_NAME --no-pager

# 重启Nginx
systemctl restart nginx
systemctl status nginx --no-pager

echo -e "${GREEN}部署完成！${NC}"
echo -e "${YELLOW}请注意:${NC}"
echo "1. 确保SSL证书已正确配置在 /etc/nginx/ssl/ 目录下"
echo "2. 检查防火墙设置，确保80和443端口已开放"
echo "3. 确保域名已正确解析到服务器IP"
echo ""
echo -e "${GREEN}服务管理命令:${NC}"
echo "查看Django服务状态: systemctl status $SERVICE_NAME"
echo "重启Django服务: systemctl restart $SERVICE_NAME"
echo "查看Django日志: journalctl -u $SERVICE_NAME -f"
echo "查看应用日志: tail -f $PROJECT_DIR/logs/django.log"
echo ""
echo -e "${GREEN}访问地址:${NC}"
echo "HTTP: http://www.familyassistant.top (将重定向到HTTPS)"
echo "HTTPS: https://www.familyassistant.top" 