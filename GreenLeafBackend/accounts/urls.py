from django.urls import path
from . import views
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('api/token/', views.CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/register/', views.RegistrationAPIView.as_view(), name='register'),
    path('api/profile/', views.ProfileRetrieveUpdateAPIView.as_view(), name='profile-update'),
    path('api/users/list/', views.UsersListAPIView.as_view(), name='users-list'),
    path('api/logout/', views.LogoutAPIView.as_view(), name='logout')
]