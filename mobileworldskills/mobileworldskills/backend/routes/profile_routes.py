from flask import Blueprint, request, jsonify
from db import get_db
from utils import decode_jwt
import base64

profile_bp = Blueprint('profile_bp', __name__)

@profile_bp.route('/api/profile', methods=['GET','PUT'])
def profile():
    token = request.headers.get('Authorization')
    if not token:
        return jsonify({'error': 'No token'})
    try:
        u = decode_jwt(token)
    except:
        return jsonify({'error': 'Invalid token'})
    db = get_db()
    c = db.cursor()
    if request.method=='GET':
        c.execute('select first_name,last_name,email,phone,subscribe,preferred_delivery,profile_image from users where id=%s',(u['data']['user_id'],))
        r = c.fetchone()
        if r:
            b64 = None
            if r[6]: b64 = base64.b64encode(r[6]).decode('utf-8')
            return jsonify({
                'firstName':r[0],
                'lastName':r[1],
                'email':r[2],
                'phone':r[3],
                'subscribe':bool(r[4]),
                'deliveryMethod':r[5],
                'profileImageBase64': b64
            })
        return jsonify({'error':'Not found'})
    if request.method=='PUT':
        d = request.form or request.json
        f = d.get('firstName')
        l = d.get('lastName')
        ph = d.get('phone')
        sb = d.get('subscribe')
        m = d.get('deliveryMethod')
        img = request.files.get('profileImage')
        fields = []
        vals = []
        if img:
            blob_data = img.read()
            fields.append('profile_image=%s')
            vals.append(blob_data)
        if f!=None:
            fields.append('first_name=%s')
            vals.append(f)
        if l!=None:
            fields.append('last_name=%s')
            vals.append(l)
        if ph!=None:
            fields.append('phone=%s')
            vals.append(ph)
        if sb!=None:
            fields.append('subscribe=%s')
            vals.append(sb)
        if m!=None:
            fields.append('preferred_delivery=%s')
            vals.append(m)
        if fields:
            sql = 'update users set '+','.join(fields)+' where id=%s'
            vals.append(u['data']['user_id'])
            c.execute(sql, vals)
            db.commit()
        c.execute('select first_name,last_name,email,phone,subscribe,preferred_delivery,profile_image from users where id=%s',(u['data']['user_id'],))
        r = c.fetchone()
        if r:
            b64 = None
            if r[6]: b64 = base64.b64encode(r[6]).decode('utf-8')
            return jsonify({
                'firstName':r[0],
                'lastName':r[1],
                'email':r[2],
                'phone':r[3],
                'subscribe':bool(r[4]),
                'deliveryMethod':r[5],
                'profileImageBase64': b64
            })
        return jsonify({'error':'Not found'})
