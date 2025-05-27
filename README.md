# FAMILY ASSISTANT

这是一个Django家庭助手项目，使用阿里云RDS MySQL数据库，通过PyMySQL进行数据库连接和操作。

## 功能特性

- ✅ 用户注册和登录
- ✅ JWT Token认证
- ✅ RESTful API接口
- ✅ MySQL数据库支持
- ✅ 中文字符集支持

## 安装和设置

### 1. 安装依赖
```bash
pip install -r requirements.txt
```

项目依赖：
- Django 4.2.21
- PyMySQL 1.1.0（用于MySQL数据库连接）
- Django REST Framework 3.16.0
- Django REST Framework Simple JWT 5.5.0

### 2. 数据库配置
项目已配置连接到阿里云RDS MySQL数据库：
- 主机: rm-bp1187tb295ka68e9lo.mysql.rds.aliyuncs.com
- 用户名: root1
- 数据库名: family_assistant
- 驱动: PyMySQL

### 3. 数据库迁移
在首次运行前，需要创建数据库表：
```bash
python manage.py makemigrations
python manage.py migrate
```

### 4. 创建超级用户（可选）
```bash
python manage.py createsuperuser
```

### 5. 运行开发服务器
```bash
python manage.py runserver
```

服务器将在 `http://localhost:8000` 启动

## API接口

### 可用接口

- `POST /api/register/` - 用户注册
- `POST /api/login/` - 用户登录（返回JWT Token）
- `GET /api/user-info/` - 获取用户信息（需要认证）
- `POST /api/token/refresh/` - 刷新Token

### 快速测试

1. **注册用户**:
```bash
curl -X POST http://localhost:8000/api/register/ \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "testpass123"}'
```

2. **用户登录**:
```bash
curl -X POST http://localhost:8000/api/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "testpass123"}'
```

3. **获取用户信息**（使用登录返回的token）:
```bash
curl -X GET http://localhost:8000/api/user-info/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

详细的API文档请查看 [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)

## 项目结构

```
FAMILY-ASSISTANT/
├── FAMILY_ASSISTANT/          # Django项目配置
│   ├── settings.py           # 项目设置
│   ├── urls.py              # 主URL配置
│   └── wsgi.py              # WSGI配置
├── family_app/               # 主应用
│   ├── views.py             # API视图
│   ├── urls.py              # 应用URL配置
│   └── models.py            # 数据模型
├── templates/                # 模板文件
├── requirements.txt          # 项目依赖
├── manage.py                # Django管理脚本
├── README.md                # 项目说明
└── API_DOCUMENTATION.md     # API文档
```

## 注意事项
- 项目使用PyMySQL作为MySQL数据库驱动，无需安装mysqlclient
- 确保阿里云RDS实例允许您的IP地址访问
- 确保数据库 `family_assistant` 已在MySQL中创建
- JWT Token有效期：Access Token 24小时，Refresh Token 7天
- 如果遇到连接问题，请检查防火墙和安全组设置 