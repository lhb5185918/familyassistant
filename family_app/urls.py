from django.urls import path
from . import views

app_name = 'family_app'

urlpatterns = [
    path('login/', views.login, name='login'),
    path('register/', views.register, name='register'),
    path('user-info/', views.user_info, name='user_info'),
] 