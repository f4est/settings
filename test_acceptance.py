import requests
import os

BASE_URL = "http://localhost:3000"
LOG_DIR = "logs"
os.makedirs(LOG_DIR, exist_ok=True)

def save_log(filename, content):
    path = os.path.join(LOG_DIR, filename)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

def test_get_all_products():
    r = requests.get(f"{BASE_URL}/api/products")
    txt = f"Status: {r.status_code}\nBody: {r.text}"
    save_log("GET_all_products.txt", txt)

def test_get_one_product():
    r = requests.get(f"{BASE_URL}/api/products/3")
    txt = f"Status: {r.status_code}\nBody: {r.text}"
    save_log("GET_one_product.txt", txt)

def test_post_product():
    data = {"name": "Brownie", "price": 4.75, "stock": 15}
    r = requests.post(f"{BASE_URL}/api/products", json=data)
    txt = f"Status: {r.status_code}\nBody: {r.text}"
    save_log("POST_product.txt", txt)

def test_put_product():
    # Обновляем существующий продукт, например 'Baguette' с id=2
    data = {"name": "Updated Baguette", "price": 3.5, "stock": 25}
    r = requests.put(f"{BASE_URL}/api/products/2", json=data)
    txt = f"Status: {r.status_code}\nBody: {r.text}"
    save_log("PUT_product.txt", txt)

def test_delete_product():
    # Удаляем, например, 'Tarte aux Pommes' с id=6
    r = requests.delete(f"{BASE_URL}/api/products/6")
    txt = f"Status: {r.status_code}\nBody: {r.text}"
    save_log("DELETE_product.txt", txt)

def test_get_all_orders():
    r = requests.get(f"{BASE_URL}/api/orders")
    txt = f"Status: {r.status_code}\nBody: {r.text}"
    save_log("GET_all_orders.txt", txt)

def test_get_one_order():
    r = requests.get(f"{BASE_URL}/api/orders/3")  # order with product_id=3
    txt = f"Status: {r.status_code}\nBody: {r.text}"
    save_log("GET_one_order.txt", txt)

def test_post_order():
    # Создаём заказ на product_id=1 (Croissant)
    data = {"product_id": 1, "quantity": 2}
    r = requests.post(f"{BASE_URL}/api/orders", json=data)
    txt = f"Status: {r.status_code}\nBody: {r.text}"
    save_log("POST_order.txt", txt)

def test_put_order_complete():
    # Завершаем заказ id=4
    r = requests.put(f"{BASE_URL}/api/orders/4/complete")
    txt = f"Status: {r.status_code}\nBody: {r.text}"
    save_log("PUT_order_complete.txt", txt)

def test_put_order_cancel():
    # Отменяем заказ id=5
    r = requests.put(f"{BASE_URL}/api/orders/5/cancel")
    txt = f"Status: {r.status_code}\nBody: {r.text}"
    save_log("PUT_order_cancel.txt", txt)

if __name__ == "__main__":
    test_get_all_products()
    test_get_one_product()
    test_post_product()
    test_put_product()
    test_delete_product()
    test_get_all_orders()
    test_get_one_order()
    test_post_order()
    test_put_order_complete()
    test_put_order_cancel()
