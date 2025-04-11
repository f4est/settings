from flask import Blueprint, request, jsonify
from db import get_db
from utils import decode_jwt

address_bp = Blueprint('address_bp', __name__)

@address_bp.route('/api/addresses', methods=['GET','POST'])
def addresses():
    token = request.headers.get('Authorization')
    try:
        u = decode_jwt(token)
    except:
        return jsonify({'error':'Invalid token'})
    db = get_db()
    c = db.cursor()
    if request.method=='GET':
        c.execute('select id,label,full_address,preferred from addresses where user_id=%s',(u['data']['user_id'],))
        r = c.fetchall()
        return jsonify([{'id':x[0],'label':x[1],'fullAddress':x[2],'preferred':bool(x[3])} for x in r])
    d = request.json
    lb = d['label']
    fa = d['fullAddress']
    pr = d['preferred']
    if pr:
        c.execute('update addresses set preferred=0 where user_id=%s',(u['data']['user_id'],))
    c.execute('insert into addresses(user_id,label,full_address,preferred) values(%s,%s,%s,%s)',(u['data']['user_id'],lb,fa,pr))
    db.commit()
    return jsonify({'success':True})

@address_bp.route('/api/addresses/<int:a_id>', methods=['PUT','DELETE'])
def address_detail(a_id):
    token = request.headers.get('Authorization')
    try:
        u = decode_jwt(token)
    except:
        return jsonify({'error':'Invalid token'})
    db = get_db()
    c = db.cursor()
    if request.method=='PUT':
        d = request.json
        lb = d.get('label')
        fa = d.get('fullAddress')
        pr = d.get('preferred')
        if pr:
            c.execute('update addresses set preferred=0 where user_id=%s',(u['data']['user_id'],))
        fields=[]
        vals=[]
        if lb!=None:
            fields.append('label=%s')
            vals.append(lb)
        if fa!=None:
            fields.append('full_address=%s')
            vals.append(fa)
        if pr!=None:
            fields.append('preferred=%s')
            vals.append(pr)
        if fields:
            sql='update addresses set '+','.join(fields)+' where id=%s and user_id=%s'
            vals.append(a_id)
            vals.append(u['data']['user_id'])
            c.execute(sql, vals)
            db.commit()
        return jsonify({'success':True})
    c.execute('delete from addresses where id=%s and user_id=%s',(a_id,u['data']['user_id']))
    db.commit()
    return jsonify({'success':True})
