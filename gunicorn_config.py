"""
Gunicorn配置文件
"""
import multiprocessing
import os

# 服务器socket
bind = "127.0.0.1:8000"
backlog = 2048

# Worker进程
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
worker_connections = 1000
timeout = 30
keepalive = 2

# 重启
max_requests = 1000
max_requests_jitter = 50
preload_app = True

# 日志
accesslog = "/root/family-assistant/logs/gunicorn_access.log"
errorlog = "/root/family-assistant/logs/gunicorn_error.log"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

# 进程命名
proc_name = 'family_assistant'

# 用户和组（root用户部署时注释掉）
# user = "root"
# group = "root"

# 临时目录
tmp_upload_dir = None

# 启用线程
threads = 2 