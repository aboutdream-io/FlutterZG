from django.contrib.auth import get_user_model

User = get_user_model()


class CustomBackend(object):
    def authenticate(self, username, password):
        try:
            user = User.objects.filter(username=username) | User.objects.filter(email=username)

            if not user:
                return None

            user = user[0]

            if user.check_password(password):
                return user
            else:
                return None

        except User.DoesNotExist:
            return None

    def get_user(self, user_id):
        try:
            user = User.objects.get(id=user_id)
            if user.is_active:
                return user
            return None
        except User.DoesNotExist:
            return None
