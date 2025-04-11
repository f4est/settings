CREATE DATABASE IF NOT EXISTS belle_croissant_db;
USE belle_croissant_db;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  password VARCHAR(255),
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone VARCHAR(50),
  subscribe TINYINT(1),
  secret_question VARCHAR(255),
  secret_answer VARCHAR(255),
  profile_image LONGBLOB,
  preferred_delivery VARCHAR(50)
);

CREATE TABLE addresses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  label VARCHAR(100),
  full_address VARCHAR(255),
  preferred TINYINT(1),
  FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  order_date DATETIME,
  total DECIMAL(10,2),
  status VARCHAR(50),
  FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  price DECIMAL(10,2),
  FOREIGN KEY (order_id) REFERENCES orders (id)
);

CREATE TABLE customers(
  id INT PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(255),
  phone VARCHAR(50),
  city VARCHAR(100)
);

CREATE TABLE products(
  id INT PRIMARY KEY,
  name VARCHAR(255),
  category VARCHAR(100),
  price DECIMAL(10,2),
  image_blob LONGBLOB
);

CREATE TABLE sales(
  id INT PRIMARY KEY,
  customer_id INT,
  product_id INT,
  quantity INT,
  sale_date DATE,
  total_amount DECIMAL(10,2),
  FOREIGN KEY(customer_id) REFERENCES customers(id),
  FOREIGN KEY(product_id) REFERENCES products(id)
);
