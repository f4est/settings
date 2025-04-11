from flask import Flask
from config import SECRET_KEY
from routes.auth_routes import auth_bp
from routes.profile_routes import profile_bp
from routes.address_routes import address_bp
from routes.subscription_routes import subscription_bp
from routes.order_routes import order_bp
from routes.product_routes import product_bp

app = Flask(__name__)
app.config['SECRET_KEY'] = SECRET_KEY

app.register_blueprint(auth_bp)
app.register_blueprint(profile_bp)
app.register_blueprint(address_bp)
app.register_blueprint(subscription_bp)
app.register_blueprint(order_bp)
app.register_blueprint(product_bp)

if __name__ == '__main__':
    app.run(debug=True)
