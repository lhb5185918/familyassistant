#!/bin/bash

# Family Assistant Gunicorn启动脚本

# 设置项目路径
PROJECT_DIR="/root/family-assistant"
VENV_DIR="$PROJECT_DIR/venv"

# 切换到项目目录
cd $PROJECT_DIR

# 激活虚拟环境
source $VENV_DIR/bin/activate

# 设置环境变量
export DJANGO_SETTINGS_MODULE=production_settings
export PYTHONPATH=$PROJECT_DIR:$PYTHONPATH

# 创建日志目录
mkdir -p logs

# 启动Gunicorn
exec gunicorn \
    --config gunicorn_config.py \
    FAMILY_ASSISTANT.wsgi:application 