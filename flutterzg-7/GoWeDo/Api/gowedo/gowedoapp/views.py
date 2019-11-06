from django.shortcuts import render
from .serializers import PostSerializer
from .models import Post
from rest_framework import viewsets


class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()
    http_method_names = ['get', 'post', 'patch', 'delete']
    serializer_class = PostSerializer

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)
