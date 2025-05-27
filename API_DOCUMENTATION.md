# Family Assistant API 文档

## 基础信息

- **基础URL**: `http://localhost:8000/api/`
- **认证方式**: JWT Bearer Token
- **数据格式**: JSON

## 认证相关接口

### 1. 用户注册

**接口地址**: `POST /api/register/`

**请求参数**:
```json
{
    "username": "用户名",
    "password": "密码",
    "email": "邮箱地址（可选）"
}
```

**响应示例**:
```json
{
    "success": true,
    "message": "注册成功",
    "data": {
        "user_id": 1,
        "username": "testuser"
    }
}
```

### 2. 用户登录

**接口地址**: `POST /api/login/`

**请求参数**:
```json
{
    "username": "用户名",
    "password": "密码"
}
```

**成功响应**:
```json
{
    "success": true,
    "message": "登录成功",
    "data": {
        "user_id": 1,
        "username": "testuser",
        "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
        "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
        "token_type": "Bearer"
    }
}
```

**错误响应**:
```json
{
    "success": false,
    "message": "用户名或密码错误"
}
```

### 3. 获取用户信息

**接口地址**: `GET /api/user-info/`

**请求头**:
```
Authorization: Bearer <access_token>
```

**响应示例**:
```json
{
    "success": true,
    "data": {
        "user_id": 1,
        "username": "testuser",
        "email": "test@example.com",
        "is_staff": false,
        "date_joined": "2024-01-01T00:00:00Z"
    }
}
```

### 4. 刷新Token

**接口地址**: `POST /api/token/refresh/`

**请求参数**:
```json
{
    "refresh": "refresh_token_here"
}
```

**响应示例**:
```json
{
    "access": "new_access_token_here"
}
```

## 使用示例

### 使用curl测试登录接口

```bash
# 注册用户
curl -X POST http://localhost:8000/api/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "testpass123",
    "email": "test@example.com"
  }'

# 用户登录
curl -X POST http://localhost:8000/api/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "testpass123"
  }'

# 获取用户信息（需要先登录获取token）
curl -X GET http://localhost:8000/api/user-info/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

### 使用Python requests测试

```python
import requests

# 基础URL
BASE_URL = "http://localhost:8000/api"

# 注册用户
register_data = {
    "username": "testuser",
    "password": "testpass123",
    "email": "test@example.com"
}
response = requests.post(f"{BASE_URL}/register/", json=register_data)
print("注册结果:", response.json())

# 用户登录
login_data = {
    "username": "testuser",
    "password": "testpass123"
}
response = requests.post(f"{BASE_URL}/login/", json=login_data)
login_result = response.json()
print("登录结果:", login_result)

# 获取access_token
if login_result.get('success'):
    access_token = login_result['data']['access_token']
    
    # 获取用户信息
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get(f"{BASE_URL}/user-info/", headers=headers)
    print("用户信息:", response.json())
```

## Token说明

- **Access Token**: 用于API认证，有效期24小时
- **Refresh Token**: 用于刷新Access Token，有效期7天
- **使用方式**: 在请求头中添加 `Authorization: Bearer <access_token>`

## 错误码说明

- **200**: 请求成功
- **201**: 创建成功
- **400**: 请求参数错误
- **401**: 认证失败
- **500**: 服务器内部错误 