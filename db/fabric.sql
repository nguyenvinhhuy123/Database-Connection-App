CREATE DATABASE  IF NOT EXISTS fabric;

USE  fabric;

DROP TABLE IF EXISTS paid_by_payment;
DROP TABLE IF EXISTS supply;
DROP TABLE IF EXISTS bolt;
DROP TABLE IF EXISTS category_current_price;
DROP TABLE IF EXISTS supplier_phone;
DROP TABLE IF EXISTS customer_phone;
DROP TABLE IF EXISTS customer_order;
DROP TABLE IF EXISTS supplier;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS import_order;
DROP TABLE IF EXISTS manager;
DROP TABLE IF EXISTS partner_staff;
DROP TABLE IF EXISTS operational_staff;
DROP TABLE IF EXISTS office_staff;
DROP TABLE IF EXISTS category;

CREATE TABLE manager (
    manager_code INT AUTO_INCREMENT PRIMARY KEY,
    fname VARCHAR(255),
    lname VARCHAR(255),
    gender ENUM('Male', 'Female'),
    address VARCHAR(255),
    phone_number VARCHAR(20) UNIQUE,
	CHECK (phone_number REGEXP '^[0-9]{10}$')
);

CREATE TABLE partner_staff (
    partner_code INT AUTO_INCREMENT PRIMARY KEY,
    fname VARCHAR(255),
    lname VARCHAR(255),
    gender ENUM('Male', 'Female'),
    address VARCHAR(255),
    phone_number VARCHAR(20) UNIQUE,
	CHECK (phone_number REGEXP '^[0-9]{10}$')
);

CREATE TABLE operational_staff (
    opcode INT AUTO_INCREMENT PRIMARY KEY,
    fname VARCHAR(255),
    lname VARCHAR(255),
    gender ENUM('Male', 'Female'),
    address VARCHAR(255),
    phone_number VARCHAR(20) UNIQUE,
	CHECK (phone_number REGEXP '^[0-9]{10}$')
);

CREATE TABLE office_staff (
    office_code INT AUTO_INCREMENT PRIMARY KEY,
    fname VARCHAR(255),
    lname VARCHAR(255),
    gender ENUM('Male', 'Female'),
    address VARCHAR(255),
    phone_number VARCHAR(20) UNIQUE,
	CHECK (phone_number REGEXP '^[0-9]{10}$')
);

CREATE TABLE category (
    cat_code INT AUTO_INCREMENT PRIMARY KEY,
    cat_name VARCHAR(255),
    quantity INT DEFAULT 0,
    color VARCHAR(50),
    in_order BOOLEAN # the category is in the order or in the storage
);

CREATE TABLE supplier (
    sup_code INT AUTO_INCREMENT PRIMARY KEY,
    sup_name VARCHAR(255),
    address VARCHAR(255),
    bank_account VARCHAR(12) UNIQUE,
    tax_code VARCHAR(10) UNIQUE,
    partner_code INT,
    FOREIGN KEY (partner_code) REFERENCES partner_staff(partner_code),
    CHECK (bank_account REGEXP '^[0-9]{8,12}$'),
    CHECK (tax_code REGEXP '^[0-9]{10}$')
);


CREATE TABLE supplier_phone (
    sup_code INT,
    phone_number VARCHAR(20) UNIQUE,
    PRIMARY KEY (sup_code, phone_number),
    FOREIGN KEY (sup_code) REFERENCES supplier(sup_code),
	CHECK (phone_number REGEXP '^[0-9]{10}$')
);

CREATE TABLE customer (
    customer_code INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    address VARCHAR(255),
    arrearage_amount DECIMAL(10, 2) DEFAULT 0,
    warning_time TIMESTAMP DEFAULT NULL,
    debt_mode VARCHAR(50) DEFAULT NULL,
    office_code INT,
    FOREIGN KEY (office_code) REFERENCES office_staff(office_code)
);

CREATE TABLE customer_phone (
    customer_code INT,
    phone_number VARCHAR(20) UNIQUE,
    PRIMARY KEY (customer_code, phone_number),
    FOREIGN KEY (customer_code) REFERENCES customer(customer_code), 
	CHECK (phone_number REGEXP '^[0-9]{10}$')
);

CREATE TABLE customer_order (
    order_code INT AUTO_INCREMENT PRIMARY KEY,
    opcode INT,
	customer_code INT NOT NULL,
    number_of_bolts INT DEFAULT 0,
    status VARCHAR(50) DEFAULT 'New',
    reason VARCHAR(255) DEFAULT NULL,
    process_datetime DATETIME,
    price DECIMAL(10, 2) DEFAULT 0,
    remaining_price DECIMAL(10, 2) DEFAULT 0,
	FOREIGN KEY (opcode) REFERENCES operational_staff(opcode),
    FOREIGN KEY (customer_code) REFERENCES customer(customer_code)
);

CREATE TABLE import_order (
    import_code INT AUTO_INCREMENT PRIMARY KEY,
    purchase_price DECIMAL(10, 2) DEFAULT 0,
    import_date DATE
);

CREATE TABLE supply (
    import_code INT,
    cat_code INT,
    sup_code INT,
    PRIMARY KEY (import_code, cat_code, sup_code),
    FOREIGN KEY (import_code) REFERENCES import_order(import_code),
    FOREIGN KEY (cat_code) REFERENCES category(cat_code),
    FOREIGN KEY (sup_code) REFERENCES supplier(sup_code)
);

CREATE TABLE paid_by_payment (
    order_code INT,
    customer_code INT,
    pay_datetime DATETIME,
    type VARCHAR(50),
    amount DECIMAL(10, 2),
    PRIMARY KEY (order_code, customer_code, pay_datetime),
    FOREIGN KEY (order_code) REFERENCES customer_order(order_code),
    FOREIGN KEY (customer_code) REFERENCES customer(customer_code)
);

CREATE TABLE bolt (
    cat_code INT,
    bolt_code INT,
    bolt_length DECIMAL(10, 2) DEFAULT 0,
    order_code INT,
    PRIMARY KEY (cat_code, bolt_code),
    FOREIGN KEY (cat_code) REFERENCES category(cat_code),
    FOREIGN KEY (order_code) REFERENCES customer_order(order_code)
);

CREATE TABLE category_current_price (
    cat_code INT,
    p_date DATE,
    price DECIMAL(10, 2) DEFAULT 0,
    PRIMARY KEY (cat_code, p_date, price),
    FOREIGN KEY (cat_code) REFERENCES category(cat_code)
);


















