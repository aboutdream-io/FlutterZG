from django.db import models
from django.contrib.auth.models import PermissionsMixin
from django.contrib.auth.base_user import AbstractBaseUser, BaseUserManager


class UserManager(BaseUserManager):
    use_in_migrations = True

    def create_account(self, email, username, password, **kwargs):
        if not email:
            raise ValueError('Email is required!')
        username = self.model.normalize_username(username)
        email = self.normalize_email(email)
        user = self.model(username=username, email=email, **kwargs)
        user.set_password(password)
        user.save(self.db)
        return user

    def create_user(self, email, username, password, **kwargs):
        kwargs.setdefault('is_staff', False)
        kwargs.setdefault('is_active', False)
        return self.create_account(email, username, password, **kwargs)

    def create_superuser(self, email, username, password, **kwargs):
        kwargs.setdefault('is_staff', True)
        kwargs.setdefault('is_active', True)
        kwargs.setdefault('is_superuser', True)
        return self.create_account(email, username, password, **kwargs)


class User(AbstractBaseUser, PermissionsMixin):
    email = models.EmailField(max_length=256, unique=True)
    username = models.CharField(max_length=128, unique=True, null=True, blank=True, default='')
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=False)

    first_name = models.CharField(max_length=32, null=True, blank=True)
    last_name = models.CharField(max_length=64, null=True, blank=True)
    facebook_id = models.CharField(max_length=128, null=True, blank=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    objects = UserManager()
