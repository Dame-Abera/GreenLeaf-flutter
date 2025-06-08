from django.shortcuts import render
from rest_framework.response import Response
from accounts import serializers as my_serializers
from rest_framework import generics, permissions, status
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.views import APIView
from django.contrib.auth import get_user_model
from . import models as my_models
from rest_framework_simplejwt.exceptions import TokenError


# Create your views here.
class RegistrationAPIView(generics.CreateAPIView):
    serializer_class = my_serializers.RegistrationSerializer
    permission_classes = [permissions.AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()  # Save and get the created user instance

        refresh = RefreshToken.for_user(user)

        return Response({
            'user': {
                'email': user.email,
            },
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        }, status=status.HTTP_201_CREATED)


class ProfileRetrieveUpdateAPIView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = my_serializers.ProfileSerializer
    authentication_classes = [JWTAuthentication,]
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = my_serializers.CustomTokenObtainPairSerializer


class UsersListAPIView(generics.ListAPIView):
    queryset = get_user_model().objects.all()
    serializer_class = my_serializers.UserListSerializer
    authentication_classes = [JWTAuthentication]
    permission_classes = [permissions.IsAdminUser]


class LogoutAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data["refresh"]
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response({"detail": "Logout successful."}, status=status.HTTP_200_OK)
        except KeyError:
            return Response({"error": "Refresh token is required."}, status=status.HTTP_400_BAD_REQUEST)
        except TokenError:
            return Response({"error": "Token is invalid or expired."}, status=status.HTTP_400_BAD_REQUEST)