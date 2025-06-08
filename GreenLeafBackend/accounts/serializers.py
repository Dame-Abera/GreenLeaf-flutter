from rest_framework import serializers
from django.contrib.auth import authenticate
from accounts import models as my_models
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['email'] = user.email
        return token

    def validate(self, attrs):
        credentials = {
            'email': attrs.get('email'),
            'password': attrs.get('password')
        }

        user = authenticate(**credentials)

        if user is None:
            raise serializers.ValidationError("Invalid Credentials")
    
        data = super().validate(attrs)
        return data




class RegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    confirm_password = serializers.CharField(write_only=True)
    # phone_number = serializers.CharField(write_only=True)

    
    class Meta:
        model = my_models.CustomUser
        fields = ['email', 'password', 'confirm_password',]
    
    def validate(self, attrs):
        if attrs['password'] != attrs['confirm_password']:
            raise serializers.ValidationError('Password do not match.')
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('confirm_password')
        user = my_models.CustomUser.objects.create_user(**validated_data)
        return user


class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = my_models.CustomUser
        fields = ('id', 'first_name','last_name', 'birthdate', 'gender', 'email', 'phone_number', 'profile_image')
        read_only_fields = ('email',)


class UserListSerializer(serializers.ModelSerializer):
    total_plant_record = serializers.SerializerMethodField()
    total_observation_records = serializers.SerializerMethodField()

    class Meta:
        model = my_models.CustomUser
        fields = ['id', 'first_name', 'last_name', 'email', 'total_plant_record', 'total_observation_records', 'is_admin']

    def get_total_plant_record(self, obj):
        return obj.plants.all().count()
    
    def get_total_observation_records(self, obj):
        return obj.observations.all().count()
    
    