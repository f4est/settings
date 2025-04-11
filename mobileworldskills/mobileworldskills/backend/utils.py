import bcrypt
import jwt
import datetime
from config import SECRET_KEY

def hash_value(value):
    return bcrypt.hashpw(value.encode('utf-8'), bcrypt.gensalt())

def check_hash(value, hashed):
    return bcrypt.checkpw(value.encode('utf-8'), hashed.encode('utf-8'))

def encode_jwt(data):
    return jwt.encode({'data': data, 'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=2)}, SECRET_KEY, algorithm='HS256')

def decode_jwt(token):
    return jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
