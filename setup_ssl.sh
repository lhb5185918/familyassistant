#!/bin/bash

# SSL证书配置脚本
# 需要root权限运行

set -e

echo "配置SSL证书..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}错误: 此脚本需要root权限运行${NC}"
   echo "请使用: sudo ./setup_ssl.sh"
   exit 1
fi

# SSL证书目录
SSL_DIR="/etc/nginx/ssl"

echo -e "${GREEN}1. 创建SSL证书目录...${NC}"
mkdir -p $SSL_DIR

echo -e "${YELLOW}请选择SSL证书配置方式:${NC}"
echo "1) 使用已有的SSL证书文件"
echo "2) 使用Let's Encrypt自动获取证书"
echo "3) 创建自签名证书（仅用于测试）"
read -p "请输入选择 (1-3): " ssl_choice

case $ssl_choice in
    1)
        echo -e "${GREEN}使用已有SSL证书...${NC}"
        echo "请将您的SSL证书文件复制到以下位置:"
        echo "证书文件: $SSL_DIR/familyassistant.top.crt"
        echo "私钥文件: $SSL_DIR/familyassistant.top.key"
        echo ""
        read -p "证书文件是否已放置到正确位置? (y/n): " cert_ready
        if [[ $cert_ready != "y" ]]; then
            echo "请先放置证书文件，然后重新运行此脚本"
            exit 1
        fi
        ;;
    2)
        echo -e "${GREEN}使用Let's Encrypt获取证书...${NC}"
        # 安装certbot
        yum install -y epel-release
        yum install -y certbot python3-certbot-nginx
        
        # 获取证书
        certbot --nginx -d www.familyassistant.top -d familyassistant.top
        
        # 设置自动续期
        echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -
        echo "Let's Encrypt证书配置完成"
        ;;
    3)
        echo -e "${YELLOW}创建自签名证书（仅用于测试）...${NC}"
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout $SSL_DIR/familyassistant.top.key \
            -out $SSL_DIR/familyassistant.top.crt \
            -subj "/C=CN/ST=Beijing/L=Beijing/O=FamilyAssistant/CN=www.familyassistant.top"
        echo "自签名证书创建完成"
        ;;
    *)
        echo -e "${RED}无效选择${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}2. 设置证书文件权限...${NC}"
chmod 600 $SSL_DIR/familyassistant.top.key
chmod 644 $SSL_DIR/familyassistant.top.crt
chown root:root $SSL_DIR/familyassistant.top.*

echo -e "${GREEN}3. 验证证书文件...${NC}"
if [ -f "$SSL_DIR/familyassistant.top.crt" ] && [ -f "$SSL_DIR/familyassistant.top.key" ]; then
    echo "证书文件验证成功"
    openssl x509 -in $SSL_DIR/familyassistant.top.crt -text -noout | grep "Subject:"
else
    echo -e "${RED}证书文件不存在或不完整${NC}"
    exit 1
fi

echo -e "${GREEN}4. 测试Nginx配置...${NC}"
nginx -t

echo -e "${GREEN}5. 重启Nginx服务...${NC}"
systemctl restart nginx

echo -e "${GREEN}SSL证书配置完成！${NC}"
echo ""
echo -e "${YELLOW}注意事项:${NC}"
echo "1. 如果使用Let's Encrypt，证书会自动续期"
echo "2. 如果使用自签名证书，浏览器会显示安全警告"
echo "3. 建议在生产环境中使用有效的SSL证书"
echo ""
echo -e "${GREEN}测试HTTPS访问:${NC}"
echo "curl -I https://www.familyassistant.top" 