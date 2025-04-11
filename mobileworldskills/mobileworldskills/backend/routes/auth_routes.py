from flask import Blueprint, request, jsonify
from db import get_db
from utils import hash_value, check_hash, encode_jwt

auth_bp = Blueprint('auth_bp', __name__)

@auth_bp.route('/api/register', methods=['POST'])
def register():
    db = get_db()
    c = db.cursor()
    d = request.json
    e = d['email']
    p = d['password']
    f = d['firstName']
    l = d['lastName']
    ph = d['phone']
    s = d['subscribe']
    sq = d['secretQuestion']
    sa = d['secretAnswer']
    m = d['deliveryMethod']
    c.execute('insert into users(email,password,first_name,last_name,phone,subscribe,secret_question,secret_answer,preferred_delivery) values(%s,%s,%s,%s,%s,%s,%s,%s,%s)', (e, hash_value(p), f, l, ph, s, sq, hash_value(sa), m))
    db.commit()
    return jsonify({'success': True})

@auth_bp.route('/api/login', methods=['POST'])
def login():
    db = get_db()
    c = db.cursor()
    d = request.json
    e = d['email']
    p = d['password']
    c.execute('select id, password from users where email=%s', (e,))
    r = c.fetchone()
    if r and check_hash(p, r[1]):
        t = encode_jwt({'user_id': r[0]})
        return jsonify({'token': t})
    return jsonify({'error': 'Invalid credentials'})

@auth_bp.route('/api/forgot-password', methods=['POST'])
def forgot_password():
    db = get_db()
    c = db.cursor()
    d = request.json
    e = d['email']
    c.execute('select secret_question from users where email=%s',(e,))
    r = c.fetchone()
    if r:
        return jsonify({'secretQuestion': r[0]})
    return jsonify({'error': 'Email not found'})

@auth_bp.route('/api/reset-password', methods=['POST'])
def reset_password():
    db = get_db()
    c = db.cursor()
    d = request.json
    e = d['email']
    a = d['secretAnswer']
    n = d.get('newPassword')
    c.execute('select id, secret_answer from users where email=%s',(e,))
    r = c.fetchone()
    if r and check_hash(a, r[1]):
        if n:
            c.execute('update users set password=%s where id=%s',(hash_value(n), r[0]))
            db.commit()
            return jsonify({'success': True})
        return jsonify({'verified': True})
    return jsonify({'error': 'Wrong answer'})
