import csv
import pymysql

db = pymysql.connect(
  host='localhost',
  user='root',
  password='password',
  database='belle_croissant_db',
  autocommit=True
)
c = db.cursor()

with open('customers_cleaned.csv','r',encoding='utf-8') as f:
    rdr = csv.DictReader(f)
    for row in rdr:
        cid = int(row['customer_id'])
        fn = row['first_name']
        ln = row['last_name']
        em = row['email']
        ph = row['phone']
        ct = row['city']
        c.execute('insert into customers(id,first_name,last_name,email,phone,city) values(%s,%s,%s,%s,%s,%s)', (cid,fn,ln,em,ph,ct))

with open('products_cleaned.csv','r',encoding='utf-8') as f:
    rdr = csv.DictReader(f)
    for row in rdr:
        pid = int(row['product_id'])
        nm = row['product_name']
        cat = row['category']
        pr = float(row['price'])
        c.execute('insert into products(id,name,category,price) values(%s,%s,%s,%s)', (pid,nm,cat,pr))

with open('sales_transactions_cleaned.csv','r',encoding='utf-8') as f:
    rdr = csv.DictReader(f)
    for row in rdr:
        sid = int(row['sale_id'])
        cid = int(row['customer_id'])
        pid = int(row['product_id'])
        q = int(row['quantity'])
        sd = row['sale_date']
        ta = float(row['total_amount'])
        c.execute('insert into sales(id,customer_id,product_id,quantity,sale_date,total_amount) values(%s,%s,%s,%s,%s,%s)', (sid,cid,pid,q,sd,ta))

db.close()
