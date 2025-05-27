# Family Assistant 生产环境部署指南

## 服务器要求

- **操作系统**: CentOS 7/8 或 Rocky Linux 8
- **内存**: 最少 2GB RAM
- **存储**: 最少 20GB 可用空间
- **网络**: 公网IP，开放80和443端口
- **域名**: www.familyassistant.top 已解析到服务器IP

## 部署步骤

### 1. 服务器初始化

```bash
# 更新系统
sudo yum update -y

# 安装基础工具
sudo yum install -y git wget curl vim

# 关闭SELinux（可选，根据安全需求）
sudo setenforce 0
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# 配置防火墙
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

### 2. 安装Python 3.9

```bash
# 安装编译依赖
sudo yum groupinstall "Development Tools" -y
sudo yum install gcc openssl-devel bzip2-devel libffi-devel zlib-devel wget -y

# 下载并编译Python 3.9
cd /tmp
wget https://www.python.org/ftp/python/3.9.18/Python-3.9.18.tgz
tar -xzf Python-3.9.18.tgz
cd Python-3.9.18
./configure --enable-optimizations --prefix=/usr/local/python3.9
make -j $(nproc)
sudo make altinstall

# 创建软链接
sudo ln -sf /usr/local/python3.9/bin/python3.9 /usr/bin/python3.9
sudo ln -sf /usr/local/python3.9/bin/pip3.9 /usr/bin/pip3.9
```

### 3. 安装Nginx

```bash
# 安装EPEL仓库
sudo yum install -y epel-release

# 安装Nginx
sudo yum install -y nginx

# 启动并设置开机自启
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 4. 创建项目用户

```bash
# 创建专用用户
sudo useradd -m -s /bin/bash familyapp
sudo usermod -aG wheel familyapp

# 切换到项目用户
sudo su - familyapp
```

### 5. 部署项目代码

```bash
# 创建项目目录
mkdir -p /home/familyapp/projects
cd /home/familyapp/projects

# 上传项目代码到此目录
# 假设项目代码已上传到 family-assistant 目录

cd family-assistant

# 创建虚拟环境
python3.9 -m venv venv
source venv/bin/activate

# 安装依赖
pip install --upgrade pip
pip install -r requirements.txt
pip install gunicorn

# 创建必要目录
mkdir -p logs staticfiles media

# 设置环境变量
export DJANGO_SETTINGS_MODULE=production_settings

# 收集静态文件
python manage.py collectstatic --noinput

# 运行数据库迁移
python manage.py migrate
```

### 6. 配置文件部署

将以下配置文件复制到项目目录：

- `production_settings.py` - Django生产环境设置
- `gunicorn_config.py` - Gunicorn配置
- `start_gunicorn.sh` - Gunicorn启动脚本
- `family-assistant.service` - systemd服务文件
- `nginx_family_assistant.conf` - Nginx配置

### 7. 执行部署

```bash
# 设置脚本执行权限
chmod +x deploy.sh start_gunicorn.sh

# 执行部署脚本
./deploy.sh
```

### 8. 配置SSL证书（可选）

```bash
# 使用root权限执行
sudo chmod +x setup_ssl.sh
sudo ./setup_ssl.sh
```

## 服务管理

### Django应用服务

```bash
# 启动服务
sudo systemctl start family-assistant

# 停止服务
sudo systemctl stop family-assistant

# 重启服务
sudo systemctl restart family-assistant

# 查看状态
sudo systemctl status family-assistant

# 查看日志
sudo journalctl -u family-assistant -f
```

### Nginx服务

```bash
# 重启Nginx
sudo systemctl restart nginx

# 重新加载配置
sudo systemctl reload nginx

# 测试配置
sudo nginx -t

# 查看状态
sudo systemctl status nginx
```

## 日志文件位置

- **Django日志**: `/home/familyapp/projects/family-assistant/logs/django.log`
- **Gunicorn访问日志**: `/home/familyapp/projects/family-assistant/logs/gunicorn_access.log`
- **Gunicorn错误日志**: `/home/familyapp/projects/family-assistant/logs/gunicorn_error.log`
- **Nginx访问日志**: `/var/log/nginx/family_assistant_access.log`
- **Nginx错误日志**: `/var/log/nginx/family_assistant_error.log`

## 性能优化

### 1. 数据库连接池

在 `production_settings.py` 中添加：

```python
DATABASES = {
    'default': {
        # ... 其他配置
        'OPTIONS': {
            # ... 其他选项
            'CONN_MAX_AGE': 60,  # 连接池
        },
    }
}
```

### 2. 缓存配置

```python
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
    }
}
```

### 3. Gunicorn优化

根据服务器配置调整 `gunicorn_config.py` 中的worker数量：

```python
workers = multiprocessing.cpu_count() * 2 + 1
```

## 监控和维护

### 1. 系统监控

```bash
# 查看系统资源使用
htop
df -h
free -h

# 查看网络连接
netstat -tulpn | grep :80
netstat -tulpn | grep :8000
```

### 2. 应用监控

```bash
# 查看Gunicorn进程
ps aux | grep gunicorn

# 查看Django日志
tail -f /home/familyapp/projects/family-assistant/logs/django.log

# 查看Nginx访问日志
tail -f /var/log/nginx/family_assistant_access.log
```

### 3. 定期维护

```bash
# 清理日志文件（每月执行）
find /home/familyapp/projects/family-assistant/logs/ -name "*.log" -mtime +30 -delete
find /var/log/nginx/ -name "*family_assistant*" -mtime +30 -delete

# 更新系统（每月执行）
sudo yum update -y

# 备份数据库（每日执行）
mysqldump -h rm-bp1187tb295ka68e9lo.mysql.rds.aliyuncs.com -u root1 -p family_assistant > backup_$(date +%Y%m%d).sql
```

## 故障排除

### 1. 服务无法启动

```bash
# 查看详细错误信息
sudo journalctl -u family-assistant -n 50

# 检查配置文件语法
python manage.py check --settings=production_settings

# 手动启动测试
cd /home/familyapp/projects/family-assistant
source venv/bin/activate
gunicorn FAMILY_ASSISTANT.wsgi:application --config gunicorn_config.py
```

### 2. 数据库连接问题

```bash
# 测试数据库连接
python manage.py dbshell --settings=production_settings

# 检查网络连接
telnet rm-bp1187tb295ka68e9lo.mysql.rds.aliyuncs.com 3306
```

### 3. 静态文件问题

```bash
# 重新收集静态文件
python manage.py collectstatic --clear --noinput --settings=production_settings

# 检查文件权限
ls -la /home/familyapp/projects/family-assistant/staticfiles/
```

## 安全建议

1. **定期更新系统和软件包**
2. **使用强密码和密钥认证**
3. **配置防火墙规则**
4. **启用SSL/TLS加密**
5. **定期备份数据**
6. **监控系统日志**
7. **限制不必要的服务和端口**

## 联系支持

如遇到部署问题，请检查：
1. 服务器配置是否满足要求
2. 域名DNS解析是否正确
3. 防火墙和安全组设置
4. 数据库连接配置
5. 日志文件中的错误信息 