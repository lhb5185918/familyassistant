from django.shortcuts import render
from django.contrib.auth import authenticate
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.models import User

# Create your views here.

@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """
    用户登录接口
    """
    username = request.data.get('username')
    password = request.data.get('password')
    
    if not username or not password:
        return Response({
            'success': False,
            'message': '用户名和密码不能为空'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # 验证用户
    user = authenticate(username=username, password=password)
    
    if user is not None:
        if user.is_active:
            # 生成JWT token
            refresh = RefreshToken.for_user(user)
            access_token = refresh.access_token
            
            return Response({
                'success': True,
                'message': '登录成功',
                'data': {
                    'user_id': user.id,
                    'username': user.username,
                    'access_token': str(access_token),
                    'refresh_token': str(refresh),
                    'token_type': 'Bearer'
                }
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'success': False,
                'message': '账户已被禁用'
            }, status=status.HTTP_401_UNAUTHORIZED)
    else:
        return Response({
            'success': False,
            'message': '用户名或密码错误'
        }, status=status.HTTP_401_UNAUTHORIZED)


@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    """
    用户注册接口
    """
    username = request.data.get('username')
    password = request.data.get('password')
    email = request.data.get('email', '')
    
    if not username or not password:
        return Response({
            'success': False,
            'message': '用户名和密码不能为空'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # 检查用户名是否已存在
    if User.objects.filter(username=username).exists():
        return Response({
            'success': False,
            'message': '用户名已存在'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        # 创建用户
        user = User.objects.create_user(
            username=username,
            password=password,
            email=email
        )
        
        return Response({
            'success': True,
            'message': '注册成功',
            'data': {
                'user_id': user.id,
                'username': user.username
            }
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': f'注册失败: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
def user_info(request):
    """
    获取当前用户信息接口（需要认证）
    """
    user = request.user
    return Response({
        'success': True,
        'data': {
            'user_id': user.id,
            'username': user.username,
            'email': user.email,
            'is_staff': user.is_staff,
            'date_joined': user.date_joined
        }
    }, status=status.HTTP_200_OK)
