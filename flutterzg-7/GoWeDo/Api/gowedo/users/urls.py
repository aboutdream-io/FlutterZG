from django.urls import path, include
from rest_framework import routers
from .views import UserViewSet, LoginView, FacebookLoginView, GoogleLoginView

router = routers.DefaultRouter()
router.register(r'users', UserViewSet)

urlpatterns = [
    path('login/', LoginView.as_view(), name='login'),
    path('facebook/login/', FacebookLoginView.as_view(), name='facebook_login'),
    path('google/login/', GoogleLoginView.as_view(), name='google_login'),
]

urlpatterns += router.urls
