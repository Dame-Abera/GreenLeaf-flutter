from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin

class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("Email is required.")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        return self.create_user(email, password, **extra_fields)

def upload_to(instance, filename):
    user_id = instance.pk or 'temp'
    return f'users/{user_id}/{filename}'

class CustomUser(AbstractBaseUser, PermissionsMixin):
    first_name = models.CharField(max_length=200, blank=True, null=True)
    last_name = models.CharField(max_length=200, blank=True, null=True)
    email = models.EmailField(max_length=250, unique=True)
    profile_image = models.ImageField(blank=True, null=True, upload_to=upload_to)
    birthdate = models.DateField(null=True, blank=True)
    gender = models.CharField(max_length=10, choices=[("Male", "Male"), ("Female", "Female")], null=True, blank=True)
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    objects = CustomUserManager()

    @property
    def is_admin(self):
        return self.is_staff or self.is_superuser

    def __str__(self):
        return self.email
