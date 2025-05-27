# gunicorn_config.py
# Gunicorn配置文件

import multiprocessing

# 服务器socket
bind = "127.0.0.1:8000"
backlog = 2048

# 工作进程
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
accesslog = "/home/familyapp/projects/family-assistant/logs/gunicorn_access.log"
errorlog = "/home/familyapp/projects/family-assistant/logs/gunicorn_error.log"
loglevel = "info"

# 进程命名
proc_name = 'family_assistant'

# 用户和组
user = "familyapp"
group = "familyapp"

# 临时目录
tmp_upload_dir = None

# 安全
limit_request_line = 4094
limit_request_fields = 100
limit_request_field_size = 8190 