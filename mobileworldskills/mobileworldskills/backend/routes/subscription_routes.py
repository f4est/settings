from flask import Blueprint, request, jsonify
from db import get_db
from utils import decode_jwt

subscription_bp = Blueprint('subscription_bp', __name__)

@subscription_bp.route('/api/subscribe', methods=['POST'])
def subscribe():
    token = request.headers.get('Authorization')
    try:
        u = decode_jwt(token)
    except:
        return jsonify({'error':'Invalid token'})
    db = get_db()
    c = db.cursor()
    c.execute('update users set subscribe=1 where id=%s',(u['data']['user_id'],))
    db.commit()
    return jsonify({'success':True})

@subscription_bp.route('/api/unsubscribe', methods=['POST'])
def unsubscribe():
    token = request.headers.get('Authorization')
    try:
        u = decode_jwt(token)
    except:
        return jsonify({'error':'Invalid token'})
    db = get_db()
    c = db.cursor()
    c.execute('update users set subscribe=0 where id=%s',(u['data']['user_id'],))
    db.commit()
    return jsonify({'success':True})
