#!/bin/bash
# start_gunicorn.sh
# Gunicorn启动脚本

# 项目路径
PROJECT_DIR="/home/familyapp/projects/family-assistant"
VENV_DIR="$PROJECT_DIR/venv"

# 切换到项目目录
cd $PROJECT_DIR

# 激活虚拟环境
source $VENV_DIR/bin/activate

# 启动Gunicorn
exec gunicorn FAMILY_ASSISTANT.wsgi:application \
    --config gunicorn_config.py \
    --env DJANGO_SETTINGS_MODULE=production_settings 