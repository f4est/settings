from flask import Blueprint, request, jsonify
from db import get_db
from utils import decode_jwt

order_bp = Blueprint('order_bp', __name__)

@order_bp.route('/api/customers', methods=['GET'])
def customers():
    em = request.args.get('email')
    if not em:
        return jsonify([])
    return jsonify([{'name':'Example','email':em}])

@order_bp.route('/api/orders', methods=['GET','POST'])
def orders():
    db = get_db()
    c = db.cursor()
    if request.method=='GET':
        user_id = request.args.get('user_id')
        c.execute('select id,order_date,total,status from orders where user_id=%s order by order_date desc',(user_id,))
        r = c.fetchall()
        return jsonify([{'orderId':x[0],'orderDate':str(x[1]),'total':float(x[2]),'status':x[3]} for x in r])
    token = request.headers.get('Authorization')
    try:
        decode_jwt(token)
    except:
        return jsonify({'error':'Invalid token'})
    d = request.json
    uid = d['userId']
    ttl = d['total']
    c.execute('insert into orders(user_id,order_date,total,status) values(%s,now(),%s,%s)',(uid,ttl,'CREATED'))
    db.commit()
    oid = c.lastrowid
    return jsonify({'success':True,'orderId':oid})

@order_bp.route('/api/order-items', methods=['POST'])
def order_items():
    db = get_db()
    c = db.cursor()
    token = request.headers.get('Authorization')
    try:
        decode_jwt(token)
    except:
        return jsonify({'error':'Invalid token'})
    d = request.json
    oid = d['orderId']
    its = d['items']
    for i in its:
        pid = i['productId']
        q = i['quantity']
        pr = i['price']
        c.execute('insert into order_items(order_id,product_id,quantity,price) values(%s,%s,%s,%s)',(oid,pid,q,pr))
    db.commit()
    return jsonify({'success':True})
