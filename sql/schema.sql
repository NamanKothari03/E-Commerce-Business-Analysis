-- schema.sql : database design for the E-Commerce Analytics project
-- Run this in MySQL Workbench BEFORE loading data.

DROP DATABASE IF EXISTS ecommerce;
CREATE DATABASE ecommerce;
USE ecommerce;

-- One row per customer
CREATE TABLE customers (
    customer_id   VARCHAR(10)  PRIMARY KEY,
    city          VARCHAR(50),
    state         VARCHAR(50),
    region        VARCHAR(20)
);

-- One row per product
CREATE TABLE products (
    product_id    VARCHAR(10)  PRIMARY KEY,
    product_name  VARCHAR(100),
    category      VARCHAR(50),
    sub_category  VARCHAR(50)
);

-- One row per order LINE (an order can have 1-3 lines)
CREATE TABLE orders (
    order_line_id  INT AUTO_INCREMENT PRIMARY KEY,
    order_id       VARCHAR(15)  NOT NULL,
    order_date     DATE         NOT NULL,
    customer_id    VARCHAR(10)  NOT NULL,
    product_id     VARCHAR(10)  NOT NULL,
    quantity       INT          NOT NULL,
    sales          DECIMAL(12,2) NOT NULL,
    discount       DECIMAL(4,2) NOT NULL,
    cost           DECIMAL(12,2) NOT NULL,
    profit         DECIMAL(12,2) NOT NULL,
    shipping_cost  DECIMAL(10,2) NOT NULL,
    delivery_days  INT,
    payment_mode   VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id)  REFERENCES products(product_id),
    INDEX idx_order_id (order_id),
    INDEX idx_order_date (order_date),
    INDEX idx_customer (customer_id)
);

-- Only order lines that were returned
CREATE TABLE returns (
    order_line_id    INT PRIMARY KEY,
    returned_revenue DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (order_line_id) REFERENCES orders(order_line_id)
);
