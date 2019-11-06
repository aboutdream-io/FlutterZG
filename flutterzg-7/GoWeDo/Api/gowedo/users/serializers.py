from rest_framework import serializers
from django.contrib.auth import get_user_model
from .backends import CustomBackend
from rest_framework.validators import UniqueValidator
from django.contrib.auth.password_validation import validate_password
from django.core import exceptions
from rest_framework.authtoken.models import Token

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = [
            'id',
            'email',
            'username'
        ]


class UserRegistrationSerializer(serializers.ModelSerializer):

    username = serializers.CharField(
        validators=[UniqueValidator(queryset=User.objects.all())]
    )
    email = serializers.EmailField(
        validators=[UniqueValidator(queryset=User.objects.all())]
    )
    password = serializers.CharField(min_length=8)

    def validate(self, attrs):
        password = attrs.get('password')

        errors = dict()
        try:
            validate_password(password, user=User(**attrs))
        except exceptions.ValidationError as e:
            errors['password'] = list(e.messages)

        if errors:
            raise serializers.ValidationError(errors)

        return super(UserRegistrationSerializer, self).validate(attrs)

    def create(self, validated_data):
        user = User.objects.create(
            username=validated_data['username'],
            email=validated_data['email']
        )
        user.set_password(validated_data['password'])
        user.save()
        return user

    class Meta:
        model = User
        fields = [
            'username',
            'email',
            'password'
        ]


# kopija DRF AuthTokenSerializer sa izmjenama radi potreba rada aplikacije
class UserLoginSerializer(serializers.Serializer):
    username = serializers.CharField(label='Username')
    password = serializers.CharField(
        label='Password',
        style={'input_type': 'password'},
        trim_whitespace=False
    )

    def validate(self, attrs):
        backend = CustomBackend()
        username = attrs.get('username')
        password = attrs.get('password')

        if username and password:
            user = backend.authenticate(username=username, password=password)

            if not user:
                msg = 'Unable to log in with provided credentials.'
                raise serializers.ValidationError(msg, code='authorization')
        else:
            msg = 'Must include "username/email" and "password".'
            raise serializers.ValidationError(msg, code='authorization')

        attrs['user'] = user
        return attrs


class FacebookSerializer(serializers.Serializer):
    """
        Serializer for facebook login
    """
    email = serializers.EmailField(required=True)
    name = serializers.CharField()
    first_name = serializers.CharField()
    last_name = serializers.CharField()
    id = serializers.CharField()

    def validate(self, attrs):

        email = attrs.get('email')
        first_name = attrs.get('first_name')
        last_name = attrs.get('last_name')
        facebook_id = attrs.get('id')

        try:
            # ako user postoji onda dohvati njegov token
            user = User.objects.get(email=email)

            if user:
                if user.facebook_id and user.facebook_id != facebook_id:
                    raise serializers.ValidationError('Facebook id does not match the existing one')
                token, created = Token.objects.get_or_create(user=user)
                attrs['token'] = token.key

        except User.DoesNotExist:
            # inace stvori novog usera i novi token
            username = email.split('@')[0]
            user = User.objects.create(
                username=username,
                email=email,
                first_name=first_name,
                last_name=last_name,
                facebook_id=facebook_id
            )
            user.save()
            token, created = Token.objects.get_or_create(user=user)
            attrs['token'] = token.key

        return attrs


class GoogleSerializer(serializers.Serializer):
    """
        Serializer for google login
    """
    email = serializers.EmailField(required=True)
    name = serializers.CharField()
    first_name = serializers.CharField()
    last_name = serializers.CharField()

    def validate(self, attrs):

        email = attrs.get('email')
        name = attrs.get('name')
        first_name = attrs.get('first_name')
        last_name = attrs.get('last_name')

        try:
            user = User.objects.get(email=email)

            if user:
                token, created = Token.objects.get_or_create(user=user)
                attrs['token'] = token.key

        except User.DoesNotExist:
            username = email.split('@')[0]
            user = User.objects.create(
                username=username,
                email=email,
                first_name=first_name,
                last_name=last_name
            )
            user.save()
            token, created = Token.objects.get_or_create(user=user)
            attrs['token'] = token.key

        return attrs
