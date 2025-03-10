CREATE DATABASE PharmacyDB;
USE PharmacyDB;

CREATE TABLE users (
    id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    billing_address TEXT,
    default_shipping_address TEXT,
    country VARCHAR(50),
    phone VARCHAR(20) UNIQUE NOT NULL
);


CREATE TABLE medicines (
    id INT PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    weight DECIMAL(5,2) NULL,
    description TEXT NULL,
    manufacturer VARCHAR(100),
    stock INT DEFAULT 0, 
    expiry_date DATE NOT NULL,
    prescription_required BOOLEAN DEFAULT FALSE,
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE orders (
    id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    shipping_address TEXT NOT NULL,
    order_address TEXT NOT NULL,
    order_email VARCHAR(100) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_status ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE
);


CREATE TABLE order_details (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    medicine_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    sku VARCHAR(50) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE CASCADE
);


CREATE TABLE inventory (
    id INT PRIMARY KEY AUTO_INCREMENT,
    medicine_id INT NOT NULL,
    stock_level INT NOT NULL DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE CASCADE
);


CREATE TABLE prescriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    doctor_id INT NOT NULL,
    medicine_id INT NOT NULL,
    prescription_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE CASCADE
);


CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_mode ENUM('Cash', 'Card', 'Insurance') NOT NULL,
    transaction_status ENUM('Pending', 'Completed', 'Failed') NOT NULL DEFAULT 'Pending',
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);


INSERT INTO users (email, password, full_name, role, phone, country) VALUES
('john@example.com', 'hashed_password', 'John Doe', 'customer', '+1234567890', 'USA'),
('alice@example.com', 'hashed_password', 'Alice Smith', 'pharmacist', '+1987654321', 'UK'),
('admin@example.com', 'hashed_password', 'Admin User', 'admin', '+1122334455', 'India');

INSERT INTO medicines (sku, name, category, price, manufacturer, stock, expiry_date, prescription_required) VALUES
('MED001', 'Paracetamol', 'Painkiller', 5.99, 'XYZ Pharma', 100, '2026-12-31', FALSE),
('MED002', 'Amoxicillin', 'Antibiotic', 12.50, 'ABC Pharma', 50, '2025-06-30', TRUE),
('MED003', 'Vitamin C', 'Supplement', 8.00, 'HealthCare Inc.', 75, '2027-01-15', FALSE);

INSERT INTO orders (customer_id, amount, shipping_address, order_address, order_email, order_status) VALUES
(1, 17.99, '123 Main St, USA', '123 Main St, USA', 'john@example.com', 'Shipped');

INSERT INTO order_details (order_id, medicine_id, price, sku, quantity) VALUES
(1, 1, 5.99, 'MED001', 2),
(1, 3, 8.00, 'MED003', 1);


SELECT m.name, u.country, SUM(od.quantity) AS total_sold
FROM order_details od
JOIN orders o ON od.order_id = o.id
JOIN users u ON o.customer_id = u.id
JOIN medicines m ON od.medicine_id = m.id
GROUP BY m.name, u.country
ORDER BY total_sold DESC
LIMIT 10;


SELECT m.name, 
       SUM(od.quantity) / (m.stock + SUM(od.quantity)) AS turnover_rate
FROM order_details od
JOIN medicines m ON od.medicine_id = m.id
GROUP BY m.name, m.stock
ORDER BY turnover_rate DESC;


SELECT u.full_name, u.email, COUNT(o.id) AS total_orders
FROM users u
JOIN orders o ON u.id = o.customer_id
GROUP BY u.full_name, u.email
ORDER BY total_orders DESC
LIMIT 10;



