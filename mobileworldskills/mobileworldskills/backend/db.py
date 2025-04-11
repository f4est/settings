import pymysql

def get_db():
    return pymysql.connect(
        host='localhost',
        user='root',
        password='password',
        database='belle_croissant_db',
        autocommit=True
    )
