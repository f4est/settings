from flask import Blueprint, request, jsonify, Response
from db import get_db
import base64

product_bp = Blueprint('product_bp', __name__)

@product_bp.route('/api/products', methods=['GET'])
def list_products():
    db = get_db()
    c = db.cursor()
    srch = request.args.get('search','').lower()
    cats = request.args.getlist('cat')
    c.execute('select id,name,category,price,image_blob from products')
    r = c.fetchall()
    result=[]
    for x in r:
        pid,nm,ct,pr,blob_data=x
        if srch and srch not in nm.lower():
            continue
        if cats and ct not in cats:
            continue
        b64=None
        if blob_data:
            b64=base64.b64encode(blob_data).decode('utf-8')
        result.append({'id':pid,'name':nm,'category':ct,'price':float(pr),'imageBase64':b64})
    return jsonify(result)

@product_bp.route('/api/products/<int:pid>', methods=['GET'])
def product_detail(pid):
    db = get_db()
    c = db.cursor()
    c.execute('select id,name,category,price,image_blob from products where id=%s',(pid,))
    r = c.fetchone()
    if not r:
        return jsonify({'error':'Not found'}),404
    b64=None
    if r[4]:
        b64=base64.b64encode(r[4]).decode('utf-8')
    return jsonify({'id':r[0],'name':r[1],'category':r[2],'price':float(r[3]),'imageBase64':b64})
