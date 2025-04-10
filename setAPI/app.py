from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import timedelta
import func

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:password@localhost/win10croassantdb'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

class Product(db.Model):
    __tablename__ = 'Products'
    ProductId = db.Column(db.Integer, primary_key=True)
    ProductName = db.Column(db.String(100), nullable=False)
    Category = db.Column(db.String(50), nullable=False)
    Price = db.Column(db.Float, nullable=False)
    Cost = db.Column(db.Float, nullable=False)
    Description = db.Column(db.Text)
    Seasonal = db.Column(db.Boolean, nullable=False)
    Active = db.Column(db.Boolean, nullable=False)
    IntroducedDate = db.Column(db.Date, nullable=False)
    Ingredients = db.Column(db.Text)

class Customer(db.Model):
    __tablename__ = 'Customers'
    CustomerId = db.Column(db.Integer, primary_key=True)
    FirstName = db.Column(db.String(50), nullable=False)
    LastName = db.Column(db.String(50), nullable=False)
    Age = db.Column(db.Integer)
    Gender = db.Column(db.Enum('M', 'F', 'O'))
    PostalCode = db.Column(db.String(10))
    Email = db.Column(db.String(100), unique=True)
    PhoneNumber = db.Column(db.String(20))
    MembershipStatus = db.Column(db.String(20), nullable=False, default='Basic')
    JoinDate = db.Column(db.Date)
    LastPurchaseDate = db.Column(db.Date)
    TotalSpending = db.Column(db.Float, nullable=False, default=0.0)
    AverageOrderValue = db.Column(db.Float)
    Frequency = db.Column(db.String(50))
    PreferredCategory = db.Column(db.String(50))
    Churned = db.Column(db.Boolean)

class Order(db.Model):
    __tablename__ = 'Orders'
    TransactionId = db.Column(db.Integer, primary_key=True)
    CustomerId = db.Column(db.Integer, db.ForeignKey('Customers.CustomerId'), nullable=False)
    OrderDate = db.Column(db.DateTime, nullable=False)
    TotalAmount = db.Column(db.Float, nullable=False)
    Status = db.Column(db.String(20), nullable=False, default='Pending')
    PaymentMethod = db.Column(db.String(50), nullable=False)
    Channel = db.Column(db.String(20), nullable=False)
    StoreId = db.Column(db.Integer)
    PromotionId = db.Column(db.Integer)
    DiscountAmount = db.Column(db.Float)

class OrderItem(db.Model):
    __tablename__ = 'OrderItems'
    OrderItemId = db.Column(db.Integer, primary_key=True)
    TransactionId = db.Column(db.Integer, db.ForeignKey('Orders.TransactionId'), nullable=False)
    ProductId = db.Column(db.Integer, db.ForeignKey('Products.ProductId'), nullable=False)
    Quantity = db.Column(db.Integer, nullable=False)
    Price = db.Column(db.Float, nullable=False)

@app.route('/api/products', methods=['GET'])
def get_products():
    data = Product.query.all()
    result = []
    for p in data:
        result.append({
            'ProductId': p.ProductId,
            'ProductName': p.ProductName,
            'Category': p.Category,
            'Price': p.Price,
            'Cost': p.Cost,
            'Description': p.Description,
            'Seasonal': p.Seasonal,
            'Active': p.Active,
            'IntroducedDate': p.IntroducedDate.isoformat(),
            'Ingredients': p.Ingredients
        })
    return jsonify(result), 200

@app.route('/api/products/<int:pid>', methods=['GET'])
def get_product(pid):
    p = Product.query.get(pid)
    if not p:
        return jsonify({'error': 'Not found'}), 404
    return jsonify({
        'ProductId': p.ProductId,
        'ProductName': p.ProductName,
        'Category': p.Category,
        'Price': p.Price,
        'Cost': p.Cost,
        'Description': p.Description,
        'Seasonal': p.Seasonal,
        'Active': p.Active,
        'IntroducedDate': p.IntroducedDate.isoformat(),
        'Ingredients': p.Ingredients
    }), 200

@app.route('/api/products', methods=['POST'])
def create_product():
    d = request.json
    p = Product(
        ProductName=d['ProductName'],
        Category=d['Category'],
        Price=float(d['Price']),
        Cost=float(d['Cost']),
        Description=d.get('Description'),
        Seasonal=bool(d['Seasonal']),
        Active=bool(d['Active']),
        IntroducedDate=datetime.strptime(d['IntroducedDate'], '%Y-%m-%d').date(),
        Ingredients=d.get('Ingredients')
    )
    db.session.add(p)
    db.session.commit()
    return jsonify({'message': 'Created', 'ProductId': p.ProductId}), 201

@app.route('/api/products/<int:pid>', methods=['PUT'])
def update_product(pid):
    p = Product.query.get(pid)
    if not p:
        return jsonify({'error': 'Not found'}), 404
    d = request.json
    p.ProductName = d.get('ProductName', p.ProductName)
    p.Category = d.get('Category', p.Category)
    if 'Price' in d:
        p.Price = float(d['Price'])
    if 'Cost' in d:
        p.Cost = float(d['Cost'])
    p.Description = d.get('Description', p.Description)
    if 'Seasonal' in d:
        p.Seasonal = bool(d['Seasonal'])
    if 'Active' in d:
        p.Active = bool(d['Active'])
    if 'IntroducedDate' in d:
        p.IntroducedDate = datetime.strptime(d['IntroducedDate'], '%Y-%m-%d').date()
    p.Ingredients = d.get('Ingredients', p.Ingredients)
    db.session.commit()
    return jsonify({'message': 'Updated'}), 200

@app.route('/api/products/<int:pid>', methods=['DELETE'])
def delete_product(pid):
    p = Product.query.get(pid)
    if not p:
        return jsonify({'error': 'Not found'}), 404
    db.session.delete(p)
    db.session.commit()
    return '', 204

@app.route('/api/customers', methods=['GET'])
def get_customers():
    data = Customer.query.all()
    result = []
    for c in data:
        result.append({
            'CustomerId': c.CustomerId,
            'FirstName': c.FirstName,
            'LastName': c.LastName,
            'Age': c.Age,
            'Gender': c.Gender,
            'PostalCode': c.PostalCode,
            'Email': c.Email,
            'PhoneNumber': c.PhoneNumber,
            'MembershipStatus': c.MembershipStatus,
            'JoinDate': c.JoinDate.isoformat() if c.JoinDate else None,
            'LastPurchaseDate': c.LastPurchaseDate.isoformat() if c.LastPurchaseDate else None,
            'TotalSpending': c.TotalSpending,
            'AverageOrderValue': c.AverageOrderValue,
            'Frequency': c.Frequency,
            'PreferredCategory': c.PreferredCategory,
            'Churned': c.Churned
        })
    return jsonify(result), 200

@app.route('/api/customers/<int:cid>', methods=['GET'])
def get_customer(cid):
    c = Customer.query.get(cid)
    if not c:
        return jsonify({'error': 'Not found'}), 404
    return jsonify({
        'CustomerId': c.CustomerId,
        'FirstName': c.FirstName,
        'LastName': c.LastName,
        'Age': c.Age,
        'Gender': c.Gender,
        'PostalCode': c.PostalCode,
        'Email': c.Email,
        'PhoneNumber': c.PhoneNumber,
        'MembershipStatus': c.MembershipStatus,
        'JoinDate': c.JoinDate.isoformat() if c.JoinDate else None,
        'LastPurchaseDate': c.LastPurchaseDate.isoformat() if c.LastPurchaseDate else None,
        'TotalSpending': c.TotalSpending,
        'AverageOrderValue': c.AverageOrderValue,
        'Frequency': c.Frequency,
        'PreferredCategory': c.PreferredCategory,
        'Churned': c.Churned
    }), 200

@app.route('/api/customers', methods=['POST'])
def create_customer():
    d = request.json
    c = Customer(
        FirstName=d['FirstName'],
        LastName=d['LastName'],
        Age=d.get('Age'),
        Gender=d.get('Gender'),
        PostalCode=d.get('PostalCode'),
        Email=d.get('Email'),
        PhoneNumber=d.get('PhoneNumber'),
        MembershipStatus=d.get('MembershipStatus', 'Basic'),
        JoinDate=datetime.strptime(d['JoinDate'], '%Y-%m-%d').date() if d.get('JoinDate') else None,
        LastPurchaseDate=datetime.strptime(d['LastPurchaseDate'], '%Y-%m-%d').date() if d.get('LastPurchaseDate') else None,
        TotalSpending=float(d.get('TotalSpending', 0.0)),
        AverageOrderValue=float(d['AverageOrderValue']) if d.get('AverageOrderValue') else None,
        Frequency=d.get('Frequency'),
        PreferredCategory=d.get('PreferredCategory'),
        Churned=bool(d.get('Churned', False))
    )
    db.session.add(c)
    db.session.commit()
    return jsonify({'message': 'Created', 'CustomerId': c.CustomerId}), 201

@app.route('/api/customers/<int:cid>', methods=['PUT'])
def update_customer(cid):
    c = Customer.query.get(cid)
    if not c:
        return jsonify({'error': 'Not found'}), 404
    d = request.json
    c.FirstName = d.get('FirstName', c.FirstName)
    c.LastName = d.get('LastName', c.LastName)
    if 'Age' in d:
        c.Age = d['Age']
    if 'Gender' in d:
        c.Gender = d['Gender']
    if 'PostalCode' in d:
        c.PostalCode = d['PostalCode']
    if 'Email' in d:
        c.Email = d['Email']
    if 'PhoneNumber' in d:
        c.PhoneNumber = d['PhoneNumber']
    if 'MembershipStatus' in d:
        c.MembershipStatus = d['MembershipStatus']
    if 'JoinDate' in d:
        c.JoinDate = datetime.strptime(d['JoinDate'], '%Y-%m-%d').date()
    if 'LastPurchaseDate' in d:
        c.LastPurchaseDate = datetime.strptime(d['LastPurchaseDate'], '%Y-%m-%d').date()
    if 'TotalSpending' in d:
        c.TotalSpending = float(d['TotalSpending'])
    if 'AverageOrderValue' in d:
        c.AverageOrderValue = float(d['AverageOrderValue'])
    if 'Frequency' in d:
        c.Frequency = d['Frequency']
    if 'PreferredCategory' in d:
        c.PreferredCategory = d['PreferredCategory']
    if 'Churned' in d:
        c.Churned = bool(d['Churned'])
    db.session.commit()
    return jsonify({'message': 'Updated'}), 200

@app.route('/api/customers/<int:cid>', methods=['DELETE'])
def delete_customer(cid):
    c = Customer.query.get(cid)
    if not c:
        return jsonify({'error': 'Not found'}), 404
    db.session.delete(c)
    db.session.commit()
    return '', 204

@app.route('/api/orders', methods=['GET'])
def get_orders():
    data = Order.query.all()
    result = []
    for o in data:
        result.append({
            'TransactionId': o.TransactionId,
            'CustomerId': o.CustomerId,
            'OrderDate': o.OrderDate.isoformat(),
            'TotalAmount': o.TotalAmount,
            'Status': o.Status,
            'PaymentMethod': o.PaymentMethod,
            'Channel': o.Channel,
            'StoreId': o.StoreId,
            'PromotionId': o.PromotionId,
            'DiscountAmount': o.DiscountAmount
        })
    return jsonify(result), 200

@app.route('/api/orders/<int:oid>', methods=['GET'])
def get_order(oid):
    o = Order.query.get(oid)
    if not o:
        return jsonify({'error': 'Not found'}), 404
    return jsonify({
        'TransactionId': o.TransactionId,
        'CustomerId': o.CustomerId,
        'OrderDate': o.OrderDate.isoformat(),
        'TotalAmount': o.TotalAmount,
        'Status': o.Status,
        'PaymentMethod': o.PaymentMethod,
        'Channel': o.Channel,
        'StoreId': o.StoreId,
        'PromotionId': o.PromotionId,
        'DiscountAmount': o.DiscountAmount
    }), 200

@app.route('/api/orders', methods=['POST'])
def create_order():
    d = request.json
    o = Order(
        CustomerId = d['CustomerId'],
        OrderDate = datetime.strptime(d['OrderDate'], '%Y-%m-%d %H:%M:%S'),
        TotalAmount = float(d['TotalAmount']),
        Status = d.get('Status', 'Pending'),
        PaymentMethod = d['PaymentMethod'],
        Channel = d['Channel'],
        StoreId = d.get('StoreId'),
        PromotionId = d.get('PromotionId'),
        DiscountAmount = float(d.get('DiscountAmount', 0.0))
    )
    db.session.add(o)
    db.session.commit()
    return jsonify({'message': 'Created', 'TransactionId': o.TransactionId}), 201

@app.route('/api/orders/<int:oid>', methods=['PUT'])
def update_order(oid):
    o = Order.query.get(oid)
    if not o:
        return jsonify({'error': 'Not found'}), 404
    d = request.json
    if 'CustomerId' in d:
        o.CustomerId = d['CustomerId']
    if 'OrderDate' in d:
        o.OrderDate = datetime.strptime(d['OrderDate'], '%Y-%m-%d %H:%M:%S')
    if 'TotalAmount' in d:
        o.TotalAmount = float(d['TotalAmount'])
    if 'Status' in d:
        o.Status = d['Status']
    if 'PaymentMethod' in d:
        o.PaymentMethod = d['PaymentMethod']
    if 'Channel' in d:
        o.Channel = d['Channel']
    if 'StoreId' in d:
        o.StoreId = d['StoreId']
    if 'PromotionId' in d:
        o.PromotionId = d['PromotionId']
    if 'DiscountAmount' in d:
        o.DiscountAmount = float(d['DiscountAmount'])
    db.session.commit()
    return jsonify({'message': 'Updated'}), 200

@app.route('/api/orders/<int:oid>', methods=['DELETE'])
def delete_order(oid):
    o = Order.query.get(oid)
    if not o:
        return jsonify({'error': 'Not found'}), 404
    db.session.delete(o)
    db.session.commit()
    return '', 204

@app.route('/api/orderitems', methods=['GET'])
def get_orderitems():
    data = OrderItem.query.all()
    result = []
    for i in data:
        result.append({
            'OrderItemId': i.OrderItemId,
            'TransactionId': i.TransactionId,
            'ProductId': i.ProductId,
            'Quantity': i.Quantity,
            'Price': i.Price
        })
    return jsonify(result), 200

@app.route('/api/orderitems/<int:iid>', methods=['GET'])
def get_orderitem(iid):
    i = OrderItem.query.get(iid)
    if not i:
        return jsonify({'error': 'Not found'}), 404
    return jsonify({
        'OrderItemId': i.OrderItemId,
        'TransactionId': i.TransactionId,
        'ProductId': i.ProductId,
        'Quantity': i.Quantity,
        'Price': i.Price
    }), 200

@app.route('/api/orderitems', methods=['POST'])
def create_orderitem():
    d = request.json
    i = OrderItem(
        TransactionId=d['TransactionId'],
        ProductId=d['ProductId'],
        Quantity=d['Quantity'],
        Price=float(d['Price'])
    )
    db.session.add(i)
    db.session.commit()
    return jsonify({'message': 'Created', 'OrderItemId': i.OrderItemId}), 201

@app.route('/api/orderitems/<int:iid>', methods=['PUT'])
def update_orderitem(iid):
    i = OrderItem.query.get(iid)
    if not i:
        return jsonify({'error': 'Not found'}), 404
    d = request.json
    if 'TransactionId' in d:
        i.TransactionId = d['TransactionId']
    if 'ProductId' in d:
        i.ProductId = d['ProductId']
    if 'Quantity' in d:
        i.Quantity = d['Quantity']
    if 'Price' in d:
        i.Price = float(d['Price'])
    db.session.commit()
    return jsonify({'message': 'Updated'}), 200

@app.route('/api/orderitems/<int:iid>', methods=['DELETE'])
def delete_orderitem(iid):
    i = OrderItem.query.get(iid)
    if not i:
        return jsonify({'error': 'Not found'}), 404
    db.session.delete(i)
    db.session.commit()
    return '', 204

@app.route("/api/inventory", methods=["GET"])
def get_inventory():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT name, quantity, unit FROM inventory;")
    rows = cur.fetchall()
    cur.close()
    conn.close()

    inventory = [{"name": r[0], "quantity": r[1], "unit": r[2]} for r in rows]
    return jsonify(inventory)

@app.route('/api/sales-stats', methods=['GET'])
def get_sales_stats():
    today = datetime.today().date()
    ten_days_ago = today - timedelta(days=9)

    sales_data = (
        db.session.query(
            func.date(Order.OrderDate).label('date'),
            func.count(Order.TransactionId).label('sales')
        )
        .filter(Order.OrderDate >= ten_days_ago)
        .group_by(func.date(Order.OrderDate))
        .order_by(func.date(Order.OrderDate))
        .all()
    )

    result = []
    for entry in sales_data:
        day_str = entry.date.strftime('%d.%m')
        result.append({'day': day_str, 'sales': entry.sales})

    return jsonify(result)


if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True, port=5000)
