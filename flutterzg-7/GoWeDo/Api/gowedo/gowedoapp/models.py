from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()


def upload_image_path(instance, filename):
    return 'user_{0}/posts/{1}'.format(instance.author.id, filename)


class Post(models.Model):
    title = models.CharField(max_length=128, null=True, blank=True)
    description = models.CharField(max_length=512, null=True, blank=True)
    image = models.ImageField(upload_to=upload_image_path)
    created_at = models.DateTimeField(auto_now_add=True)
    author = models.ForeignKey(User, on_delete=models.CASCADE, default=None)

    class Meta:
        ordering = ['-created_at']
