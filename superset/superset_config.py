import os
from datetime import timedelta
from superset.config import *

# Основные настройки
SECRET_KEY = os.getenv('SUPERSET_SECRET_KEY')
SQLALCHEMY_DATABASE_URI = 'sqlite:////app/superset_home/superset.db'

# Настройки безопасности
CSRF_ENABLED = True
WTF_CSRF_ENABLED = True
WTF_CSRF_TIME_LIMIT = None  # или установите конкретное значение в секундах, например 3600