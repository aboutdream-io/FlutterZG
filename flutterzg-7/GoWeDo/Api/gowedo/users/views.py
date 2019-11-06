from django.shortcuts import render
from django.contrib.auth import get_user_model
from django.conf import settings
from rest_framework.authtoken.models import Token
from rest_framework import viewsets, status
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.schemas import coreapi, ManualSchema
from rest_framework.views import APIView
from rest_framework.compat import coreapi, coreschema
from rest_framework import parsers, renderers
from .serializers import *

from google.oauth2 import id_token, credentials, service_account
from google.auth.transport import requests
from google_auth_oauthlib.flow import Flow

import facebook

User = get_user_model()


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    http_method_names = ['get', 'post', 'put', 'patch', 'delete']
    permission_classes = [AllowAny]

    @action(methods=['post'], detail=False, permission_classes=[AllowAny], url_path='registration')
    def register(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            user.is_active = True
            user.save()
            if user:
                return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# kopija DRF ObtainAuthToken
class LoginView(APIView):
    throttle_classes = ()
    permission_classes = ()
    parser_classes = (parsers.FormParser, parsers.MultiPartParser, parsers.JSONParser,)
    renderer_classes = (renderers.JSONRenderer,)
    serializer_class = UserLoginSerializer
    if coreapi is not None and coreschema is not None:
        schema = ManualSchema(
            fields=[
                coreapi.Field(
                    name="username",
                    required=False,
                    location='form',
                    schema=coreschema.String(
                        title="Username",
                        description="Valid username for authentication",
                    ),
                ),
                coreapi.Field(
                    name="password",
                    required=True,
                    location='form',
                    schema=coreschema.String(
                        title="Password",
                        description="Valid password for authentication",
                    ),
                ),
            ],
            encoding="application/json",
        )

    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(data=request.data,
                                           context={'request': request})
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        token, created = Token.objects.get_or_create(user=user)
        return Response({'token': token.key})


class FacebookLoginView(APIView):
    # provjerim po mailu postoji li korisnik u bazi
    # ako postoji dohvatim token i vratim ga
    # inace stvorim token i spremim usera

    permission_classes = [AllowAny]
    serializer_class = FacebookSerializer

    def post(self, request, *args, **kwargs):
        token = request.data['access_token']
        try:
            graph = facebook.GraphAPI(access_token=token, version=settings.FACEBOOK_GRAPH_VERSION)
            user_info = graph.get_object(
                "me?fields=birthday,email,gender,name,first_name,last_name"
            )
            serializer = self.serializer_class(data=user_info)
            if serializer.is_valid(raise_exception=True):
                token = serializer.validated_data['token']
                return Response({'token': token})
            return Response(serializer.errors)

        except exceptions.ValidationError:
            raise serializers.ValidationError('Invalid access token')


class GoogleLoginView(APIView):
    # ista stvar kao i za facebook

    permission_classes = [AllowAny]
    serializer_class = GoogleSerializer

    def post(self, request, *args, **kwargs):
        token = request.data['google_id_token']

        # info = id_token.verify_firebase_token(
        #     token,
        #     requests.Request(),
        #     '1075917403216-46hiu6fd8shlrcruj85smteh9ik97o1j.apps.googleusercontent.com'
        # )

        info = id_token.verify_oauth2_token(
            token,
            requests.Request(),
            '1075917403216-46hiu6fd8shlrcruj85smteh9ik97o1j.apps.googleusercontent.com'
        )
        data = dict()

        data['email'] = info['email']
        data['name'] = info['name']
        data['first_name'] = info['given_name']
        data['last_name'] = info['family_name']

        serializer = self.serializer_class(data=data)
        if serializer.is_valid(raise_exception=True):
            token = serializer.validated_data['token']
            return Response({'token': token})
        return Response(serializer.errors)

