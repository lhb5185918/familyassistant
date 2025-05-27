# Family Assistant - Root用户部署指南

## 前提条件

确保您的CentOS服务器已安装：
- ✅ Python 3.9
- ✅ Nginx
- ✅ 已下载SSL证书文件

## 快速部署步骤

### 第一步：准备项目目录
```bash
# 使用root用户登录服务器
cd /root

# 将项目文件上传到 /root/family-assistant 目录
# 确保所有配置文件都在项目根目录下
```

### 第二步：配置防火墙
```bash
# 开放HTTP和HTTPS端口
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
```

### 第三步：执行自动部署
```bash
cd /root/family-assistant

# 设置脚本执行权限
chmod +x deploy.sh

# 执行部署脚本（已配置为root用户）
./deploy.sh
```

### 第四步：配置SSL证书
```bash
# 设置SSL脚本执行权限
chmod +x setup_ssl.sh

# 执行SSL配置脚本
./setup_ssl.sh
```

## 项目目录结构

部署后的目录结构：
```
/root/family-assistant/
├── FAMILY_ASSISTANT/          # Django项目主目录
├── family_app/                # Django应用
├── templates/                 # 模板文件
├── venv/                      # Python虚拟环境
├── logs/                      # 日志文件
├── staticfiles/               # 静态文件（自动生成）
├── media/                     # 媒体文件
├── production_settings.py     # 生产环境配置
├── gunicorn_config.py         # Gunicorn配置
├── start_gunicorn.sh          # Gunicorn启动脚本
├── family-assistant.service   # systemd服务文件
├── nginx_family_assistant.conf # Nginx配置
├── deploy.sh                  # 部署脚本
├── setup_ssl.sh               # SSL配置脚本
├── requirements.txt           # Python依赖
└── manage.py                  # Django管理脚本
```

## 服务管理

### Django应用服务
```bash
# 启动服务
systemctl start family-assistant

# 停止服务
systemctl stop family-assistant

# 重启服务
systemctl restart family-assistant

# 查看状态
systemctl status family-assistant

# 查看日志
journalctl -u family-assistant -f
```

### Nginx服务
```bash
# 重启Nginx
systemctl restart nginx

# 重新加载配置
systemctl reload nginx

# 测试配置
nginx -t

# 查看状态
systemctl status nginx
```

## 重要配置说明

### 1. 服务器IP配置
在 `production_settings.py` 中添加您的服务器IP：
```python
ALLOWED_HOSTS = [
    'www.familyassistant.top',
    'familyassistant.top',
    'localhost',
    '127.0.0.1',
    'YOUR_SERVER_IP',  # 添加您的服务器IP
]
```

### 2. SSL证书配置
SSL证书文件应放置在：
- 证书文件：`/etc/nginx/ssl/familyassistant.top.crt`
- 私钥文件：`/etc/nginx/ssl/familyassistant.top.key`

### 3. 数据库连接
项目已配置连接阿里云RDS MySQL，确保：
- 数据库白名单包含您的服务器IP
- 网络连接正常

## 日志文件位置

- **Django应用日志**：`/root/family-assistant/logs/django.log`
- **Gunicorn访问日志**：`/root/family-assistant/logs/gunicorn_access.log`
- **Gunicorn错误日志**：`/root/family-assistant/logs/gunicorn_error.log`
- **Nginx访问日志**：`/var/log/nginx/family_assistant_access.log`
- **Nginx错误日志**：`/var/log/nginx/family_assistant_error.log`

## 故障排除

### 1. 检查服务状态
```bash
# 检查Django服务
systemctl status family-assistant

# 检查Nginx服务
systemctl status nginx

# 检查端口占用
netstat -tulpn | grep :80
netstat -tulpn | grep :443
netstat -tulpn | grep :8000
```

### 2. 查看详细日志
```bash
# Django服务日志
journalctl -u family-assistant -n 50

# 应用日志
tail -f /root/family-assistant/logs/django.log

# Nginx错误日志
tail -f /var/log/nginx/error.log
```

### 3. 手动测试Django
```bash
cd /root/family-assistant
source venv/bin/activate
export DJANGO_SETTINGS_MODULE=production_settings
python manage.py runserver 0.0.0.0:8000
```

## 访问地址

部署完成后访问：
- **HTTP**：http://www.familyassistant.top （自动重定向到HTTPS）
- **HTTPS**：https://www.familyassistant.top

## 安全注意事项

由于使用root用户部署，请注意：

1. **文件权限**：确保敏感文件权限正确设置
2. **防火墙**：只开放必要的端口（80, 443）
3. **SSL证书**：使用有效的SSL证书保护数据传输
4. **定期更新**：定期更新系统和依赖包
5. **备份**：定期备份重要数据和配置文件

## 更新部署

如需更新代码：
```bash
cd /root/family-assistant

# 停止服务
systemctl stop family-assistant

# 更新代码（git pull 或重新上传文件）

# 激活虚拟环境
source venv/bin/activate

# 安装新依赖（如有）
pip install -r requirements.txt

# 收集静态文件
export DJANGO_SETTINGS_MODULE=production_settings
python manage.py collectstatic --noinput

# 运行数据库迁移（如有）
python manage.py migrate

# 重启服务
systemctl start family-assistant
systemctl restart nginx
``` 